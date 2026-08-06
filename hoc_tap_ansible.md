# HƯỚNG DẪN HỌC & THỰC HÀNH TOÀN DIỆN ANSIBLE (CHUẨN RED HAT AU294 / RH294)

Tài liệu này được tổng hợp từ toàn bộ kho tài liệu học tập của bạn bao gồm 8 Chương lý thuyết và 4 Bài Lab thực hành tổng hợp của chương trình đào tạo **Red Hat Linux Automation with Ansible**.

---

## PHẦN I: BẢN ĐỒ LÝ THUYẾT (TÓM TẮT TỪ CẤP CHƯƠNG 1 - 8)

### Chương 1 & 2: Khởi đầu với Ansible & Cấu trúc Dự án
* **Kiến trúc**: Control Node (máy chạy lệnh - máy RHEL của bạn) kết nối qua SSH tới Managed Hosts (các máy cần điều khiển).
* **Inventory**: Tệp quản lý danh sách IP/Hostname của máy đích. Hỗ trợ gom nhóm (`[webservers]`), nhóm lồng nhóm (`[group:children]`), phạm vi giải IP (`192.168.1.[1:50]`).
* **YAML**: Cú pháp cơ bản của Playbook. Thụt lề bằng dấu cách (space), không dùng phím Tab.

### Chương 3: Biến (Variables), Facts & Ansible Vault
* **Biến (Vars)**: Dùng để lưu trữ các giá trị động. Khai báo trong playbook (`vars:`), tệp biến (`vars_files:`), hoặc các thư mục đặc biệt `group_vars/` và `host_vars/`.
* **Facts**: Dữ liệu hệ thống tự động thu thập từ máy đích ở đầu mỗi Play (Gathering Facts). Ví dụ: `ansible_facts['hostname']`, `ansible_facts['memtotal_mb']`.
* **Ansible Vault**: Mã hóa các thông tin nhạy cảm (như mật khẩu, khóa bí mật) bằng thuật toán AES-256. Lệnh: `ansible-vault encrypt secret.yml`.

### Chương 4: Điều khiển Tác vụ (Task Control)
* **Câu điều kiện (`when`)**: Chạy tác vụ chỉ khi điều kiện đúng (thường so khớp với biến hoặc Facts).
* **Vòng lặp (`loop`)**: Chạy một tác vụ lặp lại với nhiều giá trị đầu vào (sử dụng biến lặp `{{ item }}`).
* **Xử lý sự kiện (`handlers`)**: Tác vụ chỉ chạy khi có sự thay đổi được báo cáo (`notify`) bởi tác vụ khác (ví dụ: khởi động lại dịch vụ khi tệp cấu hình thay đổi).
* **Khối tác vụ (`block` & `rescue`)**: Gom nhóm các tác vụ (`block`) và định nghĩa khối xử lý lỗi (`rescue`) để chạy nếu các tác vụ trong block bị lỗi (giống cấu trúc try-catch).

### Chương 5: Quản lý & Triển khai Tệp tin (File Deployment)
* **Tác vụ tệp**: Tạo, xóa, chỉnh sửa quyền hạn với các module `ansible.builtin.copy`, `ansible.builtin.file`, `ansible.builtin.lineinfile`.
* **Jinja2 Templates (`ansible.builtin.template`)**: Đẩy tệp cấu hình động chứa các biến và logic xử lý (như vòng lặp `for`, câu lệnh `if`) lên máy đích từ tệp nguồn đuôi `.j2`.

### Chương 6: Vận hành Ansible ở quy mô lớn ( AAP & Execution Environments)
* Sử dụng **Automation Execution Environments (EE)** là các container (chạy bằng Podman/Docker) đóng gói sẵn toàn bộ môi trường chạy Ansible để đảm bảo tính đồng bộ từ môi trường phát triển (dev) lên sản xuất (prod).

### Chương 7: Tái sử dụng code với Ansible Roles
* **Ansible Roles**: Cấu trúc thư mục tiêu chuẩn hóa để chia nhỏ một playbook cồng kềnh thành các phần độc lập có thể tái sử dụng (tasks, handlers, vars, defaults, files, templates, meta).

### Chương 8: Tự động hóa Tác vụ Quản trị Linux
* Sử dụng **Red Hat System Roles** (`redhat.rhel_system_roles`) - bộ sưu tập các role viết sẵn do Red Hat cung cấp để tự động hóa cấu hình hệ thống Linux như: Lưu trữ mạng (`storage`), tường lửa (`firewall`), mạng (`network`), tiến trình lặp (`cron`).

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
