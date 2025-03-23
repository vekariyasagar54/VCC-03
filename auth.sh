#!/bin/bash

# Path to your service account key JSON file
KEY_FILE="gcp-k.json"

# Check if the key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Service account key file not found!"
    exit 1
fi

# Set the environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/$KEY_FILE"

# Authenticate with GCP
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"

# Verify authentication
gcloud auth list

echo "Authentication successful!"
