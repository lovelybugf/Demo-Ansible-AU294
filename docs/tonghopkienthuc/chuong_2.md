# Chương 2: Quản lý Inventory & Viết Playbook Cơ bản

Chương này đi sâu vào cách định nghĩa danh sách máy chủ đích (Inventory), cấu trúc cơ bản của tệp cấu hình Playbook bằng YAML và cách kiểm tra lỗi cũng như chạy các lệnh thực thi cơ bản.

---

## 1. Xây dựng Inventory trong Ansible

### 1.1. Khái niệm Inventory
Ansible sử dụng **Inventory** để xác định các máy chủ sẽ bị tác động khi chạy lệnh. Inventory có thể ở dạng tĩnh (Static file) hoặc động (Dynamic - truy vấn từ đám mây/Cơ sở dữ liệu ở runtime).
* Định dạng phổ biến nhất là **INI format**. Tệp mặc định của hệ thống là `/etc/ansible/hosts`, nhưng thực tế dự án luôn định nghĩa tệp inventory riêng (được trỏ trong `ansible.cfg` hoặc truyền qua cờ `-i`).

### 1.2. Phân loại Nhóm máy chủ (Host Groups)
* **Khai báo nhóm**: Đặt tên nhóm trong dấu ngoặc vuông `[...]`, các host thuộc nhóm viết ở các dòng tiếp theo:
  ```ini
  [webservers]
  web1.example.com
  web2.example.com
  192.168.40.140
  ```
* **Nhóm mặc định**: Luôn có 2 nhóm mặc định:
  * `all`: Chứa tất cả các host được khai báo trong inventory.
  * `ungrouped`: Chứa các host được khai báo trực tiếp mà không nằm trong bất kỳ nhóm tùy biến nào.
* **Nhóm lồng nhau (Nested Groups)**: Tạo nhóm cha chứa các nhóm con bằng hậu tố `:children`:
  ```ini
  [usa]
  wash1.example.com
  
  [canada]
  ont1.example.com
  
  [north-america:children]
  usa
  canada
  ```

### 1.3. Định nghĩa dãy máy chủ bằng Dải số (Ranges)
Giúp rút gọn khai báo khi hệ thống có hàng trăm máy chủ đặt tên theo quy tắc:
* **Cú pháp**: `[START:END]` hoặc `[START:END:STEP]` (tăng tiến bước nhảy).
* **Ví dụ**:
  * `web[01:20].example.com` (khớp từ web01 đến web20, giữ nguyên số 0 ở đầu).
  * `192.168.40.[10:20]` (khớp các IP từ .10 đến .20).
  * `web[01:20:2].example.com` (chỉ khớp các web số lẻ: web01, web03, ..., web19).

### 1.4. Định nghĩa Biến (Variables) trực tiếp trong Inventory
* **Biến cấp Host**: Đặt trực tiếp cùng dòng với host:
  ```ini
  web1.example.com ansible_port=2222 ansible_user=admin
  ```
* **Biến cấp Group**: Sử dụng hậu tố `:vars`:
  ```ini
  [webservers:vars]
  ansible_connection=ssh
  ansible_ssh_private_key_file=/path/to/key
  ```

### 1.5. Lệnh kiểm tra Inventory
Sử dụng `ansible-navigator` để xem cấu trúc nhóm:
* Liệt kê dạng JSON: `ansible-navigator inventory -i inventory -m stdout --list`
* Vẽ sơ đồ nhóm: `ansible-navigator inventory -i inventory -m stdout --graph <tên_nhóm>`
* Duyệt dạng giao diện tương tác: `ansible-navigator inventory -i inventory`

---

## 2. Viết Playbook trong Ansible

### 2.1. Định dạng YAML và Quy tắc Thụt lề
Playbook được viết dưới dạng tệp văn bản YAML (`.yml` hoặc `.yaml`):
* Bắt đầu tệp bằng ba dấu gạch ngang `---` để đánh dấu khởi đầu.
* Kết thúc tệp (tùy chọn) bằng ba dấu chấm `...`.
* **Quy tắc thụt lề**: Chỉ dùng khoảng trắng (Spaces) để thụt lề cấp bậc dữ liệu, tuyệt đối **không được dùng phím Tab**. Thường dùng thụt lề 2 khoảng trắng.
* Danh sách phần tử bắt đầu bằng dấu gạch ngang kèm khoảng trắng `- `. Từ điển (Dictionary) được viết dưới dạng cặp `key: value`.

### 2.2. Cấu trúc của một Playbook
Một playbook chứa danh sách các **Plays**. Một Play điều phối hoạt động bằng cách chạy một danh sách các **Tasks** tuần tự lên một nhóm **Hosts** được chọn:

