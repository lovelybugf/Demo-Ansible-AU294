# Chương 1: Giới thiệu Ansible & Thiết lập Môi trường Phát triển

Chương này cung cấp cái nhìn tổng quan về Ansible, các khái niệm cốt lõi, kiến trúc hệ thống và hướng dẫn chi tiết cách thiết lập môi trường phát triển chuyên nghiệp với VS Code, Podman và AAP (Ansible Automation Platform) 2.5.

---

## 1. Khái niệm và Đặc trưng Cốt lõi của Ansible

### 1.1. Hạ tầng dưới dạng mã (Infrastructure as Code - IaC)
* **IaC** có nghĩa là định nghĩa và mô tả trạng thái mong muốn của hạ tầng hệ thống (máy chủ, mạng, cơ sở dữ liệu) bằng ngôn ngữ tự động hóa mà con người có thể đọc được.
* Với Ansible, mã nguồn được lưu dưới dạng văn bản đơn giản (YAML), cho phép quản lý phiên bản qua Git, xem lịch sử thay đổi và khôi phục cấu hình dễ dàng.
* **Lợi ích**: Giảm thiểu lỗi cấu hình thủ công của con người (Human Error), tăng tính nhất quán và dễ dàng mở rộng quy mô hệ thống.

### 1.2. 3 Đặc tính lớn của Ansible
* **Đơn giản (Simple)**: Sử dụng cú pháp YAML trực quan, dễ đọc, dễ học mà không cần kỹ năng lập trình phức tạp.
* **Mạnh mẽ (Powerful)**: Đảm nhiệm toàn bộ vòng đời ứng dụng bao gồm: cấu hình hệ thống, cài đặt phần mềm, điều phối quy trình (orchestration) và cấu hình thiết bị mạng.
* **Không cần Agent (Agentless)**: Đây là ưu điểm vượt trội nhất. Ansible không yêu cầu cài đặt bất kỳ phần mềm đặc trị (agent) nào trên máy chủ đích (managed host). Nó kết nối qua giao thức tiêu chuẩn như SSH (Linux/UNIX) hoặc WinRM/WinSSH (Windows).

### 1.3. Cơ chế hoạt động Agentless
1. Control Node (máy chạy lệnh) kết nối tới Managed Hosts qua SSH/WinRM.
2. Control Node đẩy các chương trình Python nhỏ gọi là **Modules** sang thư mục tạm thời của máy con.
3. Các module này được thực thi để đưa máy con về trạng thái mong muốn (Desired State).
4. Sau khi hoàn tất, các module này tự động bị xóa sạch khỏi máy con.

---

## 2. Các thành phần và Phiên bản của Ansible

### 2.1. Phân biệt Ansible Core và Ansible Community
Kể từ phiên bản 2.10, Ansible tách thành hai định dạng để giải quyết vấn đề gói cài đặt quá nặng:
* **Ansible Core (`ansible-core`)**: Chứa công cụ chạy lệnh cốt lõi (`ansible`, `ansible-playbook`), runtime engine và bộ module tích hợp cơ bản (`ansible.builtin`).
* **Community Ansible (`ansible`)**: Bao gồm `ansible-core` cộng thêm một lượng lớn các Module và Plug-ins được duy trì bởi cộng đồng doanh nghiệp dưới dạng **Ansible Content Collections**.

### 2.2. Red Hat Ansible Automation Platform (AAP)
* Là giải pháp doanh nghiệp trả phí của Red Hat, tích hợp thêm giao diện quản lý tập trung (Automation Controller - trước đây là Ansible Tower), hệ thống phân quyền (RBAC), quản lý logs tập trung và bảo mật.
* **Tương quan phiên bản**:
  * AAP 2.4 tương ứng với Ansible Core 2.15
  * AAP 2.5 tương ứng với Ansible Core 2.16

---

## 3. Bộ công cụ phát triển Ansible (Ansible Development Tools)

AAP 2.5 tích hợp sẵn các công cụ mạnh mẽ hỗ trợ nhà phát triển:
* **Ansible Lint (`ansible-lint`)**: Công cụ phân tích mã tĩnh, quét các tệp YAML để phát hiện lỗi cú pháp, cảnh báo các tiêu chuẩn code lỗi thời (deprecated) trước khi commit lên Git.
* **Automation Content Navigator (`ansible-navigator`)**: Bộ điều hướng TUI (Text User Interface) trực quan để chạy, debug playbook trực tiếp bên trong các môi trường thực thi container độc lập.
* **Execution Environment Builder (`ansible-builder`)**: Công cụ tự động dựng các Container Image tùy biến chứa sẵn các module, thư viện python cần thiết (được gọi là các Execution Environments - EE).

