#!/bin/bash
# {{ ansible_managed }}

# This script posts status messages to Slack.
#
# Usage: provide DISPLAY_NAME, ICON_EMOJI, COLOR and TITLE in
# the environment and call this script.

WEBHOOK_URL="https://hooks.slack.com/services/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"
DISPLAY_NAME="Default name"
ICON_EMOJI="poop"
COLOR="danger"
TITLE="Someone called the notification script without changing the defaults"

read -r -d '' PAYLOAD << EOF
{
  "username": "${DISPLAY_NAME}",
  "icon_emoji": ":${ICON_EMOJI}:",
  "attachments": [
    {
      "color": "${COLOR}",
      "ts": "$(date +%s)",
      "title": "${TITLE}"
    }
  ]
}
EOF

curl -X POST -H 'Content-type: application/json'  --data "${PAYLOAD}" ${WEBHOOK_URL}
