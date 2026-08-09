# Chương 5: Triển khai Files & Cấu hình Templates Jinja2

Chương này hướng dẫn cách tự động hóa các tác vụ quản lý tệp tin trên máy con và kỹ thuật sử dụng động cơ mẫu Jinja2 (Templates) để tạo các tệp cấu hình tùy biến động theo từng máy.

---

## 1. Các Module Quản lý Tệp tin (File Management Modules)

Ansible cung cấp bộ module mạnh mẽ phục vụ việc tạo, xóa, chỉnh sửa thuộc tính và đồng bộ dữ liệu:

### 1.1. Module Sao chép và Thu thập File
* **`ansible.builtin.copy`**: Sao chép tệp từ Control Node sang máy con.
  * Đảm bảo tính nhất quán (Idempotency) bằng cách so sánh mã băm **SHA1 Checksum** của tệp nguồn và đích.
  * Nếu đường dẫn nguồn `src` kết thúc bằng dấu gạch chéo `/` (ví dụ: `src: files/`), hệ thống chỉ copy phần ruột bên trong. Nếu không có gạch chéo `/`, hệ thống copy cả thư mục cha.
  * Sử dụng `remote_src: true` để chỉ định copy nguồn có sẵn trên máy con (không truyền từ Control Node sang).
* **`ansible.builtin.fetch`**: Thu thập tệp từ máy con về lưu tại Control Node.
  * Mặc định tự động phân chia thư mục theo tên host của máy con để tránh ghi đè lẫn nhau.
  * Thiết lập `flat: true` nếu muốn tệp tin tải về nằm trực tiếp trong thư mục đích mà không tạo cấu trúc cây thư mục theo host.
* **`ansible.posix.synchronize`**: Đồng bộ dữ liệu tốc độ cao qua giao thức `rsync`.
  * Tối ưu cho việc chuyển các thư mục dung lượng lớn. Yêu cầu cả máy chạy và máy con đều cài đặt lệnh `rsync`. Mặc định ở chế độ đẩy (`push`), đổi sang `mode: pull` để thu thập dữ liệu về Control Node.

### 1.2. Module Chỉnh sửa Nội dung File (Sửa dòng/Khối văn bản)
* **`ansible.builtin.lineinfile`**: Đảm bảo một dòng văn bản cụ thể tồn tại hoặc biến mất trong file.
  * Thích hợp cho việc sửa đổi nhỏ, đơn lẻ (như bật tắt cấu hình sshd, cấu hình một dòng tham số).
  * Sử dụng `regexp` để tìm và thay thế dòng khớp regex. Sử dụng `insertbefore` hoặc `insertafter` để định vị dòng chèn. Thiết lập `create: true` để tự động tạo file nếu chưa có.
  * Thiết lập `backup: true` để tự động sao lưu file gốc trước khi sửa.
* **`ansible.builtin.blockinfile`**: Chèn, cập nhật hoặc xóa một khối văn bản gồm nhiều dòng.
  * Sử dụng các nhãn đánh dấu để nhận diện khối (`# BEGIN ANSIBLE MANAGED BLOCK` và `# END ANSIBLE MANAGED BLOCK`). Nhờ các nhãn này, Ansible sẽ cập nhật lại chính xác khối văn bản cũ thay vì chèn lặp lại ở lần chạy sau.
  * Có thể tùy biến nhãn này qua tham số `marker`, `marker_begin`, `marker_end` để quản lý nhiều khối văn bản độc lập trong cùng một file.

### 1.3. Module Quản lý Thuộc tính và Tra cứu File
* **`ansible.builtin.file`**: Thiết lập phân quyền, chủ sở hữu, nhóm, hoặc tạo liên kết mềm (symlink), xóa tệp/thư mục.
  * Các giá trị của `state`: `directory` (tạo thư mục), `touch` (tạo file rỗng hoặc cập nhật mtime), `link` (tạo symlink), `absent` (xóa file/thư mục).
  * Hỗ trợ cấu hình nhãn bảo mật SELinux thông qua tham số `setype` (ví dụ: `setype: httpd_sys_content_t`).
* **`ansible.builtin.stat`**: Lấy thông tin chi tiết của file (giống lệnh `stat` của Linux) như quyền, checksum, sự tồn tại (`passwd_stat.stat.exists`), chủ sở hữu.
* **`ansible.builtin.find`**: Tìm kiếm tệp tin theo các điều kiện lọc (kích thước `size`, độ tuổi file `age`, tên định dạng `patterns`, đệ quy `recurse: true`), trả về danh sách lưu trong `.files`.

---

## 2. Sử dụng Mẫu Jinja2 (Jinja2 Templates)

