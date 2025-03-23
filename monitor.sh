#!/bin/bash

# GCP Configuration
PROJECT_ID="elite-campus-452409-r6"
ZONE="us-central1-a"
VM_NAME="flask-app-vm-$(date +%s)"  # Unique VM name with timestamp
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
BOOT_DISK_SIZE="20GB"
CPU_THRESHOLD=75    # CPU usage threshold (%)
MEMORY_THRESHOLD=75 # Memory usage threshold (%)

# Function to get overall CPU usage (100 - idle percentage)
get_cpu_usage() {
    mpstat 1 1 | awk '/Average/ {print 100 - $NF}'
}

# Function to get overall memory usage
get_memory_usage() {
    free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}'
}

# Function to create a new GCP VM and deploy the Flask app using the startup script
create_vm() {
    echo "Creating Ubuntu VM: $VM_NAME..."
    gcloud compute instances create "$VM_NAME" \
        --project="$PROJECT_ID" \
        --zone="$ZONE" \
        --machine-type="$MACHINE_TYPE" \
        --image-family="$IMAGE_FAMILY" \
        --image-project="$IMAGE_PROJECT" \
        --boot-disk-size="$BOOT_DISK_SIZE" \
        --tags=http-server,https-server \
        --metadata-from-file startup-script=startup_script.sh \
        --quiet

    echo "Fetching external IP..."
    VM_IP=$(gcloud compute instances list --filter="name=$VM_NAME" --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
    echo "========================================"
    echo "Flask App deployed successfully."
    echo "New VM IP: http://$VM_IP:80"
    echo "========================================"
}

# Monitor system usage continuously
while true; do
    CPU_USAGE=$(get_cpu_usage)
    MEMORY_USAGE=$(get_memory_usage)

    echo "System CPU Usage: ${CPU_USAGE}% | Memory Usage: ${MEMORY_USAGE}%"

    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )) || (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "High system usage detected. Deploying Flask app to a new VM..."
        create_vm
    fi

    sleep 10  # Check every 10 seconds
done
