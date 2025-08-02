#!/bin/bash

# Set API endpoint and port
API_ENDPOINT="https://localhost:8080"
API_PORT=8080

# Set API keys and secrets
API_KEY="my_secret_key"
API_SECRET="my_secret_secret"

# Set simulation data
SIMULATION_DATA=("user1:password1" "user2:password2")

# Function to start API service
start_api_service() {
  # Create a temp directory for the API service
  TEMP_DIR=$(mktemp -d)

  # Create a config file for the API service
  CONFIG_FILE="$TEMP_DIR/config.json"
  echo "{\"api_key\":\"$API_KEY\",\"api_secret\":\"$API_SECRET\"}" > $CONFIG_FILE

  # Start the API service
  echo "Starting API service on port $API_PORT..."
  nc -l -p $API_PORT -e "./api_handler.sh" &
}

# Function to handle API requests
api_handler() {
  # Read request data
  REQUEST_METHOD=$1
  REQUEST_DATA=$2

  # Handle different API endpoints
  case $REQUEST_METHOD in
    "GET")
      # Handle GET requests
      if [[ $REQUEST_DATA == *"users"* ]]; then
        echo -e "HTTP/1.1 200 OK\r\n"
        echo -e "Content-Type: application/json\r\n\r\n"
        echo "[{\"username\":\"user1\",\"password\":\"password1\"},{\"username\":\"user2\",\"password\":\"password2\"}]"
      else
        echo -e "HTTP/1.1 404 Not Found\r\n"
      fi
      ;;
    "POST")
      # Handle POST requests
      if [[ $REQUEST_DATA == *"login"* ]]; then
        # Extract credentials from request data
        USERNAME=$(echo $REQUEST_DATA | jq -r '.username')
        PASSWORD=$(echo $REQUEST_DATA | jq -r '.password')

        # Check credentials
        for user in "${SIMULATION_DATA[@]}"; do
          IFS=: read -r username password <<< "$user"
          if [[ $username == $USERNAME && $password == $PASSWORD ]]; then
            echo -e "HTTP/1.1 200 OK\r\n"
            echo -e "Content-Type: application/json\r\n\r\n"
            echo "{\"message\":\"Login successful\"}"
            return
          fi
        done

        echo -e "HTTP/1.1 401 Unauthorized\r\n"
      else
        echo -e "HTTP/1.1 404 Not Found\r\n"
      fi
      ;;
    *)
      echo -e "HTTP/1.1 405 Method Not Allowed\r\n"
      ;;
  esac
}

# Start the API service
start_api_service