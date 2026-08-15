# Hướng Dẫn Hiện Thực Hóa Cấu Trúc Ansible Chuẩn (AU374)

Tài liệu này hướng dẫn chi tiết cách tự tạo một cấu trúc dự án tự động hóa bằng Ansible chuẩn hóa, cách cấu hình Git, cấu hình trình điều khiển `ansible-navigator` và quản lý hệ thống máy chủ qua Inventory theo chuẩn đào tạo nâng cao của Red Hat (AU374).

---

## 1. Cấu Trúc Thư Mục Dự Án Ansible Tiêu Chuẩn

Trong môi trường doanh nghiệp, một dự án Ansible không nên viết tất cả mọi thứ vào một tệp tin duy nhất. Thay vào đó, dự án cần phân tách rõ ràng để dễ bảo trì, cập nhật và chia sẻ.

### Sơ đồ thư mục chuẩn:
```text
ansible-project/
├── ansible.cfg                # Tệp cấu hình các mặc định của Ansible Core
├── ansible-navigator.yml      # Cấu hình container chạy Execution Environment (EE)
├── inventory.yml              # Quản lý danh sách thiết bị bằng định dạng YAML
├── .gitignore                 # Cấu hình loại trừ các tệp tự động tải khi commit Git
├── collections/
│   └── requirements.yml       # Khai báo các Collections cần tải thêm từ Galaxy
├── group_vars/                # Thư mục chứa các biến cấp độ nhóm thiết bị
│   ├── all/
│   │   └── common.yml         # Biến chung cho tất cả các máy chủ
│   └── webservers/
│       └── apache.yml         # Biến dành riêng cho nhóm máy chủ webservers
├── host_vars/                 # Thư mục chứa các biến cấp độ từng máy riêng lẻ
│   └── localhost.yml          # Biến ghi đè riêng cho máy localhost
├── roles/                     # Thư mục chứa các cấu trúc Role tự viết để tái sử dụng
│   └── requirements.yml       # (Tùy chọn) Khai báo các Role cần tải thêm từ bên ngoài
└── playbooks/
    └── run_demo.yml           # Các playbook thực thi tác vụ chính
```

---

## 2. Hướng Dẫn Cấu Hình Git Cho Dự Án Ansible

Khi quản lý dự án tự động hóa bằng Git, việc quan trọng nhất là **không đẩy các mã nguồn tự động tải về** lên Git Server, vì điều này làm nặng kho chứa và có thể gây xung đột phiên bản.

### Thiết lập `.gitignore`:
Tệp tin [.gitignore](file:///d:/Demo-Ansible-AU294/au374_demos/.gitignore) trong thư mục này đã hiện thực hóa cấu hình chuẩn:
* Loại bỏ thư mục lưu trữ collections tải về: `collections/*`, nhưng giữ lại file cấu hình: `!collections/requirements.yml`.
* Loại bỏ thư mục role tải về: `roles/**`, nhưng giữ lại file cấu hình: `!roles/requirements.yml`.
* Loại bỏ các file log tạm thời do `ansible-navigator` sinh ra khi chạy: `*artifact-*.json`.

### Các lệnh Git khuyên dùng khi phát triển:
1. **Thiết lập thông tin cá nhân**:
   ```bash
   git config --global user.name "Tên Của Bạn"
   git config --global user.email "email@cua.ban"
   ```
2. **Luôn sử dụng nhánh tính năng (Feature Branches)** để kiểm thử trước khi merge vào nhánh `main`:
   ```bash
   git checkout -b feature/trien-khai-nginx
   ```
3. **Viết commit message rõ ràng** (Ví dụ: `feat: bổ sung role cấu hình nginx và mở port firewall`).

---

## 3. Cấu Hẫn Cấu Hình Trình Điều Khiển Navigator

Trình điều khiển hiện đại `ansible-navigator` chạy playbook bên trong các container cô lập gọi là Execution Environment (EE). 

Cấu hình mẫu trong tệp [ansible-navigator.yml](file:///d:/Demo-Ansible-AU294/au374_demos/ansible-navigator.yml) đã hiện thực hóa các thông số quan trọng:
* **Container Engine**: Sử dụng `podman` vì đây là Container Engine mặc định trên hệ điều hành RHEL 8/9 của Red Hat.
* **Chế độ Output (`mode: stdout`)**: Chuyển giao diện từ đồ họa TUI dạng bảng sang màn hình văn bản truyền thống. Giúp bạn dễ dàng theo dõi đầu ra của playbook, sao chép nhật ký chạy và xử lý các câu hỏi yêu cầu nhập mật khẩu bảo mật (như Vault, SSH).
* **Vô hiệu hóa log tạm (`playbook-artifact: false`)**: Ngăn không cho sinh ra các tệp tin log đuôi `.json` sau mỗi lần chạy làm nhiễu thư mục làm việc của dự án.

---

## 4. Cấu Hình Inventory Và Tổ Chức Biến Cấp Cao

### Định dạng Inventory YAML thay vì INI:
Tài liệu AU374 khuyến nghị chuyển dịch toàn bộ file Inventory sang định dạng YAML nhằm đảm bảo cấu trúc chặt chẽ và dễ tích hợp với các hệ thống Cloud/API bên ngoài. Tệp [inventory.yml](file:///d:/Demo-Ansible-AU294/au374_demos/inventory.yml) sử dụng cách phân cấp rõ ràng giữa nhóm cha và nhóm con.

### Thứ tự ưu tiên của biến (Variable Precedence) cần nhớ:
Ansible nạp biến từ rất nhiều nguồn, thứ tự ưu tiên từ thấp đến cao như sau:
1. `defaults/main.yml` trong Role (Thấp nhất, dùng làm giá trị mặc định phòng ngừa).
2. Biến trong tệp Inventory hoặc `group_vars/all`.
3. Biến trong thư mục `group_vars/` của nhóm cụ thể (Ví dụ: `group_vars/webservers`).
4. Biến trong thư mục `host_vars/` của máy chủ riêng biệt (Ví dụ: `host_vars/localhost`).
5. Biến thu thập tự động từ phần cứng máy con (Facts).
6. Biến khai báo trực tiếp trong Playbook (`vars` hoặc `vars_files`).
7. Biến nạp nóng qua dòng lệnh thực thi CLI: `ansible-navigator run playbook.yml -e "ten_bien=gia_tri"` (Cao nhất, luôn luôn ghi đè mọi giá trị khác).

Hãy xem cách thức nạp biến thực tế bằng cách thực thi Playbook mẫu [run_demo.yml](file:///d:/Demo-Ansible-AU294/au374_demos/run_demo.yml) theo hướng dẫn ở file [README.md](file:///d:/Demo-Ansible-AU294/au374_demos/README.md).
