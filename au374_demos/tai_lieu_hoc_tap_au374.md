# GIÁO TRÌNH HỌC TẬP & ÔN THI ANSIBLE NÂNG CAO (RED HAT AU374)
## Hướng Dẫn Lý Thuyết Và Thực Hành Chi Tiết Cho Hệ Thống Red Hat Ansible Automation Platform 2.6

Chào mừng bạn đến với tài liệu ôn tập và thực hành nâng cao dựa trên tài liệu chuẩn của khóa học **Red Hat Advanced Automation with Ansible (AU374 / RH374)**. Tài liệu này được biên soạn chi tiết bằng tiếng Việt để giúp bạn dễ dàng làm chủ các tính năng nâng cao của Ansible Automation Platform 2.6.

---

## MỤC LỤC
1. [Chương 1: Quản Lý Tài Nguyên Dự Án Ansible Bằng Git](#chương-1)
2. [Chương 2: Quản Lý Collections Và Môi Trường Thực Thi (Execution Environments)](#chương-2)
3. [Chương 3: Vận Hành Playbook Trên Automation Controller](#chương-3)
4. [Chương 4: Quản Trị Các Cấu Hình Hệ Thống Với Navigator](#chương-4)
5. [Chương 5: Quản Lý Inventory Và Tổ Chức Biến Nâng Cao](#chương-5)

---

<a name="chương-1"></a>
## CHƯƠNG 1: QUẢN LÝ TÀI NGUYÊN DỰ ÁN ANSIBLE BẰNG GIT

### 1. Ý nghĩa của Git trong Tự động hóa (IaC)
Khi hạ tầng được định nghĩa dưới dạng mã nguồn (**Infrastructure as Code**), dự án Ansible phải được quản lý bằng Hệ thống quản lý phiên bản phân tán (DVCS) như Git để đảm bảo:
* Theo dõi lịch sử thay đổi (Ai sửa cái gì, khi nào, vì sao).
* Khả năng khôi phục (revert) về phiên bản chạy ổn định trước đó.
* Làm việc cộng tác qua mô hình phân nhánh (branching) và phê duyệt mã nguồn (Pull/Merge Requests).

### 2. Cấu hình Git cơ bản cho kỹ sư Ansible
Trước khi làm việc, cần cấu hình thông tin định danh toàn cục:
```bash
git config --global user.name "Peter Shadowman"
git config --global user.email "peter@host.example.com"
```
Để hiển thị trạng thái của thư mục Git trực tiếp trên dấu nhắc dòng lệnh Bash (Terminal), cấu hình file `~/.bashrc`:
```bash
source /usr/share/git-core/contrib/completion/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export PS1='[\u@\h \W$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")]\$ '
```
*Ký hiệu hiển thị:*
* `(branch *)`: Có file đã tracked bị sửa đổi nhưng chưa stage.
* `(branch +)`: Có file sửa đổi đã được stage qua `git add`.
* `(branch %)`: Có file mới (untracked).

### 3. Quy tắc cấu hình `.gitignore` trong dự án Ansible
Không phải tệp tin nào cũng được đẩy lên Git. Các tài nguyên tự động tải về (Collections, Roles) hoặc file log tạm thời **phải** được bỏ qua.
Tệp tin `.gitignore` chuẩn cho dự án Ansible:
```ini
# Bỏ qua toàn bộ role tải về qua Ansible Galaxy
roles/**
# Ngoại trừ tệp khai báo danh sách role cần tải
!roles/requirements.yml

# Bỏ qua các collection tải về cục bộ
collections/*
# Ngoại trừ tệp yêu cầu dependencies
!collections/requirements.yml

# Bỏ qua log chạy tạm của ansible-navigator
*artifact-*.json
*.log
*.retry
.ansible-navigator/
```

---

<a name="chương-2"></a>
## CHƯƠNG 2: QUẢN LÝ COLLECTIONS VÀ MÔ TRƯỜNG THỰC THI (EE)

### 1. Khái niệm Ansible Content Collections
Kể từ phiên bản Ansible 2.10/2.11 trở đi, hầu hết các module đã được tách khỏi lõi `ansible-core` và đóng gói thành các **Collections**.
* **Namespace**: Là phần đầu của tên Collection, đại diện cho nhà phát triển (ví dụ: `ansible`, `redhat`, `community`, `cisco`).
* **FQCN (Fully Qualified Collection Name)**: Cách gọi tên module đầy đủ để tránh xung đột.
  * *Ví dụ*: Viết `ansible.builtin.copy` thay vì `copy`, hoặc `ansible.posix.authorized_key`.

### 2. Quản lý và cài đặt Collections cục bộ
Khi chạy playbook trong container (Execution Environment), Ansible sẽ không đọc được các collections cài trên máy thật Control Node (`~/.ansible/collections`). Do đó, bạn **phải cài collections vào thư mục cục bộ của dự án** (`./collections`).

#### Sử dụng tệp `collections/requirements.yml`:
```yaml
---
collections:
  - name: ansible.posix
    version: 1.6.0
  - name: community.general
    version: 8.1.0
```
#### Câu lệnh cài đặt:
```bash
ansible-galaxy collection install -r collections/requirements.yml -p ./collections/
```

### 3. Tìm nguồn tải Collections từ Automation Hub
Để cấu hình tải collections từ cổng chính thức được hỗ trợ bởi Red Hat (Automation Hub), cấu hình file `ansible.cfg`:
```ini
[galaxy]
server_list = hub_certified, galaxy

[galaxy_server.hub_certified]
url = https://console.redhat.com/api/automation-hub/content/published/
auth_url = https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token = <token_nhan_tu_portal>

[galaxy_server.galaxy]
url = https://galaxy.ansible.com/
```

### 4. Tìm hiểu về Automation Execution Environments (EE)
EE là một **Container Image** đóng gói sẵn:
1. Phiên bản `ansible-core` tối giản.
2. Các Ansible Collections được cài đặt sẵn.
3. Các thư viện Python và gói hệ thống phụ thuộc.
4. Trình chạy `Ansible Runner`.

#### Hai ảnh môi trường thực thi mặc định của Red Hat AAP:
* **ee-minimal-rhel9**: Image siêu nhẹ chỉ chứa duy nhất `ansible.builtin`. Thường dùng làm base image để xây dựng EE tùy chỉnh.
* **ee-supported-rhel9**: Image đầy đủ chứa tất cả các Collection được Red Hat chứng nhận (Certified Collections) và hỗ trợ kỹ thuật.

---

<a name="chương-3"></a>
## CHƯƠNG 3: VẬN HÀNH PLAYBOOK TRÊN AUTOMATION CONTROLLER

### 1. Kiến trúc Automation Controller (AAP 2)
Automation Controller (trước đây là Ansible Tower) tách biệt hoàn toàn giữa:
* **Control Plane (Mặt phẳng điều khiển)**: Lập lịch, quản lý người dùng, RBAC, phân quyền.
* **Execution Plane (Mặt phẳng thực thi)**: Nơi chạy các playbook thực tế thông qua container EE.
* **Automation Mesh**: Mạng lưới liên kết giúp Control Plane phân phối tác vụ đến các Execution Node từ xa thông qua các Hop Node trung gian.

### 2. Các tài nguyên cốt lõi trong Automation Controller
Để chạy một playbook trên giao diện Web AAP, bạn cần cấu hình các tài nguyên sau theo thứ tự:
1. **Credentials (Thông tin xác thực)**:
   * *Machine Credential*: Khóa SSH, mật khẩu, và thông tin leo thang quyền (Become sudo password) để đăng nhập máy đích.
   * *Source Control Credential*: Khóa SSH / Personal Access Token để kéo code từ GitHub/GitLab.
   * *Vault Credential*: Mật khẩu để giải mã các file bí mật dùng Ansible Vault.
2. **Projects**: Chỉ định liên kết tới Repository Git chứa mã nguồn Ansible.
3. **Inventories**: Khai báo danh sách các máy chủ đích (có thể import từ file tĩnh trong project hoặc đồng bộ động từ AWS, Azure, VMware).
4. **Job Templates**: Bản thiết kế cấu hình chạy playbook. Nó kết hợp: **Project + Playbook + Inventory + Credentials + Execution Environment**.

---

<a name="chương-4"></a>
## CHƯƠNG 4: QUẢN TRỊ CÁC CẤU HÌNH HỆ THỐNG VỚI NAVIGATOR

### 1. Truy vấn cấu hình bằng `ansible-navigator config`
Lệnh `ansible-navigator config` hiển thị toàn bộ tham số cấu hình hiện hành của Ansible engine bên trong container.
* **Cột Name**: Tên biến nội bộ của Ansible.
* **Cột Default**: `True` (đang dùng mặc định), `False` (đã bị ghi đè, sẽ hiển thị màu vàng).
* **Cột Source**: Nguồn nạp cấu hình (đường dẫn tới file `ansible.cfg` hoặc hiển thị `env` nếu nạp từ biến môi trường).

#### Các lệnh phụ hữu ích (Stdout Mode):
* `ansible-navigator config dump -m stdout`: Xuất toàn bộ cấu hình hiện tại và giá trị kèm theo.
* `ansible-navigator config view -m stdout`: Hiển thị nội dung tệp `ansible.cfg` đang được áp dụng trực tiếp.

### 2. Cấu hình tệp tin `ansible-navigator.yml`
Tệp này điều khiển hành vi của chính công cụ `ansible-navigator`. Thứ tự quét file cấu hình của navigator:
1. Biến môi trường `ANSIBLE_NAVIGATOR_CONFIG`
2. File `ansible-navigator.yml` tại thư mục hiện tại của dự án.
3. File ẩn `~/.ansible-navigator.yml` tại thư mục Home của user.

#### Khởi tạo file cấu hình mẫu nhanh:
* Tạo file đầy đủ ghi chú: `ansible-navigator settings --sample > sample.yml`
* Tạo file dựa trên cấu hình đang chạy thực tế: `ansible-navigator settings --effective > sample.yml`

---

<a name="chương-5"></a>
## CHƯƠNG 5: QUẢN LÝ INVENTORY VÀ TỔ CHỨC BIẾN NÂNG CAO

### 1. Viết Inventory bằng định dạng YAML
Định dạng YAML trực quan hơn INI, cho phép quản lý cả danh sách máy và danh sách nhóm lồng nhau tại cùng một khu vực.

#### Cú pháp YAML Inventory mẫu:
```yaml
all:
  children:
    mailservers:
      hosts:
        mail1.example.com:   # Tên máy phải kết thúc bằng dấu hai chấm
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
      vars:
        http_port: 8080      # Khai báo biến nhóm tại đây
    ungrouped:               # Các máy không nằm trong nhóm nào phải khai báo tại đây
      hosts:
        notinagroup.example.com:
```

### 2. Quy tắc viết cú pháp YAML an toàn (Tránh lỗi biên dịch)
* **Quy tắc dấu hai chấm**: Nếu chuỗi ký tự chứa dấu hai chấm theo sau là khoảng trắng, bắt buộc phải đặt trong dấu nháy đơn hoặc nháy kép.
  * *Sai*: `title: Ansible: Best Practices`
  * *Đúng*: `title: "Ansible: Best Practices"`
* **Quy tắc biến đứng đầu**: Nếu gán giá trị cho một tham số bằng biến Jinja2 đứng ở đầu dòng, bắt buộc phải bao quanh bằng dấu nháy kép.
  * *Sai*: `name: {{ my_variable }}`
  * *Đúng*: `name: "{{ my_variable }}"`
* **Quy tắc Boolean & Float**: Các giá trị đúng/sai (Boolean) hoặc số thực (Float) không được đặt trong dấu nháy, nếu đặt trong dấu nháy sẽ bị chuyển thành chuỗi (String).
  * `active: true` (Boolean) vs `active: "true"` (String).

### 3. Tổ chức biến chuyên nghiệp (Subdirectory Layout)
Để tránh tệp inventory bị phình to, hãy di chuyển biến ra ngoài:
* Tạo thư mục `group_vars/` và `host_vars/`.
* **Cấp độ nâng cao (Doanh nghiệp)**: Thay vì tạo file `group_vars/webservers.yml`, hãy tạo thư mục `group_vars/webservers/` và chia nhỏ thành các file YAML theo chức năng:
  ```text
  group_vars/
  ├── all/
  │   └── common.yml         # Chứa biến chung (DNS, NTP, Proxy)
  └── webservers/
      ├── firewall.yml       # Biến cấu hình cổng tường lửa
      ├── apache.yml         # Biến cấu hình Apache
      └── ssl.yml            # Biến cấu hình chứng chỉ SSL
  ```
  Ansible sẽ tự động quét toàn bộ thư mục này và gộp (merge) tất cả biến lại khi chạy playbook.

### 4. Quản lý Dynamic Inventories (Inventory động)
Đối với hạ tầng thay đổi liên tục (Cloud AWS, Azure, VMware), ta sử dụng **Inventory Plug-ins** thay thế cho file tĩnh.
* Để kiểm tra danh sách plugin sẵn có trong EE:
  ```bash
  ansible-navigator doc --mode stdout --type inventory --list
  ```
* Xem tài liệu hướng dẫn viết file cấu hình cho một plugin cụ thể:
  ```bash
  ansible-navigator doc --mode stdout --type inventory redhat.satellite.foreman
  ```
* Định dạng file cấu hình cho dynamic inventory luôn là YAML và bắt đầu bằng khai báo FQCN của plugin:
  ```yaml
  plugin: amazon.aws.aws_ec2
  regions:
    - us-east-1
  filters:
    instance-state-name: running
  ```
