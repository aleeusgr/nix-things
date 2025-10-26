#!/usr/bin/env bash
# Usage: ./code-analyze.sh <output.md>

OUT="${1:-analysis.md}"

cat > "$OUT" << 'EOF'
# Code Analysis Request

## Problem Statement
EOF

read -p "Describe the problem: " -r PROBLEM
echo "$PROBLEM" >> "$OUT"

cat >> "$OUT" << 'EOF'

## Code

EOF

read -p "Point to the code file: " -r CODE_FILE
if [[ -f "$CODE_FILE" ]]; then
    echo "\`\`\`${CODE_FILE##*.}" >> "$OUT"
    cat "$CODE_FILE" >> "$OUT"
    echo -e "\n\`\`\`" >> "$OUT"
else
    echo "⚠️  File not found: $CODE_FILE" >&2
fi

cat >> "$OUT" << 'EOF'

## Shell Output

EOF

read -p "point to a log file: " -r LOG_FILE
if [[ -n "$LOG_FILE" && -f "$LOG_FILE" ]]; then
    echo "\`\`\`" >> "$OUT"
    cat "$LOG_FILE" >> "$OUT"
    echo -e "\n\`\`\`" >> "$OUT"
fi

cat >> "$OUT" << 'EOF'

## Requested Analysis

Please provide:
1. **System Analysis**: Identify issues, root causes, and architectural concerns
2. **Testing Roadmap**: Recommend test cases, coverage strategy, and validation approach

EOF

echo "✓ Generated: $OUT"
