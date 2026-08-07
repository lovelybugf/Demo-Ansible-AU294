# CHƯƠNG 3: BIẾN (VARIABLES), FACTS & ANSIBLE VAULT

## I. KIẾN THỨC LÝ THUYẾT CỐT LÕI

### 1. Quản lý Biến (Variables)
* Biến dùng để tham số hóa giá trị nhằm tăng tính tái sử dụng của Playbook.
* Khai báo trong playbook bằng từ khóa `vars` hoặc nạp từ file bằng `vars_files`.
* **Cú pháp gọi biến**: Gọi thông qua cặp ngoặc nhọn song song `{{ ten_bien }}`. 
  * *Quy tắc quan trọng*: Nếu biến đứng ở đầu chuỗi giá trị, bắt buộc phải bao quanh toàn bộ chuỗi bằng dấu nháy kép (ví dụ: `msg: "{{ app_name }}"`).

### 2. Thu thập thông tin hệ thống (Facts)
* Ansible tự động chạy module `setup` ở đầu mỗi Play (khi `gather_facts: true`) để thu thập thông tin thời gian thực của máy con.
* Dữ liệu facts được lưu trong biến dict `ansible_facts`.
* **Local Facts (Custom Facts)**: Bạn có thể tự định nghĩa facts riêng cho từng máy con bằng cách lưu tệp tin định dạng INI hoặc JSON có đuôi mở rộng `.fact` vào thư mục `/etc/ansible/facts.d/` của máy con. Ansible sẽ tự động nạp các biến này vào `ansible_facts['ansible_local']`.

### 3. Bảo mật với Ansible Vault
* Ansible Vault dùng để mã hóa đối xứng (AES-256) các tệp tin chứa dữ liệu nhạy cảm (như mật khẩu, SSH key) để lưu trữ an toàn trên Git.
* Các lệnh cơ bản:
  * Mã hóa tệp: `ansible-vault encrypt <tên_tệp>`
  * Giải mã tệp: `ansible-vault decrypt <tên_tệp>`
  * Xem tệp mã hóa: `ansible-vault view <tên_tệp>`
  * Sửa tệp mã hóa: `ansible-vault edit <tên_tệp>`

---

## II. HƯỚNG DẪN CHẠY DEMO THỰC TẾ

Tệp thực hành tương ứng: 
* Playbook chính: **[playbooks/demo_2_variables.yml](file:///e:/ansible/playbooks/demo_2_variables.yml)**
* Tệp chứa biến nhạy cảm: **[playbooks/vars_vault.yml](file:///e:/ansible/playbooks/vars_vault.yml)**

### 1. Thiết lập Passwordless Sudo trên máy con (Để chạy nhanh không cần cờ `-K`):
Chạy lệnh này trên máy con `172.25.250.20` để cấp quyền cho user `ducnam`:
```bash
echo "ducnam ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ducnam
```

### 2. Tiến hành mã hóa tệp mật khẩu:
Trên máy Control Plane, thực hiện mã hóa tệp `vars_vault.yml` bằng mật khẩu (ví dụ đặt là `redhat`):
```bash
ansible-vault encrypt playbooks/vars_vault.yml
```

### 3. Thực thi Playbook giải mã nóng và tạo Custom Facts:
```bash
ansible-playbook playbooks/demo_2_variables.yml --ask-vault-pass
```
*Nhập mật khẩu giải mã `redhat` khi hệ thống yêu cầu.*

### 4. Kết quả mong đợi:
* Playbook sẽ tạo thành công thư mục `/etc/ansible/facts.d/` trên máy con và ghi đè file custom.fact vào đó.
* In ra các thông số facts hệ thống của máy con và giải mã hiển thị mật khẩu từ Vault.
