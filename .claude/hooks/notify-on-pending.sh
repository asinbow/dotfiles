#!/bin/bash

INPUT=$(cat)
echo "$INPUT" | bash /Users/apacit/.claude/hooks/notify.sh pending