---

## 4. Thiết lập Môi trường Phát triển trong VS Code

Để tạo môi trường phát triển đồng bộ và chuyên nghiệp:
1. Cài đặt các Extension trên VS Code:
   * **Ansible Extension**: Hỗ trợ tự động gợi ý code (IntelliSense) và tích hợp `ansible-lint`.
   * **Dev Containers Extension**: Cho phép mở toàn bộ thư mục code bên trong một Container chứa sẵn bộ công cụ phát triển AAP 2.5.
2. Cấu hình container engine trong Settings của VS Code:
   * Trỏ `Dev > Containers: Docker Path` thành `podman`.
   * Trỏ `Dev > Containers: Docker Compose Path` thành `podman-compose`.
3. Khởi tạo Dev Container qua VS Code Command Palette: `Ansible: Add Devcontainer` ➡️ Chọn ảnh Downstream RHEL8 (`ansible-dev-tools-rhel8`). Tệp cấu hình sẽ được lưu tại `.devcontainer/podman/devcontainer.json`.
4. Reopen dự án trong Container để bắt đầu phát triển.

---

## 5. Cấu hình Cài đặt Ansible

Có hai tệp cấu hình cực kỳ quan trọng nằm ở thư mục gốc của dự án:

### 5.1. Tệp cấu hình Ansible (`ansible.cfg`)
Thiết lập cách thức Ansible kết nối và tương tác với các máy con. Tệp gồm hai phần chính:

```ini
[defaults]
inventory = ./inventory             # Đường dẫn tới file inventory quản lý IP
remote_user = devops                # User dùng để SSH vào máy con
ask_pass = false                    # Có hỏi mật khẩu SSH hay không (false nếu dùng SSH Key)
host_key_checking = false           # Tắt kiểm tra host key (hữu ích trong môi trường lab)

[privilege_escalation]
become = true                       # Tự động leo thang đặc quyền (sudo)
become_method = ansible.builtin.sudo # Phương thức leo thang (sudo)
become_user = root                  # User đích sau khi leo thang
become_ask_pass = false             # Có hỏi mật khẩu sudo hay không (false nếu đã có NOPASSWD)
```

#### Thứ tự ưu tiên áp dụng của `ansible.cfg`:
Ansible tìm kiếm tệp cấu hình theo thứ tự từ cao xuống thấp và áp dụng tệp đầu tiên tìm thấy:
1. Biến môi trường `$ANSIBLE_CONFIG` (chỉ ra file cấu hình cụ thể).
2. Tệp `ansible.cfg` trong thư mục làm việc hiện tại (Current Directory).
3. Tệp `.ansible.cfg` (tệp ẩn) trong thư mục cá nhân của user (`~/.ansible.cfg`).
4. Tệp mặc định hệ thống `/etc/ansible/ansible.cfg`.

> [!WARNING]
> Tệp cấu hình `ansible.cfg` nằm ở thư mục hiện tại sẽ **bị bỏ qua** nếu thư mục đó cấp quyền ghi công khai cho mọi user (world-writable) để tránh rủi ro bảo mật.

### 5.2. Tệp cấu hình Navigator (`ansible-navigator.yml`)
Cấu hình các tùy chọn chạy cho công cụ `ansible-navigator`:

```yaml
---
ansible-navigator:
  execution-environment:
    container-engine: podman        # Chọn podman để quản lý container
    enabled: true                   # Chạy playbook bên trong Execution Environment
    image: registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel8:latest
    pull:
      policy: missing               # Chỉ pull ảnh nếu máy cục bộ chưa có
  mode: stdout                      # Hiển thị log trực tiếp ra màn hình terminal giống CLI truyền thống
```

#### Thứ tự ưu tiên của `ansible-navigator.yml`:
1. Biến môi trường `$ANSIBLE_NAVIGATOR_CONFIG`.
2. Tệp `ansible-navigator.yml` trong thư mục hiện tại của dự án.
3. Tệp `.ansible-navigator.yml` trong thư mục home (`~/.ansible-navigator.yml`).
