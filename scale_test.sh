#!/bin/bash

# Configuration
PROJECT_ID="project-1f436c31-1dda-476d-82b"
ZONE="us-central1-a"

# Function to resize a group
resize_group() {
    local name=$1
    local size=$2
    echo "⚙️ Resizing $name to $size..."
    gcloud compute instance-groups managed resize "$name" \
        --size="$size" \
        --zone="$ZONE" \
        --project="$PROJECT_ID"
}

echo "🚀 Starting Scaling Test..."

# Step 1: Create a Gap
resize_group "learning-group-0" 5
resize_group "learning-group-1" 1
# learning-group-2 stays at 3

echo "⏳ Waiting 90 seconds for VMs to boot/terminate and metrics to update..."
sleep 90

echo "🔄 Resetting all groups to baseline (3)..."
resize_group "learning-group-0" 3
resize_group "learning-group-1" 3
resize_group "learning-group-2" 3

echo "✅ Test complete. Check the dashboard for the spikes!"
