#!/bin/bash

EVENT=$1

[ -n "$EVENT" ] && say $EVENT

# Read JSON payload from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('session_id', ''))
" 2>/dev/null)

TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('transcript_path', ''))
" 2>/dev/null)

TITLE="Claude finished"
MESSAGE="Session complete"

# Parse transcript for last user prompt (title) and last assistant reply (message)
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  TITLE_FILE=$(mktemp)
  MESSAGE_FILE=$(mktemp)

  python3 - "$TRANSCRIPT_PATH" "$TITLE_FILE" "$MESSAGE_FILE" <<'PYEOF'
import sys, json

try:
    last_user = ""
    last_assistant = ""

    # Transcript is JSONL — one JSON object per line
    with open(sys.argv[1]) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = d.get("type")
            if msg_type not in ("user", "assistant"):
                continue

            msg = d.get("message", {})
            role = msg.get("role", msg_type)
            content = msg.get("content", "")

            if isinstance(content, list):
                text = " ".join(
                    c.get("text", "") for c in content
                    if isinstance(c, dict) and c.get("type") == "text"
                ).strip()
            else:
                text = str(content).strip()

            if not text:
                continue

            if role == "user":
                last_user = text
            elif role == "assistant":
                last_assistant = text

    title = last_user[:60].replace('\n', ' ').replace('\r', '')
    if len(last_user) > 60:
        title += "…"

    body = last_assistant[:120].replace('\n', ' ').replace('\r', '')
    if len(last_assistant) > 120:
        body += "…"

    with open(sys.argv[2], 'w') as f:
        f.write(title)
    with open(sys.argv[3], 'w') as f:
        f.write(body)
except Exception:
    pass
PYEOF

  EXTRACTED_TITLE=$(cat "$TITLE_FILE")
  EXTRACTED_MESSAGE=$(cat "$MESSAGE_FILE")
  rm -f "$TITLE_FILE" "$MESSAGE_FILE"

  [ -n "$EXTRACTED_TITLE" ] && TITLE="$EXTRACTED_TITLE"
  [ -n "$EXTRACTED_MESSAGE" ] && MESSAGE="$EXTRACTED_MESSAGE"
fi

if [ -n "$__CFBundleIdentifier" ]; then
  ACTIVATE_BUNDLE="$__CFBundleIdentifier"
else
  ACTIVATE_BUNDLE="com.mitchellh.ghostty"
fi

/opt/homebrew/bin/terminal-notifier \
  -title "Claude[$EVENT]: ${TITLE}" \
  -message "${MESSAGE}" \
  -sound "Submarine" \
  -group "claude-stop-${SESSION_ID}" \
  -activate "${ACTIVATE_BUNDLE}"
