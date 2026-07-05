#!/usr/bin/env python3
"""
GitHub source adapter for the release-notes skill.

Fetches PR metadata and enriches commit context JSON.

Requirements (from env or dotenv file):
- optional: GITHUB_TOKEN (if missing, GitHub enrichment is skipped)

Input:
- --input commit-context JSON (from collect_commit_context.py)

Output:
- JSON array of commits, each with github_pr metadata when pr_number exists
"""

import argparse
import json
import os
import re
import subprocess
import sys
from typing import Any, Dict, List, Optional
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen

GITHUB_MERGED_PR_SUBJECT_PATTERN = re.compile(
    r"^Merge pull request #(?P<pr_number>\d+) from (?P<branch>.+)$"
)
GITHUB_SQUASH_PR_SUBJECT_PATTERN = re.compile(r"^.+ \(#(?P<pr_number>\d+)\)$")


def load_dotenv_file(path: str) -> None:
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip())


def http_get_json(url: str, headers: Dict[str, str]) -> Dict[str, Any]:
    request = Request(url, headers=headers, method="GET")
    with urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def run_git(args: List[str]) -> str:
    result = subprocess.run(
        ["git"] + args,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip()


def read_commits(path: str) -> List[Dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as file:
        commits = json.load(file)
    if not isinstance(commits, list):
        raise RuntimeError("Input JSON must be an array of commits")
    return commits


def parse_pr_number_from_subject(subject: str) -> Optional[int]:
    patterns = (
        GITHUB_MERGED_PR_SUBJECT_PATTERN,
        GITHUB_SQUASH_PR_SUBJECT_PATTERN,
    )
    for pattern in patterns:
        match = pattern.match(subject.strip())
        if not match:
            continue
        try:
            return int(match.group("pr_number"))
        except ValueError:
            return None
    return None


def extract_pr_number(commit: Dict[str, Any]) -> Optional[int]:
    raw = commit.get("pr_number")
    if isinstance(raw, int):
        return raw
    if isinstance(raw, str) and raw.isdigit():
        return int(raw)
    return parse_pr_number_from_subject(str(commit.get("subject", "")))


def parse_repo_full_name_from_remote(remote_url: str) -> Optional[str]:
    remote_url = remote_url.strip()
    if not remote_url:
        return None

    ssh_match = re.match(
        r"^git@github\.com:(?P<full>[^/]+/[^/]+?)(?:\.git)?$", remote_url
    )
    if ssh_match:
        return ssh_match.group("full")

    ssh_schema_match = re.match(
        r"^ssh://git@github\.com/(?P<full>[^/]+/[^/]+?)(?:\.git)?$", remote_url
    )
    if ssh_schema_match:
        return ssh_schema_match.group("full")

    try:
        parsed = urlparse(remote_url)
    except Exception:
        return None

    if parsed.netloc != "github.com":
        return None

    path = parsed.path.strip("/")
    parts = path.split("/")
    if len(parts) < 2:
        return None

    repo_name = parts[1]
    if repo_name.endswith(".git"):
        repo_name = repo_name[:-4]
    return parts[0] + "/" + repo_name


def resolve_repo_full_name() -> Optional[str]:
    try:
        remote_url = run_git(["remote", "get-url", "origin"])
    except subprocess.CalledProcessError:
        return None
    return parse_repo_full_name_from_remote(remote_url)


def github_headers(token: str) -> Dict[str, str]:
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if token:
        headers["Authorization"] = "Bearer " + token
    return headers


def fetch_pr(
    repo_full_name: str, pr_number: int, headers: Dict[str, str]
) -> Dict[str, Any]:
    url = "https://api.github.com/repos/" + repo_full_name + "/pulls/" + str(pr_number)
    pr = http_get_json(url, headers=headers)
    return {
        "id": pr.get("id", pr_number),
        "number": pr.get("number", pr_number),
        "title": pr.get("title", ""),
        "description": pr.get("body", ""),
        "state": pr.get("state", ""),
        "source_branch": ((pr.get("head") or {}).get("ref") or ""),
        "destination_branch": ((pr.get("base") or {}).get("ref") or ""),
        "url": pr.get("html_url", ""),
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fetch GitHub PR details and attach them to each commit."
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

    github_token = os.environ.get("GITHUB_TOKEN", "").strip()
    if not github_token:
        passthrough_commits: List[Dict[str, Any]] = []
        for commit in commits:
            pr_number = extract_pr_number(commit)
            commit_out = dict(commit)
            commit_out["pr_number"] = pr_number
            commit_out["github_pr"] = None
            passthrough_commits.append(commit_out)
        json.dump(passthrough_commits, sys.stdout, ensure_ascii=True, indent=2)
        sys.stdout.write("\n")
        return 0

    repo_full_name = resolve_repo_full_name()
    if not repo_full_name:
        sys.stderr.write(
            "Could not resolve GitHub repo from origin. "
            "Ensure origin points to github.com/owner/repo.\n"
        )
        return 1

    unique_pr_numbers: List[int] = []
    seen_pr_numbers = set()
    for commit in commits:
        pr_number = extract_pr_number(commit)
        if pr_number is None or pr_number in seen_pr_numbers:
            continue
        seen_pr_numbers.add(pr_number)
        unique_pr_numbers.append(pr_number)

    prs_by_number: Dict[int, Dict[str, Any]] = {}
    headers = github_headers(github_token)
    for pr_number in unique_pr_numbers:
        try:
            prs_by_number[pr_number] = fetch_pr(repo_full_name, pr_number, headers)
        except HTTPError as err:
            prs_by_number[pr_number] = {
                "id": pr_number,
                "number": pr_number,
                "error": f"HTTP {err.code}",
                "details": err.reason,
            }
        except URLError as err:
            prs_by_number[pr_number] = {
                "id": pr_number,
                "number": pr_number,
                "error": "network",
                "details": str(err),
            }
        except Exception as err:
            prs_by_number[pr_number] = {
                "id": pr_number,
                "number": pr_number,
                "error": "unexpected",
                "details": str(err),
            }

    enriched_commits: List[Dict[str, Any]] = []
    for commit in commits:
        pr_number = extract_pr_number(commit)
        commit_out = dict(commit)
        commit_out["pr_number"] = pr_number
        commit_out["github_pr"] = (
            prs_by_number.get(pr_number) if pr_number is not None else None
        )
        enriched_commits.append(commit_out)

    json.dump(enriched_commits, sys.stdout, ensure_ascii=True, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
