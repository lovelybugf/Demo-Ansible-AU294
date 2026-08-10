#!/bin/bash
# Script này được chạy để cấu hình swap và cấu hình kubelet trên cả 2 máy ảo qua SSH từ Control Node.

echo "=== Kích hoạt Swap và Cấu hình Kubelet trên Master (172.25.250.20) ==="
sshpass -p 1 ssh -o StrictHostKeyChecking=no ducnam@172.25.250.20 "
  echo '1' | sudo -S fallocate -l 2G /data/swapfile || echo '1' | sudo -S dd if=/dev/zero of=/data/swapfile bs=1M count=2048
  echo '1' | sudo -S chmod 600 /data/swapfile
  echo '1' | sudo -S mkswap /data/swapfile
  echo '1' | sudo -S swapon /data/swapfile
  if ! grep -q '/data/swapfile' /etc/fstab; then
    echo '/data/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
  fi
  if ! grep -q 'failOnSwap' /var/lib/kubelet/config.yaml; then
    echo 'failOnSwap: false' | sudo tee -a /var/lib/kubelet/config.yaml
  fi
  echo 'KUBELET_KUBEADM_ARGS=\"--fail-swap-on=false\"' | sudo tee /var/lib/kubelet/kubeadm-flags.env
  echo '1' | sudo -S systemctl restart kubelet
"

echo "=== Kích hoạt Swap và Cấu hình Kubelet trên Worker (172.25.250.30) ==="
sshpass -p 1 ssh -o StrictHostKeyChecking=no ducnam@172.25.250.30 "
  echo '1' | sudo -S fallocate -l 4G /data/swapfile || echo '1' | sudo -S dd if=/dev/zero of=/data/swapfile bs=1M count=4096
  echo '1' | sudo -S chmod 600 /data/swapfile
  echo '1' | sudo -S mkswap /data/swapfile
  echo '1' | sudo -S swapon /data/swapfile
  if ! grep -q '/data/swapfile' /etc/fstab; then
    echo '/data/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
  fi
  if ! grep -q 'failOnSwap' /var/lib/kubelet/config.yaml; then
    echo 'failOnSwap: false' | sudo tee -a /var/lib/kubelet/config.yaml
  fi
  echo 'KUBELET_KUBEADM_ARGS=\"--fail-swap-on=false\"' | sudo tee /var/lib/kubelet/kubeadm-flags.env
  echo '1' | sudo -S systemctl restart kubelet
"

echo "=== Đã hoàn thành cấu hình Swap & Kubelet. Vui lòng kiểm tra trạng thái cụm K8s bằng lệnh kubectl get nodes ==="
