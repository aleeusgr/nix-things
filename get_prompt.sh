#!/bin/sh

# Check if all input files exist
if [ ! -f "docs/k8s.md" ] || [ ! -f "k8s.nix" ] || [ ! -f "docs/context.md" ]; then
    echo "One or more input files are missing."
    exit 1
fi

# Create the output file
OUTPUT_FILE="llm_prompt.md"
echo "# LLM Prompt for Code Analysis" > $OUTPUT_FILE

# Add issue description
echo "# Issue Description" >> $OUTPUT_FILE
cat "docs/k8s.md" >> $OUTPUT_FILE

# Add code
echo "# Code" >> $OUTPUT_FILE
cat "k8s.nix" >> $OUTPUT_FILE

# Add additional context
echo "# Additional Context" >> $OUTPUT_FILE
cat "docs/context.md" >> $OUTPUT_FILE

echo "LLM prompt created successfully: $OUTPUT_FILE"

