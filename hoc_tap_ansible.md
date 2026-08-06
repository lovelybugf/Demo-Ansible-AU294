# HƯỚNG DẪN HỌC & THỰC HÀNH TOÀN DIỆN ANSIBLE (CHUẨN RED HAT AU294 / RH294)

Tài liệu này được tổng hợp từ toàn bộ kho tài liệu học tập của bạn bao gồm 8 Chương lý thuyết và 4 Bài Lab thực hành tổng hợp của chương trình đào tạo **Red Hat Linux Automation with Ansible**.

---

## PHẦN I: BẢN ĐỒ LÝ THUYẾT CHI TIẾT (TÓM TẮT & ỨNG DỤNG TỪ CHƯƠNG 1 - 8)

### Chương 1 & 2: Khởi đầu với Ansible & Cấu trúc Dự án
* **Lý thuyết chi tiết**:
  Ansible hoạt động theo cơ chế **agentless** (không tác nhân), nghĩa là bạn không cần cài đặt bất kỳ phần mềm agent nào trên các máy đích cần quản lý. Máy chạy lệnh (**Control Node**) sẽ kết nối, đẩy và thực thi các chương trình nhỏ dạng Python (các **modules**) trên các máy con (**Managed Hosts**) thông qua giao thức kết nối tiêu chuẩn SSH (đối với Linux) hoặc WinRM (đối với Windows). Để đảm bảo môi trường thực thi luôn nhất quán, Red Hat sử dụng **Execution Environment (EE)** - một container cô lập chạy qua Podman chứa đầy đủ các module và collection cần thiết.
* **Kiến thức chủ chốt**:
  * `ansible.cfg`: File cấu hình mặc định quy định hành vi chạy của Ansible (ví dụ: tắt kiểm tra SSH host key `host_key_checking = False`, tự động leo thang quyền `become = True`).
  * `ansible-navigator.yml`: File cấu hình điều khiển cho công cụ `ansible-navigator`, chỉ định container engine (`podman`), image chạy (`quay.io/ansible/creator-ee:latest`), và chế độ xuất log ra màn hình (`mode: stdout`).
  * `inventory`: Tệp quản lý danh sách IP hoặc hostname của các máy đích. Hỗ trợ chia nhóm (`[dev]`), định nghĩa biến cụ thể cho nhóm (`[dev:vars]`), nhóm lồng nhóm (`[web:children]`), và khai báo phạm vi dải IP viết tắt (`192.168.1.[1:50]`).
  * Cú pháp YAML: Định dạng Playbook nghiêm ngặt thụt lề bằng khoảng trắng (spaces), tuyệt đối không dùng phím Tab. Bắt đầu file bằng `---` và kết thúc bằng `...`.
