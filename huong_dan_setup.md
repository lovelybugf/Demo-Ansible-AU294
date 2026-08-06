# HƯỚNG DẪN CÀI ĐẶT & CẤU HÌNH ANSIBLE TRÊN RHEL 10.2

Tài liệu này hướng dẫn từng bước thiết lập môi trường chạy Ansible và `ansible-navigator` (sử dụng Podman làm container engine) trên máy ảo RHEL 10.2 của bạn.

---

## 1. Chuẩn bị
Đăng nhập vào máy ảo RHEL bằng tài khoản **`ducnam`** (mật khẩu: **`1`**), mở terminal lên và thực hiện tuần tự các bước sau.

---

## 2. Các bước cài đặt và cấu hình

### Bước 1: Cài đặt Python 3 Pip và Git
Chạy lệnh sau để cài đặt trình quản lý gói của Python và Git từ kho ứng dụng chính thức:
```bash
sudo dnf install -y python3-pip git
```
*(Hệ thống sẽ yêu cầu nhập mật khẩu sudo của bạn, hãy nhập là `1`)*

---

### Bước 2: Cài đặt Ansible Core
Cài đặt nhân Ansible chính chủ được tối ưu riêng cho hệ điều hành RHEL:
```bash
sudo dnf install -y ansible-core
```

---

### Bước 3: Cài đặt Ansible-Navigator & Ansible-Lint
Cài đặt các công cụ phát triển và hỗ trợ viết code thông qua Pip ở cấp độ tài khoản cá nhân:
```bash
pip3 install --user ansible-navigator ansible-lint
```
*Sau khi cài xong, bạn có thể kiểm tra bằng lệnh `ansible-navigator --version` để chắc chắn lệnh hoạt động.*

---

### Bước 4: Tải hình ảnh môi trường thực thi (Execution Environment Image) qua Podman
Tải ảnh container chứa sẵn các thư viện/collection của Ansible để dùng offline:
```bash
podman pull quay.io/ansible/creator-ee:latest
```
*(Quá trình này có thể mất từ 1 - 3 phút tùy tốc độ mạng internet).*

---

### Bước 5: Tạo thư mục dự án và viết các Tệp cấu hình mẫu
Chạy lần lượt các nhóm lệnh dưới đây để tạo thư mục `~/ansible` và ghi nội dung cho các tệp cấu hình:

#### **1. Tạo thư mục làm việc:**
```bash
mkdir -p /home/ducnam/ansible
cd /home/ducnam/ansible
```

#### **2. Tạo tệp cấu hình Ansible `ansible.cfg`:**
```bash
cat << 'EOF' > ansible.cfg
[defaults]
inventory = ./inventory
host_key_checking = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
```

#### **3. Tạo tệp cấu hình Ansible-Navigator `ansible-navigator.yml`:**
```bash
cat << 'EOF' > ansible-navigator.yml
---
ansible-navigator:
  execution-environment:
    container-engine: podman
    enabled: true
    image: quay.io/ansible/creator-ee:latest
    pull:
      policy: missing
  mode: stdout
  playbook-artifact:
    enable: false
EOF
```

#### **4. Tạo tệp inventory mẫu:**
```bash
cat << 'EOF' > inventory
[local]
localhost ansible_connection=local
EOF
```

#### **5. Tạo tệp Playbook chạy thử nghiệm `test_playbook.yml`:**
```bash
cat << 'EOF' > test_playbook.yml
---
- name: Test Playbook - Verify Ansible Setup
  hosts: localhost
  gather_facts: false
  become: false
  tasks:
    - name: Ping localhost
      ansible.builtin.ping:

    - name: Print welcome and setup success message
      ansible.builtin.debug:
        msg: "Chúc mừng! Môi trường Ansible của bạn đã hoạt động chính xác."
EOF
```

---

### Bước 6: Chạy kiểm tra hệ thống
Để kiểm tra xem mọi thứ đã được cấu hình chính xác hay chưa, hãy chạy lệnh:
```bash
ansible-navigator run test_playbook.yml
```

Nếu màn hình hiển thị kết quả có dòng chữ: `"msg": "Chúc mừng! Môi trường Ansible của bạn đã hoạt động chính xác."` và cột `failed=0`, có nghĩa là bạn đã tự thiết lập môi trường Ansible thành công 100%!
