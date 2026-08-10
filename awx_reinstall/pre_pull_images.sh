#!/bin/bash
# Script tự động kéo trước (pre-pull) 8 ảnh container cần thiết cho AWX trên cả Master và Worker.
# Giúp quá trình cài đặt diễn ra ngay lập tức và tránh lỗi timeout do tải ảnh chậm.

IMAGES=(
  "quay.io/ansible/awx-operator:2.19.1"
  "registry.k8s.io/kubebuilder/kube-rbac-proxy:v0.15.0"
  "docker.io/rancher/local-path-provisioner:v0.0.37"
  "docker.io/library/busybox:latest"
  "docker.io/library/postgres:15"
  "docker.io/library/redis:7"
  "quay.io/ansible/awx:24.6.1"
  "quay.io/ansible/awx-ee:24.6.1"
)

echo "=== Đang thực hiện kéo ảnh trên Node Master (172.25.250.20) ==="
for img in "${IMAGES[@]}"; do
  echo "Pulling $img on Master..."
  sshpass -p 1 ssh -o StrictHostKeyChecking=no ducnam@172.25.250.20 "sudo crictl pull $img"
done

echo "=== Đang thực hiện kéo ảnh trên Node Worker (172.25.250.30) ==="
for img in "${IMAGES[@]}"; do
  echo "Pulling $img on Worker..."
  sshpass -p 1 ssh -o StrictHostKeyChecking=no ducnam@172.25.250.30 "sudo crictl pull $img"
done

echo "=== Đã hoàn thành kéo trước toàn bộ ảnh container cho AWX! ==="
