# CHƯƠNG 1 & 2: KHỞI ĐẦU VỚI ANSIBLE & CẤU TRÚC DỰ ÁN

## I. KIẾN THỨC LÝ THUYẾT CỐT LÕI

### 1. Kiến trúc Agentless (Không tác nhân)
* **Khái niệm**: Ansible hoạt động theo cơ chế **agentless** (không cần cài phần mềm đặc vụ trên máy khách).
* **Cơ chế**: 
  * Máy chạy lệnh (**Control Node**) sẽ kết nối SSH đến các máy con (**Managed Hosts**).
  * Đẩy các đoạn mã nhỏ viết bằng Python (gọi là **Modules**) sang máy con để thực thi.
  * Nhận lại kết quả thực thi dạng JSON, sau đó tự động xóa mã Python tạm thời này trên máy con và đóng kết nối.

### 2. Cấu trúc một dự án Ansible chuẩn
Một thư mục dự án Ansible chuẩn tối thiểu nên có các tệp tin cấu hình sau:
* **`ansible.cfg`**: Quy định hành vi mặc định của Ansible (đường dẫn inventory, chế độ leo thang quyền root, xác thực SSH).
* **`inventory`**: Tệp tin lưu trữ danh sách tên miền/địa chỉ IP của các máy con và phân chia theo các nhóm quản lý.
* **`ansible-navigator.yml`**: Quy định môi trường chạy (Execution Environment) dạng container qua Podman/Docker cho trình Navigator.

### 3. Lệnh Ad-hoc (Lệnh chạy nhanh một dòng)
* Sử dụng khi cần chạy các tác vụ nhanh, tức thời trên máy con mà không muốn tốn công viết Playbook.
* **Cú pháp**:
  ```bash
  ansible <nhóm_máy_chủ> -m <tên_module> -a "<các_tham_số>" -e "ansible_become=false"
  ```

---

## II. HƯỚNG DẪN CHẠY DEMO THỰC TẾ

Tệp thực hành tương ứng: **[playbooks/demo_1_adhoc.sh](file:///e:/ansible/playbooks/demo_1_adhoc.sh)**

### 1. Quy trình chuẩn bị:
1. Đồng bộ mã nguồn mới nhất lên máy Control Plane `172.25.250.8` (`git pull`).
2. Luôn đứng ở **thư mục gốc dự án** (`/home/ducnam/ansible/`) khi chạy lệnh để Ansible nhận diện đúng tệp cấu hình `ansible.cfg` và `inventory`.

### 2. Lệnh thực thi:
```bash
bash playbooks/demo_1_adhoc.sh
```

### 3. Giải thích các module ad-hoc đã dùng:
* **`ping`**: Gửi tín hiệu xác thực kết nối và phản hồi từ máy con (`"ping": "pong"`).
* **`shell`**: Thực thi các lệnh Linux dạng thô (`df -h`, `ls -la`).
* **`setup`**: Thu thập toàn bộ Facts (dữ liệu phần cứng, mạng, OS) của máy con.
* **`command`**: Thực thi lệnh trực tiếp trên máy con mà không thông qua môi trường shell, đảm bảo an toàn hơn `shell`.
* *Lưu ý*: Vì các lệnh trên là các lệnh kiểm tra và đọc thông số hệ thống, ta truyền thêm biến ghi đè `-e "ansible_become=false"` để chạy với tư cách user thông thường không cần quyền root.
