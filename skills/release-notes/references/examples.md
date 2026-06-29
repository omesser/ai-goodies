# Examples

## Script-first workflow

```bash
python3 .agents/skills/release-notes/scripts/collect_commit_context.py \
  --range "versions/web-app/11.28.2..versions/web-app/11.29.0" \
  > /tmp/release-commits.json
```

If only `toVersion` is known, infer previous version in the same stream:

```bash
TO_VERSION="11.29.0"
FROM_VERSION="$(git tag -l "versions/web-app/*" | sed 's#^versions/web-app/##' | sort -V | awk -v to="$TO_VERSION" 'BEGIN{prev=""} $0==to{print prev; exit} {prev=$0}')"
python3 .agents/skills/release-notes/scripts/collect_commit_context.py \
  --range "versions/web-app/${FROM_VERSION}..versions/web-app/${TO_VERSION}" \
  > /tmp/release-commits.json
```

Fetch Jira metadata and enrich commits:

```bash
python3 .agents/skills/release-notes/scripts/sources/fetch_jira_issues.py \
  --input /tmp/release-commits.json \
  --dotenv .agents/skills/release-notes/release-notes-secrets.env \
  > /tmp/release-commits-jira.json
```

Fetch GitHub PR metadata and enrich commits:

```bash
python3 .agents/skills/release-notes/scripts/sources/fetch_github_prs.py \
  --input /tmp/release-commits-jira.json \
  --dotenv .agents/skills/release-notes/release-notes-secrets.env \
  > /tmp/release-commits-enriched.json
```

Expected `.agents/skills/release-notes/release-notes-secrets.env` keys:

```bash
ATLASSIAN_BASE_URL=https://company.atlassian.net
EMAIL=your-email
JIRA_TOKEN=your-jira-token        # optional
GITHUB_TOKEN=your-github-token    # optional
```

Use `/tmp/release-commits-enriched.json` to draft the final notes.

If a token is missing, its source step is a no-op:

- missing `JIRA_TOKEN` -> `jira_issues` is empty
- missing `GITHUB_TOKEN` -> `github_pr` is `null`

## Human-written notes example

This is an example of concise wording style (without source-link prefixes).

```markdown
# Release Notes 11.29.0

## Features

- Add the ability to configure the default map type (street/satellite/hybrid).
- The “redirect to Grafana” home page behavior was removed.
- Infer the default zoom level of the map from the bounding box of all objects being shown.
- Change the default filter on the investigations page to exclude closed investigations.
- Provide the default query tab name on the investigations page.
- Allow selecting a map type at the dashboard page.
- Details popup for the weather alert.
- Open grafana weather dashboard from time scrubber.
- Toggle real-time/forecast mode on the live view map.
- Support for weather alerts in the details popup.
- Ability to manage weather alert thresholds.

## Fixed Bugs

- Filtering by alert type in live view did not show groups containing alerts of that type.
- Investigation details did not show grouping rule in some cases.
- It was not possible to clear filters by clicking on chips on the investigation page.
- Minor UX bugfixes/improvements based on FAT results for a Panda project.
- Map rule was not displayed for an offline map.
- Bug fixes related to the climate project.

### Internal Improvements

- Make it possible to validate socket.io messages in backend integration tests.
- Standardize configuration loading in a socket manager.
- Store regions as PostGIS polygons (to allow proper filtering by regions later).
- Upgrade Next.js to v11 (addresses security warnings and maintainability).
- Remove migration-only code from the web app helm chart.
```

## Non-Jira classification hints

- `fix/*`, `bugfix/*` -> Bugfixes
- `feature/*` -> Features unless clearly tooling-only
- conventions/formatting/test harness/refactors -> Internal improvements
