# CHECKLIST CHUẨN HÓA CỤM K8S 2 NODE & HƯỚNG DẪN VẬN HÀNH BẰNG AWX

Mục tiêu của tài liệu này là xây dựng một **Checklist chuẩn hóa** cho cụm K8s 2 Nodes (`k8s-master` & `k8s-worker`) của bạn và hướng dẫn cách triển khai nó thông qua **AWX** để tối ưu hóa quy trình vận hành tự động (GitOps/Ansible-driven Ops).

---

## 📋 PHẦN 1: Checklist Chuẩn hóa Hạ tầng Cụm K8s 2 Nodes

Để cụm K8s chạy ổn định lâu dài (Day-2 Operations), hạ tầng các Node vật lý/máy ảo cần được chuẩn hóa theo danh sách sau:

### 1. Chuẩn hóa Hệ điều hành & Thư viện (OS & Package)
*   [ ] **Đồng bộ NTP/Timezone**: Đảm bảo cả Master và Worker đồng bộ giờ chính xác tuyệt đối (lệch giờ sẽ làm lỗi các chứng chỉ TLS/SSL của K8s).
*   [ ] **Cập nhật nhân OS & Packages**: Cập nhật định kỳ các bản vá bảo mật của OS (Ubuntu/RHEL) và runtime engine (containerd/docker).
*   [ ] **Giới hạn File Descriptors**: Tối ưu hóa số lượng file mở tối đa (`limits.conf`) cho các Pod K8s chạy tác vụ nặng.

### 2. Chuẩn hóa Bảo mật Node (Security & Hardening)
*   [ ] **Tối ưu Firewall (UFW/Iptables)**: Chỉ mở các cổng mạng K8s cần thiết (6443 cho API, 10250 cho Kubelet, 2379-2380 cho etcd, 30000-32767 cho NodePort).
*   [ ] **Cấu hình SSH an toàn**: Tắt đăng nhập SSH bằng root trực tiếp, chuyển sang dùng SSH Key thay thế cho mật khẩu tĩnh.

### 3. Giám sát & Dọn dẹp Tài nguyên (Maintenance)
*   [ ] **Dọn dẹp Đĩa cứng `/data`**: Theo dõi và dọn dẹp các tệp logs dư thừa của container (containerd/docker logs) để tránh tràn bộ nhớ đĩa làm Node rơi vào trạng thái `DiskPressure`.
*   [ ] **Kiểm tra trạng thái Kubelet**: Đảm bảo service `kubelet` và `containerd` luôn tự động khởi động lại (restart: always) nếu bị lỗi.

### 4. Quản trị Kubernetes (Cluster Management)
*   [ ] **Gia hạn Chứng chỉ K8s (Certificates Rotation)**: Chứng chỉ nội bộ cụm K8s (etcd, apiserver) mặc định hết hạn sau 1 năm. Cần kịch bản tự động gia hạn định kỳ bằng lệnh `kubeadm certs renew`.
*   [ ] **Sao lưu Database etcd (Backup etcd)**: Tự động backup trạng thái cụm (etcd snapshot) mỗi ngày để khôi phục khi có sự cố sập cụm.

---

## 🚀 PHẦN 2: Hướng dẫn Triển khai Checklist này lên AWX

Sau khi đã đẩy dự án [k8s_cluster_ops](file:///e:/ansible/k8s_cluster_ops/) lên GitHub và đồng bộ thành công vào AWX, bạn tiến hành triển khai các tác vụ quản trị cụm qua 4 bước sau:

### 🔌 Bước 2.1: Tạo Thông tin xác thực (Credentials) trong AWX
AWX cần tài khoản SSH để đăng nhập vào 2 máy `.20` và `.30`.
1.  Vào menu **Credentials** trên Web UI ➔ Bấm **Add**.
2.  Điền thông tin:
    *   **Name**: `K8s-SSH-Credential`
    *   **Credential Type**: Chọn **Machine** (Loại thông tin xác thực cho máy chủ).
    *   **Username**: `ducnam`
    *   **Password**: `1` (Mật khẩu SSH của bạn).
    *   **Privilege Escalation Method**: Chọn **sudo** (Đăng nhập quyền root).
    *   **Privilege Escalation Password**: Điền `1` (Mật khẩu chạy lệnh sudo).
3.  Bấm **Save**.

### 🖥️ Bước 2.2: Kiểm tra lại Inventory (Danh sách máy chủ)
1.  Vào menu **Inventories** ➔ Chọn Inventory của bạn (Ví dụ: `cum-k8s-inventory`).
2.  Bấm tab **Hosts** ➔ Đảm bảo đã có đầy đủ 2 host:
    *   `172.25.250.20`
    *   `172.25.250.30`

### 🛠️ Bước 2.3: Tạo các Job Templates (Mẫu công việc chạy kịch bản)
Tạo mẫu để liên kết **Project Git**, **Inventory** và **Credentials** lại với nhau:
1.  Vào menu **Templates** ➔ Bấm **Add** ➔ Chọn **Add job template**.
2.  Thiết lập thông tin cho Template:
    *   **Name**: `K8s - Update OS & System Packages` (Hoặc tác vụ tương ứng).
    *   **Job Type**: `Run`
    *   **Inventory**: Chọn `cum-k8s-inventory`.
    *   **Project**: Chọn `k8s-project` (Dự án GitHub của bạn).
    *   **Execution Environment**: Chọn mặc định `AWX EE` hoặc để trống.
    *   **Playbook**: AWX sẽ tự động quét các file trong repo Git của bạn ➔ Chọn `playbooks/system_update.yml` (hoặc các file playbook bảo trì khác).
    *   **Credentials**: Bấm hình kính lúp ➔ Chọn `K8s-SSH-Credential` (vừa tạo ở bước 2.1).
3.  Bấm **Save**.

*(Làm tương tự cho các playbook khác như: `playbooks/check_k8s_status.yml`, `playbooks/disk_space_cleanup.yml`).*

### 📅 Bước 2.4: Lập lịch chạy Tự động (Schedules)
Đây chính là giá trị cốt lõi của AWX: Tự động chạy bảo trì định kỳ không cần can thiệp thủ công.
1.  Tại Template vừa tạo (ví dụ: `K8s - Clean up Disk space`), bấm sang tab **Schedules** ở thanh menu ngang.
2.  Bấm **Add** để thiết lập lịch:
    *   **Name**: `Hang tuan don dep dia`
    *   **Start Date/Time**: Chọn thời điểm bắt đầu (ví dụ: 0h00 ngày Chủ Nhật tới).
    *   **Local Time Zone**: Asia/Ho_Chi_Minh.
    *   **Repeat Frequency**: Chọn **Weeks** (Lặp lại mỗi tuần).
3.  Bấm **Save**.

---

## 🎯 Kết quả đạt được
Từ nay, cụm K8s của bạn sẽ được bảo trì tự động:
*   Mỗi tuần, AWX tự chạy dọn dẹp đĩa tránh nghẽn cụm.
*   Bạn có thể kiểm tra trạng thái sức khỏe của cụm (CPU/RAM/Kubectl get nodes) trực tiếp từ điện thoại hoặc máy tính thông qua Web UI của AWX chỉ bằng cách bấm nút **Launch** trên Template `check_k8s_status`.
*   Tất cả logs thực thi được AWX lưu trữ tập trung, dễ dàng điều tra lỗi (Audit Logs) khi có sự cố.
