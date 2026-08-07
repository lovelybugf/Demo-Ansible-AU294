# CHƯƠNG 6 & 7: VẬN HÀNH QUY MÔ LỚN (IMPORT / INCLUDE) & ANSIBLE ROLES

## I. KIẾN THỨC LÝ THUYẾT CỐT LÕI

### 1. Tái sử dụng Playbook & Tasks (Chương 6)
Khi dự án lớn, bạn cần chia nhỏ Playbook và gọi lại chúng. Ansible cung cấp hai cơ chế: **Tĩnh (Static - `import`)** và **Động (Dynamic - `include`)**. Đây là kiến thức trọng tâm của chương trình RH294:

| Đặc điểm | `import_*` (Tĩnh - Static) | `include_*` (Động - Dynamic) |
| :--- | :--- | :--- |
| **Thời điểm biên dịch** | **Compile-time** (Trước khi chạy playbook, Ansible tự động chèn nội dung file vào vị trí gọi). | **Runtime** (Khi playbook chạy đến dòng đó, tệp tin mới được đọc và thực thi). |
| **Lệnh áp dụng** | `import_playbook`, `import_tasks`, `import_role` | `include_tasks`, `include_role`, `include_vars` |
| **Sử dụng biến trong tên tệp** | **Không** thể dùng biến cho tên file (ví dụ: `import_tasks: "{{ os_type }}.yml"` sẽ báo lỗi vì lúc biên dịch biến chưa tồn tại). | **Có** thể dùng biến động làm tên file (ví dụ: `include_tasks: "{{ ansible_facts['os_family'] }}.yml"`). |
| **Tác động của `when`** | Điều kiện `when` sẽ được tự động nhân bản và gán trực tiếp cho **từng task con** bên trong tệp được import. | Điều kiện `when` được kiểm tra trước; nếu Sai, toàn bộ file sẽ bị bỏ qua lập tức mà không quét các task con. |
| **Hiển thị tác vụ** | Các task con hiển thị khi chạy lệnh `ansible-playbook --list-tasks`. | Các task con không xuất hiện trước khi chạy, chỉ xuất hiện khi playbook chạy đến dòng đó. |

### 2. Thiết kế Module hóa với Ansible Roles (Chương 7)
* Roles giúp tổ chức mã nguồn một cách khoa học theo cấu trúc thư mục quy chuẩn:
  * `tasks/main.yml`: Chứa các tác vụ thực thi chính.
  * `defaults/main.yml`: Chứa biến mặc định (độ ưu tiên thấp nhất, rất dễ bị ghi đè).
  * `vars/main.yml`: Chứa các biến cố định của riêng Role (độ ưu tiên cao).
  * `handlers/main.yml`: Chứa trình xử lý sự kiện riêng cho Role.
  * `templates/` và `files/`: Nơi lưu trữ tài nguyên tương ứng của Role.
* Gọi Role trong playbook bằng từ khóa `roles:` hoặc gọi động bằng `include_role`.

---

## II. HƯỚNG DẪN CHẠY DEMO THỰC TẾ

Tệp thực hành tương ứng:
* Playbook chính: **[playbooks/demo_4_roles.yml](file:///e:/ansible/playbooks/demo_4_roles.yml)**
* Thư mục Role: **[roles/web_server/](file:///e:/ansible/roles/web_server/)**

### 1. Lệnh thực thi chạy Role và ghi đè cổng mạng:
```bash
ansible-playbook playbooks/demo_4_roles.yml
```

### 2. Lệnh kiểm chứng:
Kiểm tra phản hồi của cổng 8080 (cổng đã được ghi đè thông số biến):
```bash
curl http://172.25.250.20:8080
```
