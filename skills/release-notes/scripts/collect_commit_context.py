#!/usr/bin/env python3
"""
Collect detailed git commit context for a release range.

Outputs a JSON array with:
- sha
- subject
- body
- message (subject + body)
- jira_keys
- pr_number
- pr_source_branch
"""

import argparse
import json
import re
import subprocess
import sys
from typing import Dict, List, Optional, Tuple

JIRA_KEY_PATTERN = re.compile(r"\b[A-Z][A-Z0-9]+-\d+\b")
GITHUB_MERGE_PR_SUBJECT_PATTERN = re.compile(
    r"^Merge pull request #(?P<pr_number>\d+) from (?P<branch>.+)$"
)
GITHUB_SQUASH_PR_SUBJECT_PATTERN = re.compile(r"^.+ \(#(?P<pr_number>\d+)\)$")


def run_git(args: List[str]) -> str:
    result = subprocess.run(
        ["git"] + args,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout


def parse_commits_in_range(range_ref: str) -> List[str]:
    raw = run_git(["rev-list", "--no-merges", range_ref]).strip()
    if not raw:
        return []
    return raw.splitlines()


def parse_commit(sha: str) -> Dict[str, object]:
    field_sep = "\x1f"
    pretty = f"%H{field_sep}%s{field_sep}%b"
    out = run_git(["show", "--no-patch", "--pretty=format:" + pretty, sha])

    parts = out.split(field_sep, 2)
    if len(parts) != 3:
        raise RuntimeError(f"Unexpected commit header format for {sha}")

    commit_sha, subject, body = parts
    message = (subject + "\n" + body).strip()
    jira_keys = ordered_unique(JIRA_KEY_PATTERN.findall(message))
    pr_number, pr_source_branch = parse_pr_from_subject(subject.strip())

    return {
        "sha": commit_sha,
        "subject": subject.strip(),
        "body": body.strip(),
        "message": message,
        "jira_keys": jira_keys,
        "pr_number": pr_number,
        "pr_source_branch": pr_source_branch,
    }


def ordered_unique(items: List[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def parse_pr_from_subject(subject: str) -> Tuple[Optional[int], Optional[str]]:
    patterns = (
        GITHUB_MERGE_PR_SUBJECT_PATTERN,
        GITHUB_SQUASH_PR_SUBJECT_PATTERN,
    )
    for pattern in patterns:
        match = pattern.match(subject)
        if not match:
            continue

        pr_number_raw = match.group("pr_number")
        source_branch = (match.groupdict().get("branch") or "").strip()
        try:
            pr_number = int(pr_number_raw)
        except ValueError:
            return None, source_branch or None
        return pr_number, source_branch or None

    return None, None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Collect full commit context between two refs."
    )
    parser.add_argument(
        "--range",
        dest="range_ref",
        required=True,
        help="Git range expression, e.g. versions/web-app/11.28.2..versions/web-app/11.29.0",
    )
    args = parser.parse_args()

    try:
        shas = parse_commits_in_range(args.range_ref)
        commits = [parse_commit(sha) for sha in shas]
    except subprocess.CalledProcessError as err:
        sys.stderr.write(err.stderr or str(err) + "\n")
        return 1
    except RuntimeError as err:
        sys.stderr.write(str(err) + "\n")
        return 1

    json.dump(commits, sys.stdout, ensure_ascii=True, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
