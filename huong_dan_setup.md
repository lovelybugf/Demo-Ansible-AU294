# HƯỚNG DẪN CÀI ĐẶT & CẤU HÌNH ANSIBLE TRÊN RHEL 10.2

Tài liệu này hướng dẫn từng bước thiết lập môi trường chạy Ansible và `ansible-navigator` (sử dụng Podman làm container engine) trên máy ảo RHEL 10.2 của bạn, kèm giải thích chi tiết mục đích của từng bước cấu hình.

---

## 1. Kiến trúc môi trường phát triển (Development Workflow)
* **Windows (Máy thật)**: Dùng làm máy trạm viết code (sử dụng VS Code / Antigravity IDE) và lưu trữ mã nguồn cục bộ.
* **GitHub (Trung gian)**: Dùng làm kho lưu trữ trung tâm để đồng bộ hóa mã nguồn giữa máy Windows và máy ảo.
* **RHEL 10.2 VM (Máy ảo)**: Hoạt động như một **Ansible Control Node** (máy chạy lệnh thực tế). Máy ảo này được cài đặt Ansible, các công cụ phát triển và Podman để chạy playbooks.

---

## 2. Các bước cài đặt và cấu hình trên máy ảo RHEL

Đăng nhập vào máy ảo RHEL bằng tài khoản **`ducnam`** (mật khẩu: **`1`**), mở terminal lên và thực hiện tuần tự các bước sau:

### Bước 1: Cài đặt Python 3 Pip và Git
```bash
sudo dnf install -y python3-pip git
```
* **Giải thích**: 
  * `python3-pip`: Trình quản lý gói của Python, cần thiết để cài đặt các công cụ viết code viết bằng Python như `ansible-navigator` và `ansible-lint`.
  * `git`: Dùng để tải mã nguồn dự án từ kho chứa GitHub về máy ảo để thực thi.
  * `sudo`: Sử dụng quyền quản trị tối cao để cài đặt phần mềm vào hệ thống (yêu cầu mật khẩu của tài khoản `ducnam` là `1`).

---

### Bước 2: Cài đặt Ansible Core
```bash
sudo dnf install -y ansible-core
```
* **Giải thích**: 
  * `ansible-core` là nhân thực thi cốt lõi của Ansible. Nó cung cấp các lệnh chạy playbook cơ bản (`ansible-playbook`) và các module lõi của hệ thống (`ansible.builtin`). 
  * Cài đặt qua trình quản lý gói `dnf` giúp hệ thống tự động tối ưu hóa và liên kết với Python của RHEL.

---

### Bước 3: Cài đặt Ansible-Navigator & Ansible-Lint
```bash
pip3 install --user ansible-navigator ansible-lint
```
* **Giải thích**:
  * `ansible-navigator`: Công cụ dòng lệnh hiện đại được Red Hat khuyên dùng để chạy, debug và tương tác với playbook bên trong các Execution Environment (môi trường container).
  * `ansible-lint`: Công cụ tự động quét mã nguồn playbook của bạn để cảnh báo lỗi cú pháp YAML và đề xuất chuẩn viết code (best practices), giúp tránh lỗi thụt lề khoảng trắng.
  * Tùy chọn `--user`: Cài đặt các công cụ này ở cấp độ tài khoản cá nhân của bạn, không ảnh hưởng đến hệ thống chung.

---

### Bước 4: Tải ảnh môi trường thực thi (Execution Environment Image) qua Podman
```bash
podman pull quay.io/ansible/creator-ee:latest
```
* **Giải thích**:
  * `ansible-navigator` chạy playbooks bên trong một container cô lập gọi là Execution Environment (EE). 
  * Image `quay.io/ansible/creator-ee:latest` chứa sẵn đầy đủ các module và thư viện Ansible phổ biến nhất. 
  * Việc tải trước (pull) hình ảnh này giúp lệnh chạy playbook sau này diễn ra lập tức và có thể hoạt động hoàn toàn ngoại tuyến (offline).

---

### Bước 5: Tạo thư mục dự án và viết các Tệp cấu hình mẫu

