#!/bin/bash
IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

SAFE_NAME=$(echo "$IMAGE_NAME" | tr '/:' '_')
TAR_PATH="/home/ducnam/${SAFE_NAME}.tar"

echo "=== [1/4] Pulling image: $IMAGE_NAME on Control Plane ==="
podman pull "$IMAGE_NAME"

echo "=== [2/4] Saving image to tarball: $TAR_PATH ==="
podman save "$IMAGE_NAME" -o "$TAR_PATH"

echo "=== [3/4] Copying tarball to target host (172.25.250.20) ==="
scp "$TAR_PATH" ducnam@172.25.250.20:"$TAR_PATH"

echo "=== [4/4] Importing image into containerd (k8s.io namespace) on target host ==="
ssh ducnam@172.25.250.20 "sudo ctr -n k8s.io images import $TAR_PATH"

echo "=== [5/5] Cleaning up temporary tarball files ==="
rm -f "$TAR_PATH"
ssh ducnam@172.25.250.20 "rm -f $TAR_PATH"

echo "=== DONE: Image $IMAGE_NAME is ready on Kubernetes! ==="
