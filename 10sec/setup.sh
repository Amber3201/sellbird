#!/usr/bin/env bash
# 10sec Codespace setup: runs once when the Codespace is created.
set -euo pipefail
cd "$(dirname "$0")/.."

pip install -e .
npm install -g @anthropic-ai/claude-code

# Put the 10sec templates in place. Both targets are gitignored, so what
# you fill in here (mailbox, postal address) never reaches this public repo.
[ -f sellbird.local.yaml ] || cp 10sec/sellbird.local.yaml sellbird.local.yaml
[ -f skills/email_rules.md ] || cp 10sec/email_rules.md skills/email_rules.md

echo
echo "10sec setup done. Next: run 'claude' once to sign in, then open 10sec/CODESPACE-10SEC.md"
