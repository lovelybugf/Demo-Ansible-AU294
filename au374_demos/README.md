# Hướng Dẫn Chạy Demo Thực Hành Khóa Học Red Hat AU374

Thư mục này chứa các tệp cấu hình mẫu chuẩn hóa được xây dựng theo chương trình đào tạo **Red Hat Ansible Automation Platform 2.6 (AU374 / Advanced Automation)** để bạn thực hành trực tiếp trên máy ảo Red Hat Enterprise Linux (RHEL 8/9).

---

## 1. Cấu Trúc Các Tệp Demo

* **Cấu hình Môi trường & Execution Environment**:
  * [ansible-navigator.yml](file:///d:/Demo-Ansible-AU294/au374_demos/ansible-navigator.yml): Định cấu hình chạy container qua `podman`, nạp Execution Environment chính thức (`creator-ee:latest`), tắt tạo log file JSON tạm (`playbook-artifact: false`), và đặt chế độ log ra màn hình (`mode: stdout`).
  * [ansible.cfg](file:///d:/Demo-Ansible-AU294/au374_demos/ansible.cfg): Cấu hình nạp tệp inventory mặc định, bật privilege escalation (`become = True`), và chỉ định đường dẫn lưu trữ Collection tải về.
  * [collections/requirements.yml](file:///d:/Demo-Ansible-AU294/au374_demos/collections/requirements.yml): Liệt kê các Collection cần tải xuống (ví dụ: `ansible.posix`).

* **Thiết Lập Inventory & Quản Lý Biến Chuyên Biệt (Chapter 5)**:
  * [inventory.yml](file:///d:/Demo-Ansible-AU294/au374_demos/inventory.yml): Inventory tĩnh được viết bằng định dạng YAML (chuẩn tối ưu của AAP 2.6), khai báo nhóm máy chủ `webservers` và `local`.
  * [group_vars/all/common.yml](file:///d:/Demo-Ansible-AU294/au374_demos/group_vars/all/common.yml): Khai báo biến toàn cục áp dụng cho tất cả các máy chủ trong dự án (sử dụng cấu trúc thư mục con chuyên biệt để phân tách biến).
  * [group_vars/webservers/apache.yml](file:///d:/Demo-Ansible-AU294/au374_demos/group_vars/webservers/apache.yml): Khai báo các biến đặc thù cho nhóm máy chủ web.
  * [host_vars/localhost.yml](file:///d:/Demo-Ansible-AU294/au374_demos/host_vars/localhost.yml): Khai báo biến ghi đè riêng cho máy chủ `localhost`.

* **Kịch Bản Thực Thi**:
  * [run_demo.yml](file:///d:/Demo-Ansible-AU294/au374_demos/run_demo.yml): Playbook tổng hợp chạy qua 2 Plays để kiểm tra nạp Facts hệ thống, in biến từ các cấp độ khác nhau để chứng minh Variable Precedence và cách tổ chức code.

---

## 2. Hướng Dẫn Từng Bước Thực Thi Trên Máy RHEL của bạn

Hãy thực hiện tuần tự các bước sau từ terminal của máy Control Node (máy chạy lệnh):

### Bước 1: Di chuyển vào thư mục demo
```bash
cd /home/ducnam/ansible/au374_demos
```

### Bước 2: Tải xuống các Collection cần thiết từ Galaxy/Automation Hub
Chạy lệnh sau để tải các Collection được định nghĩa trong `requirements.yml` về thư mục cục bộ của dự án (tránh làm ảnh hưởng đến thư mục hệ thống):
```bash
ansible-galaxy collection install -r collections/requirements.yml -p ./collections/
```

### Bước 3: Kiểm tra Cú pháp Playbook (Syntax Check)
Sử dụng công cụ `ansible-navigator` để kiểm tra lỗi thụt lề hoặc lỗi cú pháp YAML:
```bash
ansible-navigator run run_demo.yml --syntax-check
```

### Bước 4: Chạy thử nghiệm Playbook không làm thay đổi hệ thống (Dry Run)
```bash
ansible-navigator run run_demo.yml --check
```

### Bước 5: Thực thi Playbook thực tế
Chạy playbook để thu thập Facts của máy đích và xuất các thông số biến đã cấu hình ra terminal:
```bash
ansible-navigator run run_demo.yml
```
