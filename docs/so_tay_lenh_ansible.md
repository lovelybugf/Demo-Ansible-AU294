# SỔ TAY CÁC LỆNH ANSIBLE THƯỜNG DÙNG (CẬP NHẬT LIÊN TỤC)

Sổ tay này ghi lại toàn bộ các câu lệnh đã dùng trong quá trình học tập và thực hành Ansible, kèm theo ý nghĩa chi tiết và các tùy chọn thường gặp.

---

## 1. Lệnh Ad-hoc (Chạy nhanh một dòng)

Dùng để kiểm tra nhanh hệ thống mà không cần viết Playbook.

* **Kiểm tra kết nối SSH (Ping)**:
  ```bash
  ansible dev -m ping -e "ansible_become=false"
  ```
  *Ý nghĩa*: Gửi tín hiệu kiểm tra kết nối SSH đến nhóm máy `dev` mà không yêu cầu nâng quyền root. Trả về `pong` nếu thành công.

* **Thực thi lệnh Linux bất kỳ (Shell)**:
  ```bash
  ansible dev -m shell -a "df -h" -e "ansible_become=false"
  ```
  *Ý nghĩa*: Chạy lệnh xem dung lượng ổ đĩa (`df -h`) trên tất cả máy con thuộc nhóm `dev`.

* **Thu thập thông tin cấu hình (Facts)**:
  ```bash
  ansible dev -m setup -e "ansible_become=false"
  ```
  *Ý nghĩa*: Quét và xuất toàn bộ thông tin phần cứng, hệ điều hành (Facts) dạng JSON của máy con.

* **Lọc thông tin Facts cụ thể**:
  ```bash
  ansible dev -m setup -a "filter=ansible_distribution*" -e "ansible_become=false"
  ```
  *Ý nghĩa*: Chỉ thu thập các thông tin liên quan đến phiên bản hệ điều hành của máy con để tránh tràn ngập màn hình.

---

## 2. Lệnh thực thi Playbook (`ansible-playbook`)

Dùng để chạy các kịch bản tự động hóa viết bằng tệp YAML.

* **Chạy Playbook thông thường**:
  ```bash
  ansible-playbook playbooks/demo_2_variables.yml
  ```
  *Ý nghĩa*: Thực thi tệp kịch bản.

* **Chạy Playbook yêu cầu mật khẩu đặc quyền root (`-K`)**:
  ```bash
  ansible-playbook playbooks/demo_2_variables.yml -K
  ```
  *Ý nghĩa*: Chạy playbook và yêu cầu bạn nhập mật khẩu `BECOME password` (nhập mật khẩu sudo máy con) để thực hiện các tác vụ cài đặt phần mềm.

* **Kiểm tra lỗi cú pháp tệp Playbook**:
  ```bash
  ansible-playbook playbooks/demo_2_variables.yml --syntax-check
  ```
  *Ý nghĩa*: Quét lỗi chính tả, lỗi thụt lề thụt dòng mà không thực sự chạy playbook.

* **Chạy chế độ gỡ lỗi (Verbose log mức cao nhất - `-vvvv`)**:
  ```bash
  ansible-playbook playbooks/demo_2_variables.yml -vvvv
  ```
  *Ý nghĩa*: In toàn bộ thông tin kết nối SSH và các lệnh gửi nhận ngầm ra màn hình để tìm nguyên nhân khi chạy lỗi.

---

## 3. Trình điều khiển hiện đại (`ansible-navigator`)

Dùng để chạy playbook cô lập bên trong Container (Execution Environment - EE).

* **Chạy Playbook bằng Navigator**:
  ```bash
  ansible-navigator run playbooks/demo_2_variables.yml
  ```
  *Ý nghĩa*: Khởi động một container Podman, mount thư mục code và thực thi playbook trong môi trường chuẩn hóa.

* **Chạy Navigator kèm hỏi mật khẩu root**:
  ```bash
  ansible-navigator run playbooks/demo_2_variables.yml -K
  ```

* **Kiểm tra cú pháp bằng Navigator**:
  ```bash
  ansible-navigator run playbooks/demo_2_variables.yml --syntax-check
  ```

---

## 4. Bảo mật với Ansible Vault (Mã hóa dữ liệu)

* **Mã hóa tệp tin nhạy cảm**:
  ```bash
  ansible-vault encrypt db-pass.yml
  ```
  *Ý nghĩa*: Nhập mật khẩu mã hóa để biến tệp chứa mật khẩu bản rõ thành tệp mã hóa AES-256 an toàn.

* **Xem nội dung tệp đã mã hóa (không lưu đè)**:
  ```bash
  ansible-vault view db-pass.yml
  ```
  *Ý nghĩa*: Nhập mật khẩu giải mã để đọc nhanh nội dung tệp mà không làm mất trạng thái mã hóa của tệp trên đĩa.

* **Giải mã vĩnh viễn tệp tin**:
  ```bash
  ansible-vault decrypt db-pass.yml
  ```

* **Chạy Playbook có sử dụng tệp mã hóa**:
  ```bash
  ansible-playbook playbooks/demo_2_variables.yml --ask-vault-pass
  ```
  *Ý nghĩa*: Yêu cầu nhập mật khẩu giải mã Vault khi chạy để nạp các biến mật khẩu vào kịch bản.

---

## 5. Lệnh hệ thống hỗ trợ thiết lập Lab

* **Thiết lập đăng nhập SSH không mật khẩu**:
  ```bash
  ssh-copy-id -i ~/.ssh/id_ed25519.pub ducnam@172.25.250.20
  ```
  *Ý nghĩa*: Sao chép khóa công khai sang máy con để tự động đăng nhập SSH mà không bị hỏi mật khẩu.

* **Cấu hình Sudo không cần mật khẩu (Passwordless Sudo) trên máy con**:
  ```bash
  echo "ducnam ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ducnam
  ```
  *Ý nghĩa*: Thực hiện trên máy con để cho phép user `ducnam` chạy tất cả lệnh quản trị tối cao (`sudo`) mà không cần nhập lại mật khẩu. Rất hữu ích khi Ansible chạy tự động.

* **Tải thủ công container image (Podman)**:
  ```bash
  podman pull quay.io/ansible/creator-ee:latest
  ```
  *Ý nghĩa*: Tải trước môi trường container chuẩn của Red Hat về máy Windows hoặc máy ảo để tăng tốc độ chạy playbook.
