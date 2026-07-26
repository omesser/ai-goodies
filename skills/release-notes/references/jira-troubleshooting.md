# Jira Source Troubleshooting

- Jira auth uses Basic auth with `EMAIL:JIRA_TOKEN`.
- `401` on Jira auth with `-u`: token/account mismatch, expired token, or invalid token.
- `404` for a specific issue: missing key, wrong project key, or permission restriction.
- Bearer token failing on site endpoints: use the Cloud ID endpoint with Basic auth for this flow.
