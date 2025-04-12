#!/bin/bash

# Function to check if a command is installed
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check if the host is macOS
is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

# Function to install Homebrew
install_brew() {
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ $? -eq 0 ]; then
    echo "Homebrew installed successfully."
    # Update PATH to include Homebrew's bin directory
    eval "$(/opt/homebrew/bin/brew shellenv)" #for apple silicon
    if [ -d /usr/local/bin ]; then #for intel macs
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    if command_exists brew; then
      echo "Brew command available."
    else
      echo "Error: Brew command not available after installation."
      exit 1
    fi
  else
    echo "Error installing Homebrew."
    exit 1
  fi
}

# Function to install MySQL client
install_mysql_client() {
  echo "MySQL client not found. Installing..."
  brew install mysql-client@8.0
  if [ $? -eq 0 ]; then
    echo 'export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"' >> ~/.zshrc
    echo "MySQL client installed successfully."
  else
    echo "Error installing MySQL client."
    exit 1
  fi
}

# Function to test MySQL connection
test_mysql_connection() {
  echo "Testing MySQL connection..."
  mysql -h 127.0.0.1 -P 3306 -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"
  if [ $? -eq 0 ]; then
    echo "Successfully connected to MySQL."
  else
    echo "Failed to connect to MySQL. Check MySQL logs, client installation, and password."
  fi
}

# Main script logic
if is_macos; then
  if ! command_exists brew; then
    install_brew
  fi

  if ! command_exists mysql; then
    install_mysql_client
  fi

  # Proceed to test connection only if mysql client has been installed.
  if command_exists mysql; then
    test_mysql_connection
  fi

else
  echo "This script is designed for macOS. Skipping Homebrew and MySQL client installation."
fi

# Load MySQL Root Password from environment variable
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"default_mysql_password"} #set a default

# Set the container name (optional)
CONTAINER_NAME="mysql-container"

# Set the volume name (optional)
VOLUME_NAME="mysql_data"

# Check if MySQL container is already running
if docker ps -a --filter name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
  echo "MySQL container '$CONTAINER_NAME' already exists."

  if docker ps --filter name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "MySQL container '$CONTAINER_NAME' is running."
  else
    echo "MySQL container '$CONTAINER_NAME' is stopped. Starting it..."
    docker start "$CONTAINER_NAME"
  fi

else
  echo "MySQL container '$CONTAINER_NAME' not found. Creating and starting..."

  # Create volume if it doesn't exist
  if ! docker volume ls --format '{{.Name}}' | grep -q "$VOLUME_NAME"; then
    echo "Creating volume '$VOLUME_NAME'..."
    docker volume create "$VOLUME_NAME"
  fi

  # Run the MySQL container and display logs in real-time
  docker run -d \
    --name "$CONTAINER_NAME" \
    -v "$VOLUME_NAME":/var/lib/mysql \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    --restart unless-stopped \
    mysql:8.0

  if [ $? -eq 0 ]; then
    echo "MySQL container '$CONTAINER_NAME' created and started successfully."
    # Display logs from the container creation process
    echo "Displaying docker logs from container startup:"
    docker logs "$CONTAINER_NAME"
  else
    echo "Error creating MySQL container."
  fi

fi

# Connect to the MySQL server
echo "Attempting to connect to mysql server:"
mysql -h 127.0.0.1 -P 3306 -u root -p -e "SELECT 1"

if [ $? -eq 0 ]; then
  echo "Successfully connected to mysql."
else
  echo "Failed to connect to mysql. Check mysql logs and password."
fi