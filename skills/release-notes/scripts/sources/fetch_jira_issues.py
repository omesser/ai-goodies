#!/usr/bin/env python3
"""
Jira source adapter for the release-notes skill.

Fetches Jira issue metadata for commits JSON and enriches each commit.

Requirements (from env or dotenv file):
- ATLASSIAN_BASE_URL
- EMAIL
- optional: JIRA_TOKEN (if missing, Jira enrichment is skipped)

Input:
- --input commit-context JSON (from collect_commit_context.py)

Output:
- JSON array of commits, each with jira_issues metadata
"""

import argparse
import base64
import json
import os
import re
import sys
from typing import Any, Dict, List
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

JIRA_KEY_PATTERN = re.compile(r"\b[A-Z][A-Z0-9]+-\d+\b")


def load_dotenv_file(path: str) -> None:
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip())


def http_get_json(url: str, headers: Dict[str, str]) -> Dict[str, Any]:
    req = Request(url, headers=headers, method="GET")
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def adf_to_text(node: Any) -> str:
    if node is None:
        return ""
    if isinstance(node, str):
        return node
    if isinstance(node, list):
        return "".join(adf_to_text(item) for item in node)
    if not isinstance(node, dict):
        return ""

    node_type = node.get("type")
    if node_type == "text":
        return node.get("text", "")
    if node_type == "hardBreak":
        return "\n"

    content = adf_to_text(node.get("content", []))
    if node_type in {"paragraph", "heading", "codeBlock", "blockquote", "tableRow"}:
        return content + "\n"
    if node_type in {"bulletList", "orderedList"}:
        return content + "\n"
    if node_type == "listItem":
        line = content.strip("\n")
        return ("- " + line + "\n") if line else ""

    return content


def get_cloud_id(base_url: str) -> str:
    tenant = http_get_json(base_url.rstrip("/") + "/_edge/tenant_info", headers={})
    cloud_id = tenant.get("cloudId", "")
    if not cloud_id:
        raise RuntimeError("Could not resolve Jira cloudId from tenant_info")
    return cloud_id


def ordered_unique(items: List[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def read_commits(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as f:
        commits = json.load(f)
    if not isinstance(commits, list):
        raise RuntimeError("Input JSON must be an array of commits")
    return commits


def extract_jira_keys(commit: Dict[str, Any]) -> List[str]:
    existing = commit.get("jira_keys")
    if isinstance(existing, list):
        return ordered_unique(
            [str(item).strip() for item in existing if str(item).strip()]
        )

    text = "\n".join(
        [
            str(commit.get("subject", "")),
            str(commit.get("body", "")),
            str(commit.get("message", "")),
        ]
    )
    return ordered_unique(JIRA_KEY_PATTERN.findall(text))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fetch Jira details and attach them to each commit."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="Path to commit-context JSON file from collect_commit_context.py",
    )
    parser.add_argument(
        "--dotenv",
        default=".agents/skills/release-notes/release-notes-secrets.env",
        help=(
            "Optional env file path "
            "(default: .agents/skills/release-notes/release-notes-secrets.env)."
        ),
    )
    args = parser.parse_args()

    try:
        commits = read_commits(args.input)
    except Exception as err:
        sys.stderr.write(f"Failed to read commit input: {err}\n")
        return 1

    load_dotenv_file(args.dotenv)

    base_url = os.environ.get("ATLASSIAN_BASE_URL", "").strip()
    email = os.environ.get("EMAIL", "").strip()
    jira_token = os.environ.get("JIRA_TOKEN", "").strip()
    if not jira_token:
        passthrough_commits: List[Dict[str, Any]] = []
        for commit in commits:
            keys = extract_jira_keys(commit)
            commit_out = dict(commit)
            commit_out["jira_keys"] = keys
            commit_out["jira_issues"] = []
            passthrough_commits.append(commit_out)
        json.dump(passthrough_commits, sys.stdout, ensure_ascii=True, indent=2)
        sys.stdout.write("\n")
        return 0

    missing = [
        k for k, v in [("ATLASSIAN_BASE_URL", base_url), ("EMAIL", email)] if not v
    ]
    if missing:
        sys.stderr.write(
            "Missing required environment values for Jira enrichment: "
            + ", ".join(missing)
            + "\n"
        )
        return 1

    auth = base64.b64encode(f"{email}:{jira_token}".encode("utf-8")).decode("ascii")
    headers = {"Authorization": "Basic " + auth, "Accept": "application/json"}

    try:
        cloud_id = get_cloud_id(base_url)
    except Exception as err:
        sys.stderr.write(f"Failed to resolve cloud id from ATLASSIAN_BASE_URL: {err}\n")
        return 1

    unique_keys: List[str] = ordered_unique(
        [key for commit in commits for key in extract_jira_keys(commit)]
    )

    issues_by_key: Dict[str, Dict[str, Any]] = {}
    for key in unique_keys:
        url = (
            "https://api.atlassian.com/ex/jira/"
            + cloud_id
            + "/rest/api/3/issue/"
            + key
            + "?fields=summary,description,issuetype,status"
        )
        try:
            issue = http_get_json(url, headers=headers)
            fields = issue.get("fields", {})
            issues_by_key[key] = {
                "key": issue.get("key", key),
                "summary": fields.get("summary", ""),
                "description_text": adf_to_text(fields.get("description", {})).strip(),
                "issue_type": (fields.get("issuetype") or {}).get("name", ""),
                "status": (fields.get("status") or {}).get("name", ""),
                "url": base_url.rstrip("/") + "/browse/" + key,
            }
        except HTTPError as err:
            issues_by_key[key] = {
                "key": key,
                "error": f"HTTP {err.code}",
                "details": err.reason,
            }
        except URLError as err:
            issues_by_key[key] = {"key": key, "error": "network", "details": str(err)}
        except Exception as err:
            issues_by_key[key] = {
                "key": key,
                "error": "unexpected",
                "details": str(err),
            }

    enriched_commits: List[Dict[str, Any]] = []
    for commit in commits:
        keys = extract_jira_keys(commit)
        commit_out = dict(commit)
        commit_out["jira_keys"] = keys
        commit_out["jira_issues"] = [
            issues_by_key[key] for key in keys if key in issues_by_key
        ]
        enriched_commits.append(commit_out)

    json.dump(enriched_commits, sys.stdout, ensure_ascii=True, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
