# HƯỚNG DẪN CÀI ĐẶT AWX TRÊN CỤM K8S 2 NODES SẠCH

Tài liệu này hướng dẫn chi tiết từng bước cài đặt AWX trên cụm Kubernetes 2 Nodes (`k8s-master` - `172.25.250.20` và `k8s-worker` - `172.25.250.30`) sạch vừa được thiết lập, sử dụng phân vùng lưu trữ tốc độ cao `/data` NVMe và chạy Calico CNI.

---

## Sơ đồ Quy trình Triển khai

```mermaid
graph TD
    A[Cụm K8s 2 Nodes Sạch: Ready] --> B[Bước 1: Kéo trước các ảnh container để tránh timeout]
    B --> C[Bước 2: Cài đặt StorageClass local-path mặc định]
    C --> D[Bước 3: Triển khai AWX Operator offline]
    D --> E[Bước## Triển khai trực tiếp trên Master Node (Có Internet)

Vui lòng đăng nhập SSH vào máy Master bằng tài khoản `ducnam`:
```bash
ssh ducnam@172.25.250.20
# Mật khẩu: 1
```

---

## Hướng dẫn cài đặt từng bước từ đầu

### Bước 1: Clone repo AWX Operator trực tiếp trên Master VM
Chạy các lệnh sau để tải bộ mã nguồn AWX Operator (phiên bản ổn định `2.19.1`):
```bash
# 1. Xóa thư mục cũ (nếu có) và tải repo từ GitHub
rm -rf /home/ducnam/awx
git clone https://github.com/ansible/awx-operator.git /home/ducnam/awx

# 2. Chuyển vào thư mục và chọn tag 2.19.1
cd /home/ducnam/awx
git checkout tags/2.19.1
```

---

### Bước 2: Tạo các tệp cấu hình triển khai
Chạy các lệnh sau trực tiếp trên Master VM để tạo cấu hình cài đặt tối ưu tài nguyên cho cụm lab:

1. **Tạo tệp `kustomization.yaml`**:
   ```bash
   cat << 'EOF' > kustomization.yaml
   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization
   resources:
     - config/default
     - awx-demo.yml

   images:
     - name: quay.io/ansible/awx-operator
       newTag: 2.19.1
     - name: gcr.io/kubebuilder/kube-rbac-proxy
       newName: registry.k8s.io/kubebuilder/kube-rbac-proxy
       newTag: v0.15.0

   namespace: awx
   EOF
   ```

2. **Tạo tệp `awx-demo.yml`** (Tối ưu tài nguyên RAM/CPU):
   ```bash
   cat << 'EOF' > awx-demo.yml
   ---
   apiVersion: awx.ansible.com/v1beta1
   kind: AWX
   metadata:
     name: awx-demo
   spec:
     service_type: nodeport
     nodeport_port: 32240
     postgres_storage_class: local-path
     web_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
     task_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
     ee_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
     redis_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
     rsyslog_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
     init_container_resource_requirements:
       requests:
         cpu: 10m
         memory: 32Mi
   ...
   EOF
   ```

3. **Tải tệp cài đặt StorageClass cục bộ (`local-path-storage.yaml`)**:
   ```bash
   curl -L -o local-path-storage.yaml https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
   ```

---

### Bước 3: Thiết lập StorageClass mặc định cho cụm K8s
Để cơ sở dữ liệu của AWX tự động cấp phát ổ cứng động:
```bash
# 1. Triển khai Rancher Local Path Storage
kubectl apply -f local-path-storage.yaml

# 2. Thiết lập local-path làm mặc định của cụm
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# 3. Kiểm tra trạng thái StorageClass
kubectl get sc
```
*(Xác nhận sc `local-path` có hậu tố `(default)` bên cạnh).*

---

### Bước 4: Triển khai AWX Operator & Instance
```bash
# 1. Tạo namespace riêng cho AWX
kubectl create namespace awx

# 2. Sử dụng Kustomize để triển khai Operator & Instance
kubectl apply -k .
```

---

### Bước 5: Theo dõi trạng thái và lấy mật khẩu đăng nhập
1. **Theo dõi các Pod khởi chạy**:
   ```bash
   kubectl get pods -n awx -w
   ```
   *Quá trình này sẽ tải các ảnh container từ internet và khởi chạy lần lượt các dịch vụ (`postgres`, `redis`, `web`, `task`).*

2. **Lấy mật khẩu đăng nhập quản trị**:
   ```bash
   kubectl get secret awx-demo-admin-password -n awx -o jsonpath="{.data.password}" | base64 --decode ; echo
   ```

3. **Truy cập Giao diện Web**:
   Mở trình duyệt trên máy Windows và truy cập địa chỉ:
   👉 **URL**: **http://172.25.250.20:32240** (Tài khoản: `admin`).

