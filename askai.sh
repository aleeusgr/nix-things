#!/bin/sh

# Help section
if [ "$1" = "-h" ]; then
  echo "a shell script that sends requests to the local ollama backend"
  echo "Usage: "$0" [prompt_file] [role] [model]"
  echo "  prompt_file: file containing the prompt (default: prompt.md)"
  echo "  role: role of the assistant (default: user)"
  echo "  model: AI model to use (default: codegemma)"
  exit 0
fi

prompt_file=${1:-"prompt.md"}
prompt=$(cat "$prompt_file")
role=${2:-"user"}
model=${3:-"codegemma"}

# Create the JSON payload
payload=$(jq -n --arg content "$prompt" --arg role "$role" --arg model "$model" '
{
  "model": $model,
  "messages": [
    {
      "role": $role,
      "content": $content
    }
  ],
  "stream": false,
  "options": {
    "num_keep": 5,
    "seed": 42,
    "num_predict": 100,
    "top_k": 20,
    "top_p": 0.9,
    "tfs_z": 0.5,
    "typical_p": 0.7,
    "repeat_last_n": 33,
    "temperature": 0.8,
    "repeat_penalty": 1.2,
    "presence_penalty": 1.5,
    "frequency_penalty": 1.0,
    "mirostat": 1,
    "mirostat_tau": 0.8,
    "mirostat_eta": 0.6,
    "penalize_newline": true,
    "stop": ["\n", "user:"],
    "numa": false,
    "num_ctx": 1024,
    "num_batch": 2,
    "num_gpu": 1,
    "main_gpu": 0,
    "low_vram": false,
    "f16_kv": true,
    "vocab_only": false,
    "use_mmap": true,
    "use_mlock": false,
    "num_thread": 8
  }
}
')

# Send the request to the REST endpoint
response=$(curl -s -X POST \
  http://localhost:11434/api/chat \
  -H 'Content-Type: application/json' \
  -d "$payload")

# Extract the response content
response_content=$(echo "$response" | jq -r '.message.content')

# Write the response to response.md
echo "$response_content" > response.md