Khi cấu hình máy chủ có cấu trúc giống nhau nhưng các giá trị cụ thể (IP, Hostname, CPU, RAM) khác nhau theo từng máy, việc dùng `lineinfile` hay `copy` sẽ rất thủ công. Ta sử dụng **Jinja2 Template** làm khuôn mẫu thiết kế.

### 2.1. Cú pháp và Các ký tự phân định Jinja2
Mẫu template thường được lưu với đuôi tệp tin mở rộng là `.j2` (ví dụ: `nginx.conf.j2`). Ba ký tự phân định cơ bản trong Jinja2:
1. **`{{ EXPR }}`**: Dùng để in giá trị của biến hoặc biểu thức.
   * Ví dụ: `ListenAddress {{ ansible_facts['default_ipv4']['address'] }}`
2. **`{% EXPR %}`**: Dùng cho cấu trúc điều khiển (vòng lặp `for`, câu lệnh điều kiện `if`).
3. **`{# COMMENT #}`**: Dùng cho chú thích. Nội dung chú thích này sẽ bị lược bỏ hoàn toàn khi sinh ra file cấu hình thật trên máy con.

### 2.2. Biến đặc biệt `ansible_managed`
Để cảnh báo quản trị viên không sửa file thủ công trên máy con, ta chèn biến `{{ ansible_managed }}` vào đầu tệp `.j2`. Cấu hình chuỗi hiển thị của biến này được khai báo trong `ansible.cfg`:
```ini
[defaults]
ansible_managed = Tệp tin này được quản lý tự động bởi Ansible. Mọi sửa đổi thủ công sẽ bị ghi đè!
```

### 2.3. Vòng lặp và Điều kiện bên trong Template

* **Vòng lặp `for`**:
  ```jinja2
  {% for host in groups['all'] %}
  {{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }} {{ hostvars[host]['ansible_facts']['fqdn'] }}
  {% endfor %}
  ```
  * Bên trong vòng lặp `for`, ta có thể sử dụng biến hệ thống `loop.index` (bắt đầu từ 1) để lấy chỉ mục thứ tự hiện tại của vòng lặp.
* **Điều kiện `if`**:
  ```jinja2
  {% if max_clients is defined %}
  MaxClients {{ max_clients }}
  {% endif %}
  ```

> [!WARNING]
> Cú pháp vòng lặp và điều kiện Jinja2 chỉ được sử dụng bên trong tệp tin Template (`.j2`), không được viết trực tiếp vào tệp Playbook YAML (Playbook YAML phải dùng `loop` và `when`).

---

## 3. Bộ lọc biến Jinja2 (Filters)

Bộ lọc giúp định dạng và chuyển đổi dữ liệu trước khi ghi ra tệp tin. Các bộ lọc được kết nối sau biến qua ký tự ống dẫn `|`.

### 3.1. Chuyển đổi định dạng cấu trúc dữ liệu
* **`to_nice_json` / `to_nice_yaml`**: Định dạng từ điển hoặc danh sách của Ansible thành chuỗi JSON/YAML chuẩn hóa có thụt dòng đẹp mắt để ghi vào file cấu hình.
* **`from_json` / `from_yaml`**: Đọc chuỗi JSON/YAML thô thu được từ bên ngoài và chuyển thành biến cấu trúc để Ansible xử lý.

### 3.2. Bộ lọc xử lý và cung cấp giá trị mặc định
* **Bộ lọc `default`**: Cung cấp giá trị dự phòng nếu biến không được định nghĩa, tránh gây lỗi dừng playbook:
  ```jinja2
  port = {{ app_port | default('8080') }}
  ```
  * Nếu biến `app_port` không có giá trị, hệ thống tự điền `8080`.
* **Bộ lọc chuỗi**: `lower` (chuyển chữ thường), `upper` (chuyển chữ hoa).
  * Ví dụ: `hostname: {{ inventory_hostname | lower }}`

---

## 4. Cách triển khai Template trong Playbook

Sử dụng module `ansible.builtin.template`. Mặc định module này tìm tệp nguồn trong thư mục `templates/` của dự án:

```yaml
- name: Cấu hình SSH Daemon từ Template
  hosts: all
  vars:
    ssh_port: 22
  tasks:
    - name: Deploy sshd_config
      ansible.builtin.template:
        src: sshd_config.j2
        dest: /etc/ssh/sshd_config
        mode: '0600'
        validate: '/usr/sbin/sshd -t -f %s' # Kiểm tra cú pháp file cấu hình trước khi lưu thật, %s là file tạm.
```
* Tham số `validate` cực kỳ quan trọng, nó chạy lệnh kiểm tra tính đúng đắn của file cấu hình tạm thời, nếu lệnh kiểm tra thất bại, Ansible sẽ không ghi đè vào file cấu hình thật giúp bảo vệ hệ thống khỏi lỗi sập dịch vụ.