```yaml
---
- name: Cấu hình Web Server Apache # Tiêu đề của Play (Tùy chọn nhưng nên viết)
  hosts: webservers                # Nhóm host đích từ Inventory
  remote_user: devops              # User kết nối (ghi đè cấu hình config)
  become: true                     # Bật leo thang đặc quyền sudo cho toàn bộ Task trong Play này
  
  tasks:
    - name: Cai dat Apache Web     # Tiêu đề của Task
      ansible.builtin.dnf:         # Module thực thi (dạng FQCN)
        name: httpd
        state: latest              # Các tham số của module
```

### 2.3. Khái niệm Tên đầy đủ FQCN (Fully Qualified Collection Name)
Để tránh xung đột tên module giữa các nguồn cung cấp, luôn đặt tên module dạng đầy đủ:
* Định dạng: `<namespace>.<collection_name>.<module_name>`
* Ví dụ: Sử dụng `ansible.builtin.copy` thay vì chỉ viết `copy` để đảm bảo độ tin cậy.

---

## 3. Kiểm tra và Thực thi Playbook

### 3.1. Chạy thực tế Playbook
```bash
ansible-navigator run playbook.yml
```

### 3.2. Kiểm tra cú pháp (Syntax Check)
Trước khi chạy, hãy kiểm tra xem tệp YAML có bị lỗi thụt lề hay sai cú pháp không:
```bash
ansible-navigator run playbook.yml --syntax-check
```

### 3.3. Chạy thử nghiệm (Dry Run / Check Mode)
Chạy mô phỏng để biết các task nào sẽ thay đổi hệ thống (`changed`), task nào giữ nguyên (`ok`) nhưng không tác động thật vào máy con:
```bash
ansible-navigator run playbook.yml --check
```

### 3.4. Mức độ chi tiết Logs (Verbosity Levels)
Thêm cờ `-v` khi chạy lệnh để tăng độ chi tiết hiển thị phục vụ quá trình debug lỗi:
* `-v`: Hiển thị kết quả chi tiết của các task.
* `-vv`: Hiển thị thêm cấu hình biến của task.
* `-vvv`: Hiển thị chi tiết quá trình kết nối SSH.
* `-vvvv` đến `-vvvvvv`: Xem logs debug sâu bên trong Engine và Python (dành cho lập trình viên lõi).

---

## 4. Chạy lệnh tự do và Vấn đề Nhất quán (Idempotency)

### 4.1. Phân biệt Module chạy lệnh tự do: Command, Shell và Raw

Khi hệ thống không có sẵn module chuyên biệt, ta có thể dùng các module chạy lệnh tự do sau:
* **`ansible.builtin.command`**: Module chạy lệnh đơn giản nhất và là mặc định. Lệnh chạy trực tiếp mà không qua shell của máy con nên **không** hỗ trợ các ký tự đặc biệt như ống dẫn `|`, chuyển hướng đầu ra `>`, hoặc biến môi trường `$VAR`.
* **`ansible.builtin.shell`**: Chạy lệnh thông qua trình shell (ví dụ `/bin/bash`) của máy con. Hỗ trợ đầy đủ pipelines, chuyển hướng dữ liệu và biến môi trường.
* **`ansible.builtin.raw`**: Gửi trực tiếp chuỗi lệnh qua kết nối SSH mà không khởi tạo subsystem module của Ansible. Cực kỳ hữu ích khi cấu hình thiết bị mạng hoặc máy con chưa được cài đặt Python.

### 4.2. Vấn đề Nhất quán (Idempotency)
* Một playbook/task được gọi là **nhất quán (idempotent)** khi chạy nó nhiều lần trên cùng một hệ thống vẫn cho ra cùng một kết quả duy nhất và không làm thay đổi hệ thống từ lần chạy thứ 2.
* Các module chạy lệnh tự do (`command`, `shell`, `raw`) **không có tính nhất quán**. Mỗi lần chạy chúng đều báo trạng thái `changed` (màu vàng).
* **Khuyên dùng**: Hạn chế tối đa việc sử dụng các module chạy lệnh tự do. Hãy thay thế bằng các module tích hợp sẵn có hỗ trợ kiểm tra trạng thái (ví dụ dùng `ansible.builtin.copy` thay vì `shell: echo "content" > file`).

---

## 5. Chạy nhanh lệnh đơn dòng (Ad Hoc Commands)

* **Ad Hoc Command** là cách chạy nhanh một tác vụ Ansible trực tiếp trên terminal mà không cần viết tệp Playbook. Thích hợp cho việc kiểm tra nhanh hoặc xử lý sự cố tức thời.
* **Cú pháp**: `ansible <host_pattern> -m <module_name> -a '<arguments>'`
* **Ví dụ kiểm tra kết nối**:
  ```bash
  ansible all -m ansible.builtin.ping
  ```
