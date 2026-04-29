#!/bin/bash

# 1. Load variables
source "$HOME/.config/nvim/.env"

USER_INPUT="$1"

# 2. CREATE THE JSON SAFELY (The "Senior" way)
# --arg creates a variable inside jq that is automatically escaped
JSON_PAYLOAD=$(jq -n \
  --arg model "$OPENAI_LLM_MODEL" \
  --arg input "$USER_INPUT" \
  '{
  model: $model, 
  messages: [{role: "user", content: $input}]
  }')

# 3. Call the API using the safe payload
RESPONSE=$(curl -s -w "\n%{http_code}" https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$JSON_PAYLOAD")

# 4. Separate body and status
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "$HTTP_BODY" | jq -r '.choices[0].message.content'
else
  echo "ERROR: API returned status $HTTP_STATUS"
  echo "Response: $HTTP_BODY"
  exit 1
fi