* **Ứng dụng cụ thể trong bài Lab**:
  * Được sử dụng trực tiếp để ping và verify môi trường thông qua tệp [test_playbook.yml](file:///d:/Demo-Ansible-AU294/test_playbook.yml).
  * File [inventory](file:///d:/Demo-Ansible-AU294/inventory) được dùng trong **LAB 1** để xác lập môi trường kiểm thử `[dev]` và `[local]`.
  * Các file cấu hình [ansible.cfg](file:///d:/Demo-Ansible-AU294/ansible.cfg) và [ansible-navigator.yml](file:///d:/Demo-Ansible-AU294/ansible-navigator.yml) được dùng xuyên suốt tất cả các bài Lab 1, 2, 3, 4 để tự động nâng quyền root (`become = True`) mà không cần truyền tham số thủ công.

### Chương 3: Biến (Variables), Facts & Ansible Vault
* **Lý thuyết chi tiết**:
  * **Biến (Variables)**: Cho phép tham số hóa cấu hình, làm cho playbook có thể tái sử dụng trên nhiều môi trường (dev, staging, prod) mà không cần viết lại logic. Độ ưu tiên của biến (Variable Precedence) rất quan trọng: biến khai báo trực tiếp qua CLI `-e` là cao nhất, tiếp theo là trong playbook (`vars:`/`vars_files:`), thư mục đặc biệt `group_vars/` và `host_vars/`, và thấp nhất là các biến mặc định trong Role (`defaults/`).
  * **Facts**: Dữ liệu cấu hình thời gian thực (real-time) của máy đích do Ansible tự động quét và thu thập thông qua module `ansible.builtin.setup` ở đầu mỗi play.
  * **Ansible Vault**: Công cụ dùng để mã hóa đối xứng AES-256 đối với các dữ liệu nhạy cảm (mật khẩu, SSH key, token API) để có thể lưu trữ an toàn trên Git.
* **Kiến thức chủ chốt**:
  * Cú pháp Jinja2 gọi biến: `{{ ten_bien }}` (nếu biến đứng đầu giá trị cấu hình, bắt buộc phải bao quanh bằng dấu nháy kép `""`).
  * Cú pháp gọi Facts hệ thống: `ansible_facts['hostname']`, `ansible_facts['swapfree_mb']`, `ansible_facts['fqdn']`.
  * Lệnh Ansible Vault:
    * Mã hóa file: `ansible-vault encrypt <ten_file.yml>`
    * Giải mã file: `ansible-vault decrypt <ten_file.yml>`
    * Xem nội dung file mã hóa: `ansible-vault view <ten_file.yml>`
    * Chạy playbook giải mã nóng: `ansible-navigator run playbook.yml --ask-vault-pass`
* **Ứng dụng cụ thể trong bài Lab**:
  * Trong **LAB 1**: Sử dụng fact `ansible_facts['swapfree_mb']` để kiểm tra điều kiện bộ nhớ swap của máy chủ trước khi quyết định có cài đặt package `php` hay không.
  * Trong **LAB 2**: Template Jinja2 `vhost.conf.j2` gọi trực tiếp `ansible_facts['fqdn']` và `ansible_facts['hostname']` để cấu hình động tên miền và thư mục gốc của trang web tùy theo máy đích.
  * Trong **LAB 3**: Sử dụng `ansible-vault` mã hóa mật khẩu băm của user trong tệp `pass-vault.yml`, sau đó nạp tệp này vào playbook `dev-users.yml` để tạo người dùng hệ thống một cách bảo mật.

### Chương 4: Điều khiển Tác vụ (Task Control)
* **Lý thuyết chi tiết**:
  * **Loop**: Vòng lặp chạy một tác vụ nhiều lần với các tham số đầu vào khác nhau, giúp tối ưu hóa kích thước playbook và dễ quản lý.
  * **When**: Câu lệnh điều kiện kiểm tra tính đúng đắn trước khi thực thi tác vụ. Thường kết hợp với các biến hoặc Facts hệ thống.
  * **Handlers & Notify**: Trình xử lý sự kiện. Handlers là các tác vụ đặc biệt (thường là reload/restart dịch vụ) được định nghĩa riêng. Chúng chỉ chạy khi và chỉ khi có một tác vụ chính báo cáo trạng thái thay đổi (`changed`) và gửi tín hiệu thông báo `notify`. Nếu tác vụ chính không thay đổi gì (`ok`), handler sẽ tự động bị bỏ qua để tránh lãng phí tài nguyên.
  * **Block, Rescue & Always**: Gom nhóm các tác vụ và bẫy lỗi (giống try-catch-finally). Khối `block` chứa các tác vụ chính, khối `rescue` chỉ chạy khi các tác vụ trong `block` bị lỗi (dùng để rollback, ghi log lỗi), và khối `always` luôn luôn chạy bất kể thành công hay thất bại.
* **Kiến thức chủ chốt**:
  * Cú pháp vòng lặp: `loop: "{{ list_items }}"` với biến lặp mặc định là `{{ item }}`.
  * Cú pháp điều kiện: `when: bien_kiem_tra == "gia_tri"` hoặc kết hợp nhiều điều kiện bằng logic `and`, `or`.
  * Khai báo handler trong mục `handlers:` ở cuối Playbook, liên kết qua `notify: <Tên Handler giống hệt tên khai báo>`.
  * Cú pháp bẫy lỗi:
    ```yaml
    block:
      - name: Tac vu chinh
        ansible.builtin.uri: ...
    rescue:
      - name: Ghi log khi that bai
        ansible.builtin.copy: ...
    ```
* **Ứng dụng cụ thể trong bài Lab**:
  * Trong **LAB 1**: Sử dụng `loop` để tạo nhanh hàng loạt người dùng (`joe`, `sam`), và dùng `when` để kiểm tra điều kiện swap trước khi cài đặt gói `php`.
  * Trong **LAB 2**: Sử dụng `notify: Restart HTTPD Service` để chỉ khởi động lại Apache khi tệp cấu hình Virtual Host (`vhost.conf`) có sự thay đổi nội dung.
  * Trong **LAB 2**: Sử dụng cấu trúc `block` để kiểm tra truy cập HTTP, và dùng `rescue` để ghi log lỗi chi tiết ra file `error.log` nếu trang web không phản hồi.

### Chương 5: Quản lý & Triển khai Tệp tin (File Deployment)
* **Lý thuyết chi tiết**:
  Quản lý cấu hình tệp tin là trọng tâm của tự động hóa hệ thống. Ansible hỗ trợ quản lý tệp tin tĩnh (copy trực tiếp nguyên bản) và tệp tin cấu hình động (Jinja2 templates). Jinja2 cho phép nhúng logic lập trình (vòng lặp `for`, điều kiện `if`, bộ lọc filter) vào trong tệp cấu hình nguồn `.j2`. Khi chạy, Ansible sẽ tự biên dịch, thay thế biến và ghi đè tệp tin cấu hình hoàn chỉnh lên máy đích.
* **Kiến thức chủ chốt**:
  * `ansible.builtin.file`: Quản lý thư mục, tệp tin và liên kết (`state: directory/file/link`, cấu hình quyền `mode: '0755'`, owner, group).
  * `ansible.builtin.copy`: Sao chép file tĩnh từ Control Node lên máy đích, hoặc đẩy nội dung trực tiếp qua thuộc tính `content`.
  * `ansible.builtin.lineinfile`: Tìm kiếm và chèn/sửa/xóa một dòng cụ thể trong tệp tin (thường cấu hình nhanh thông số hệ thống).
  * `ansible.builtin.template`: Biên dịch tệp template nguồn `.j2` chứa mã Jinja2 thành file cấu hình thực tế trên máy đích.
* **Ứng dụng cụ thể trong bài Lab**:
  * Trong **LAB 2**: Sử dụng `ansible.builtin.file` tạo thư mục DocumentRoot, dùng `ansible.builtin.copy` tạo trang index.html mặc định.
  * Trong **LAB 2**: Sử dụng `ansible.builtin.template` đẩy file cấu hình Apache dynamic vhost từ `vhost.conf.j2` lên máy đích, giúp ánh xạ chính xác thông số FQDN và Hostname của từng máy đích.
  * Trong **LAB 3**: Sử dụng `ansible.builtin.copy` với thuộc tính `validate: /usr/sbin/visudo -cf %s` để kiểm tra cú pháp file cấu hình sudo trước khi lưu đè lên hệ thống, đảm bảo không làm hỏng cấu hình leo thang đặc quyền của hệ điều hành.

### Chương 6: Vận hành Ansible ở quy mô lớn (AAP & Execution Environments)
* **Lý thuyết chi tiết**:
  Khi số lượng kỹ sư vận hành tăng lên, việc đảm bảo mọi Control Node (máy cá nhân, máy ảo kiểm thử, máy chủ staging) có cùng phiên bản Ansible Core, phiên bản Python và các Ansible Collections đi kèm là cực kỳ khó khăn. Để giải quyết vấn đề này, Red Hat giới thiệu **Automation Execution Environments (EE)** - là các Container Image đóng gói sẵn toàn bộ môi trường chạy chuẩn hóa. Kỹ sư chỉ cần dùng `ansible-navigator` để chạy playbook bên trong container cô lập đó, đảm bảo tính đồng bộ tuyệt đối từ môi trường phát triển (Dev) lên môi trường sản xuất (Prod).
* **Kiến thức chủ chốt**:
  * Sử dụng Container Engine là `podman` (mặc định trên RHEL) hoặc `docker`.
  * Định nghĩa tệp ảnh chạy trong [ansible-navigator.yml](file:///d:/Demo-Ansible-AU294/ansible-navigator.yml): `image: quay.io/ansible/creator-ee:latest` và thiết lập chính sách kéo ảnh `pull: policy: missing` để tăng tốc độ khởi chạy.
* **Ứng dụng cụ thể trong bài Lab**:
  * Được tích hợp sẵn xuyên suốt toàn bộ dự án qua tệp cấu hình [ansible-navigator.yml](file:///d:/Demo-Ansible-AU294/ansible-navigator.yml). Khi bạn chạy bất kỳ lệnh thực thi nào (như `ansible-navigator run site.yml`), hệ thống sẽ tự động tạo container Podman từ image `creator-ee`, mount thư mục dự án hiện tại vào thư mục `/workspaces/` trong container và thực hiện chạy cô lập playbook để tránh xung đột hệ thống.

### Chương 7: Tái sử dụng code với Ansible Roles
* **Lý thuyết chi tiết**:
  Khi viết playbook quy mô lớn, việc nhét hàng trăm task và biến vào một tệp duy nhất sẽ gây khó khăn lớn cho việc bảo trì. **Ansible Roles** cung cấp một giải pháp tổ chức mã nguồn có cấu trúc thư mục chuẩn hóa. Role cho phép chia nhỏ playbook lớn thành các thành phần con hoạt động độc lập (tasks, handlers, defaults, vars, files, templates), giúp dễ dàng chia sẻ qua Ansible Galaxy hoặc tái sử dụng trong nhiều dự án khác nhau.
* **Kiến thức chủ chốt**:
  * Lệnh sinh cấu trúc Role tự động: `ansible-galaxy role init roles/<ten_role>`.
  * Cấu trúc thư mục của một Role chuẩn:
    * `tasks/main.yml`: Logic thực thi chính của Role.
    * `defaults/main.yml`: Khai báo các biến mặc định (độ ưu tiên thấp nhất, dễ ghi đè).
    * `vars/main.yml`: Khai báo các biến cố định của Role (độ ưu tiên cao).
    * `templates/`: Nơi chứa các file template Jinja2.
    * `files/`: Nơi chứa các file tĩnh cần copy.
    * `handlers/main.yml`: Nơi khai báo handler xử lý sự kiện trong Role.
  * Cách nhúng Role vào playbook chính: sử dụng từ khóa `roles:` ở cấp độ Play.
* **Ứng dụng cụ thể trong bài Lab**:
  * Trong **LAB 4**: Thực hành chuyển đổi toàn bộ playbook triển khai web Apache cồng kềnh thành một Role cấu trúc chuẩn `ansible-httpd` và gọi gọn gàng thông qua tệp playbook chính `site.yml` (hoặc playbook tổng hợp).

### Chương 8: Tự động hóa Tác vụ Quản trị Linux
* **Lý thuyết chi tiết**:
  Ansible cung cấp các module hệ thống mạnh mẽ để quản trị cấu hình hệ điều hành Linux (như tạo phân vùng đĩa cứng LVM, cấu hình tường lửa firewalld, lập lịch cron, phân quyền người dùng). Đặc biệt, Red Hat cung cấp bộ **Red Hat System Roles** (`redhat.rhel_system_roles`) - là tập hợp các Role được viết sẵn, tối ưu hóa và kiểm thử nghiêm ngặt bởi Red Hat nhằm tự động hóa cấu hình chuẩn các dịch vụ hệ thống phức tạp trên RHEL mà không cần tự viết playbook từ đầu.
* **Kiến thức chủ chốt**:
  * `ansible.builtin.cron`: Lập lịch tự động chạy tác vụ hệ thống (thay thế việc sửa crontab thủ công).
  * `ansible.builtin.systemd_service`: Quản lý trạng thái bật/tắt/khởi động lại các dịch vụ hệ thống chạy bằng systemd.
  * System Roles phổ biến: `rhel-system-roles.storage` (quản lý phân đĩa LVM), `rhel-system-roles.firewall` (cấu hình tường lửa), `rhel-system-roles.network` (cấu hình card mạng).
* **Ứng dụng cụ thể trong bài Lab**:
  * Trong **LAB 3**: Sử dụng module `ansible.builtin.cron` cấu hình tự động lập lịch chạy tác vụ `logrotate` định kỳ vào lúc 0 giờ 0 phút mỗi ngày cho database server để tự động hóa nén và dọn dẹp log db.
  * Sử dụng các module `ansible.builtin.user`, `ansible.builtin.group` cấu hình và phân quyền nhóm sudoers cho người dùng `developer`.

---

## PHẦN II: HƯỚNG DẪN THỰC HÀNH 4 BÀI LAB TỔNG HỢP (COMPREHENSIVE REVIEWS)

Dưới đây là đặc tả yêu cầu và mã nguồn mẫu cho 4 bài Lab lớn trong tài liệu học tập của bạn, được tối ưu hóa để chạy trực tiếp trên máy ảo RHEL của bạn.

---

### LAB 1: Triển khai Ansible, Quản lý User và Package
* **Mục tiêu**: Thiết lập tệp cấu hình, quản lý user (`joe`, `sam`), cài đặt dịch vụ và sử dụng câu điều kiện.

#### **1. Tạo tệp Inventory (`/home/ducnam/ansible/inventory`):**
```ini
[dev]
# Trong bài lab của Red Hat dùng servera và serverb. Bạn có thể trỏ thẳng vào IP máy ảo RHEL của bạn hoặc localhost
localhost ansible_connection=local
```

#### **2. Playbook Quản lý User (`users.yml`):**
Tạo và cấu hình người dùng hệ thống.
```yaml
---
- name: Lab 1 - Quan ly Users joe va sam
  hosts: dev
  become: true
  tasks:
    - name: Dam bao user joe va sam ton tai tren cac may chu
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
      loop:
        - joe
        - sam
```

#### **3. Playbook Quản lý Gói và Điều kiện (`packages.yml`):**
Cài đặt phần mềm bằng biến danh sách (`loop`) và cài đặt có điều kiện (`when`) dựa trên dung lượng bộ nhớ Swap (Facts).
```yaml
---
- name: Lab 1 - Quan ly Package va cau dieu kien
  hosts: dev
  become: true
  vars:
    # Danh sach cac goi can cai dat
    packages:
      - httpd
      - mariadb-server
  tasks:
    - name: Cai dat cac goi phan mem trong danh sach
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop: "{{ packages }}"

    - name: Cai dat php neu swap space cua may lon hon 10 MB
      ansible.builtin.dnf:
        name: php
        state: present
      # ansible_facts['swapfree_mb'] lay dung luong swap trong thuc te
      when: ansible_facts['swapfree_mb'] | default(0) > 10
```
* **Lệnh chạy**: `ansible-navigator run users.yml` và `ansible-navigator run packages.yml`

---

### LAB 2: Tạo Playbook nâng cao với Template, Handler & Xử lý lỗi
* **Mục tiêu**: Deploy dịch vụ web Apache bằng Jinja2 template, cấu hình handler tự động restart dịch vụ và sử dụng khối `block/rescue` để ghi log lỗi khi gọi API/Web thất bại.

#### **1. Tạo file cấu hình vhost ảo Jinja2 (`templates/vhost.conf.j2`):**
```jinja2
# {{ ansible_managed }}
<VirtualHost *:80>
    ServerAdmin webmaster@{{ ansible_facts['fqdn'] }}
    DocumentRoot /var/www/vhosts/{{ ansible_facts['hostname'] }}
    ServerName {{ ansible_facts['fqdn'] }}
</VirtualHost>
```

#### **2. Playbook triển khai Web Server (`dev_deploy.yml`):**
```yaml
---
- name: Lab 2 - Trien khai may chu Web
  hosts: dev
  become: true
  tasks:
    - name: Dam bao thu muc DocumentRoot ton tai
      ansible.builtin.file:
        path: "/var/www/vhosts/{{ ansible_facts['hostname'] }}"
        state: directory
        mode: '0755'

    - name: Copy file index.html
      ansible.builtin.copy:
        content: "Welcome to {{ ansible_facts['fqdn'] }} website!\n"
        dest: "/var/www/vhosts/{{ ansible_facts['hostname'] }}/index.html"
        mode: '0644'

    - name: Day file cau hinh vhost tu Jinja2 Template
      ansible.builtin.template:
        src: templates/vhost.conf.j2
        dest: /etc/httpd/conf.d/vhost.conf
        mode: '0644'
      notify: Restart HTTPD Service  # Goi handler neu file co su thay doi

  handlers:
    - name: Restart HTTPD Service
      ansible.builtin.systemd_service:
        name: httpd
        state: restarted
```

#### **3. Playbook kiểm tra kết nối sử dụng Block & Rescue (`get_web_content.yml`):**
```yaml
---
- name: Lab 2 - Kiem tra noi dung web va xu ly loi
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Khoi block kiem tra ket noi va ghi loi
      block:
        - name: Truy cap thu nghiem trang web
          ansible.builtin.uri:
            url: http://localhost
            return_content: true
          register: content # Luu ket qua tra ve vao bien content

      rescue:
        - name: Ghi log loi ra file neu truy cap that bai
          ansible.builtin.copy:
            content: "Truy cap website that bai! Chi tiet loi: {{ content | to_nice_json }}\n"
            dest: /home/ducnam/ansible/error.log
            mode: '0644'
```
* **Lệnh chạy**: Tạo tệp `site.yml` chứa liên kết import hai tệp trên và thực thi:
  ```yaml
  ---
  - import_playbook: dev_deploy.yml
  - import_playbook: get_web_content.yml
  ```
  Chạy lệnh: `ansible-navigator run site.yml`

---

### LAB 3: Quản trị hệ thống (LVM Storage, Vault & Cron)
* **Mục tiêu**: Sử dụng System Roles cấu hình ổ đĩa LVM, tạo user bảo mật bằng mật khẩu mã hóa Ansible Vault, và cấu hình lịch chạy hệ thống.

#### **1. Tạo tệp mật khẩu mã hóa Vault (`pass-vault.yml`):**
Tạo file chứa mật khẩu băm của developer:
```yaml
user_password_hash: "$6$rounds=656000$randomsalt$HjH9g7G8yHj9..."
```
Mã hóa file bằng mật khẩu Vault (ví dụ mật khẩu là `redhat`):
```bash
ansible-vault encrypt pass-vault.yml
```

#### **2. Playbook Quản lý User leo thang đặc quyền (`dev-users.yml`):**
```yaml
---
- name: Lab 3 - Them nguoi dung developer va cau hinh sudo
  hosts: dev
  become: true
  vars_files:
    - pass-vault.yml # Nap file mat khau ma hoa
  tasks:
    - name: Dam bao group dev ton tai
      ansible.builtin.group:
        name: dev
        state: present

    - name: Tao nguoi dung developer
      ansible.builtin.user:
        name: developer
        password: "{{ user_password_hash }}"
        groups: dev
        append: true
        state: present

    - name: Cau hinh sudo khong mat khau cho group dev
      ansible.builtin.copy:
        content: "%dev ALL=(ALL) NOPASSWD: ALL\n"
        dest: /etc/sudoers.d/dev
        validate: /usr/sbin/visudo -cf %s # Xac thuc cú phap sudoers truoc khi ghi de
```

#### **3. Playbook lên lịch Cron Job tự động hóa (`log-rotate.yml`):**
```yaml
---
- name: Lab 3 - Lên lich chay logrotate vao nua dem
  hosts: dev
  become: true
  tasks:
    - name: Tao lich cron de rotate database logs
      ansible.builtin.cron:
        name: "Rotate database server logs"
        cron_file: rotate_db
        user: ducnam
        minute: "0"
        hour: "0"
        job: "logrotate -f /etc/logrotate.d/dbserver"
```
* **Lệnh chạy**: `ansible-navigator run dev-users.yml --vault-password-file = <file>` hoặc chạy trực tiếp và nhập mật khẩu khi được hỏi:
  ```bash
  ansible-navigator run dev-users.yml --ask-vault-pass
  ```

---

### LAB 4: Chuyển đổi Playbook thành Role tái sử dụng (Modularity)
* **Mục tiêu**: Tổ chức lại một Playbook cài đặt dịch vụ HTTPD cồng kềnh thành một Role cấu trúc chuẩn `ansible-httpd` có thể tái sử dụng.

#### **1. Tạo cấu trúc thư mục Role bằng lệnh `ansible-galaxy`:**
Di chuyển vào thư mục dự án và chạy:
```bash
mkdir -p roles
ansible-galaxy role init roles/ansible-httpd
```
Lệnh này sẽ sinh ra cấu trúc thư mục chuẩn:
```text
roles/ansible-httpd/
├── defaults/       # Khai bao bien mac dinh (main.yml)
├── files/          # Chua cac file tinh (nhu index.html)
├── handlers/       # Chua cac handler xu ly su kien (main.yml)
├── meta/           # Thong tin metadata ve role (main.yml)
├── tasks/          # Tap hop cac tac vu chinh (main.yml)
├── templates/      # Chua cac file template Jinja2 (vhost.conf.j2)
└── vars/           # Bien uu tien cao hon defaults (main.yml)
```

#### **2. Di chuyển các tác vụ vào `roles/ansible-httpd/tasks/main.yml`:**
```yaml
---
- name: Cai dat Apache Web package
  ansible.builtin.dnf:
    name: "{{ web_package }}"
    state: present

- name: Dam bao thu muc document root ton tai
  ansible.builtin.file:
    path: "{{ web_root }}"
    state: directory
    mode: '0755'

- name: Day file cau hinh vhost tu Template
  ansible.builtin.template:
    src: vhost.conf.j2
    dest: "{{ web_config_file }}"
    mode: '0644'
  notify: Restart Web Service
```

#### **3. Khai báo biến mặc định vào `roles/ansible-httpd/defaults/main.yml`:**
```yaml
---
web_package: httpd
web_service: httpd
web_config_file: /etc/httpd/conf.d/vhost.conf
web_root: /var/www/vhosts/localhost
```

#### **4. Tạo tệp playbook sử dụng role đó (`site.yml`):**
```yaml
---
- name: Run the modular Web Server role
  hosts: dev
  become: true
  roles:
    - role: ansible-httpd
```
* **Lệnh chạy**: `ansible-navigator run site.yml`