#### **1. Tạo thư mục làm việc và di chuyển vào:**
```bash
mkdir -p /home/ducnam/ansible
cd /home/ducnam/ansible
```
* **Giải thích**: Tạo một không gian làm việc chuyên biệt cho Ansible để tránh lẫn lộn với các tệp tin khác của người dùng.

#### **2. Tạo tệp cấu hình mặc định `ansible.cfg`:**
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
* **Giải thích các tham số trong `ansible.cfg`**:
  * `inventory = ./inventory`: Định nghĩa tệp lưu trữ danh sách máy chủ đích nằm ngay tại thư mục hiện hành.
  * `host_key_checking = False`: Tắt chế độ xác thực vân tay khóa SSH khi kết nối tới máy chủ mới. Giúp quá trình chạy lab không bị gián đoạn bởi các câu hỏi Yes/No.
  * `become = True`: Tự động nâng quyền quản trị tối cao trên máy đích khi thực thi các tác vụ (như cài phần mềm, cấu hình hệ thống).
  * `become_method = sudo`: Sử dụng cơ chế `sudo` tiêu chuẩn của Linux để leo thang đặc quyền.
  * `become_user = root`: Nâng lên quyền của tài khoản `root`.
  * `become_ask_pass = False`: Không hỏi mật khẩu sudo khi chạy (phù hợp nếu máy đích đã được cấu hình passwordless sudo, nếu máy đích yêu cầu mật khẩu bạn có thể chạy playbook kèm tham số `-K` để nhập mật khẩu thủ công).

#### **3. Tạo tệp cấu hình điều khiển `ansible-navigator.yml`:**
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
* **Giải thích các tham số trong `ansible-navigator.yml`**:
  * `container-engine: podman`: Chỉ định sử dụng **Podman** để chạy container (vì RHEL 10 mặc định sử dụng Podman thay vì Docker).
  * `enabled: true`: Bật tính năng Execution Environment, bắt buộc chạy playbook bên trong container.
  * `image: quay.io/ansible/creator-ee:latest`: Sử dụng tệp ảnh container đã tải ở Bước 4 làm môi trường chạy.
  * `policy: missing`: Chỉ tải lại container từ internet nếu dưới máy ảo chưa có sẵn (giúp tiết kiệm băng thông và chạy nhanh hơn).
  * `mode: stdout`: Xuất kết quả log chạy trực tiếp ra màn hình terminal truyền thống thay vì mở giao diện tương tác dạng bảng vẽ (TUI), giúp dễ dàng copy log và theo dõi lỗi.
  * `enable: false` (ở mục playbook-artifact): Không tự động sinh ra các file log JSON tạm thời sau mỗi lần chạy thành công để tránh làm rác thư mục dự án.

#### **4. Tạo tệp quản lý máy chủ mẫu `inventory`:**
```bash
cat << 'EOF' > inventory
[local]
localhost ansible_connection=local
EOF
```
* **Giải thích**:
  * Khai báo một nhóm máy chủ tên là `[local]` chỉ chứa duy nhất máy `localhost` (chính nó).
  * `ansible_connection=local`: Bảo Ansible chạy lệnh trực tiếp trên máy hiện tại thay vì cố gắng kết nối SSH vào chính nó.

#### **5. Tạo tệp Playbook chạy thử `test_playbook.yml`:**
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
* **Giải thích**:
  * Playbook đơn giản dùng để kiểm tra môi trường. 
  * `become: false`: Ghi đè cấu hình trong `ansible.cfg` để không sử dụng quyền root (vì tác vụ ping và in thông báo không cần quyền quản trị, tránh bị hỏi mật khẩu).
  * `ansible.builtin.ping`: Gửi tín hiệu kiểm tra kết nối nội bộ.
  * `ansible.builtin.debug`: In ra màn hình dòng chữ chúc mừng nếu chạy thành công.

---

## 3. Chạy kiểm tra hệ thống
Để chạy thử nghiệm playbook thông qua môi trường container vừa tạo, sử dụng câu lệnh:
```bash
ansible-navigator run test_playbook.yml
```
* **Giải thích**: Lệnh này sẽ gọi `ansible-navigator`, khởi động một container Podman từ ảnh `creator-ee:latest`, mount thư mục dự án hiện tại vào trong container và thực thi playbook `test_playbook.yml` để kiểm tra.
