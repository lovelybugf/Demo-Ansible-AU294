# Chương 6: Quản lý Mã nguồn Quy mô lớn: Import vs Include

Chương này trình bày các kỹ thuật module hóa để quản lý các dự án Ansible quy mô lớn, so sánh chi tiết giữa cơ chế nạp tĩnh (Import) và nạp động (Include) của tệp tin task/playbook, cùng các cú pháp lọc máy chủ đích nâng cao (Host Patterns).

---

## 1. Thiết kế Module hóa trong Quản lý Dự án Lớn

Khi dự án tự động hóa phát triển, các Playbook sẽ tăng dần quy mô. Việc gộp hàng trăm task vào một file duy nhất sẽ gây khó khăn cho việc bảo trì, kiểm thử và cộng tác nhóm.
* **Giải pháp**: Tách các tác vụ thành các tệp danh sách task nhỏ, độc lập (ví dụ: `tasks/install.yml`, `tasks/configure.yml`) và nạp chúng vào tệp Playbook chính.
* **Lợi ích**: Dễ kiểm thử, dễ tái sử dụng mã nguồn cho nhiều dự án khác nhau và tránh xung đột khi làm việc nhóm (merge conflicts).

---

## 2. So sánh Cơ chế Tĩnh (Import) và Động (Include)

Ansible cung cấp hai cơ chế nạp tệp tin bên ngoài với nguyên lý hoạt động hoàn toàn khác nhau:

### 2.1. Cơ chế Tĩnh - Import (`import_tasks`, `import_playbook`)
* **Thời điểm xử lý**: Parse-time (ngay khi Ansible bắt đầu đọc và biên dịch Playbook, trước khi có bất kỳ tác vụ nào được thực thi). Nó hoạt động giống như việc "sao chép và dán" nội dung tệp con trực tiếp vào tệp chính.
* **Lỗi cú pháp**: Nếu tệp import không tồn tại hoặc bị lỗi cú pháp, Playbook sẽ **thất bại lập tức** trước khi chạy.
* **Tính năng hỗ trợ**:
  * **Không hỗ trợ** các vòng lặp động (ví dụ duyệt qua danh sách đăng ký từ task trước đó). Chỉ cho phép vòng lặp với biến tĩnh đã biết từ đầu.
  * Khi liệt kê danh sách task (`--list-tasks`), các task con bên trong tệp import sẽ hiển thị đầy đủ.
  * Có thể sử dụng tính năng nhảy tới task con qua `--start-at-task`.
* **Ảnh hưởng của câu lệnh điều kiện (`when`)**:
  * > [!IMPORTANT]
    > Khi đặt điều kiện `when` ở câu lệnh `import_tasks`, Ansible sẽ **áp dụng điều kiện đó lên từng task con** bên trong tệp được import. Từng task con sẽ tự động thực hiện phép kiểm tra điều kiện đó trước khi chạy.

### 2.2. Cơ chế Động - Include (`include_tasks`, `include_vars`, `include_role`)
* **Thời điểm xử lý**: Run-time (chỉ xử lý khi luồng thực thi chạy tới vị trí của tác vụ đó trong Playbook).
* **Lỗi cú pháp**: Nếu tệp include có lỗi logic hoặc không tồn tại, Playbook chỉ báo lỗi **khi chạy tới chính xác task include đó**.
* **Tính năng hỗ trợ**:
  * **Hỗ trợ đầy đủ** vòng lặp động và các điều kiện phức tạp được quyết định trong quá trình thực thi Playbook.
  * Khi liệt kê danh sách task (`--list-tasks`), các task con bên trong file include sẽ **không hiển thị** (chỉ hiển thị bản thân task include chính).
  * Không thể nhảy trực tiếp vào task con bằng `--start-at-task`.
  * Không thể kích hoạt handler nằm bên trong tệp include bằng từ khóa `notify` từ tệp playbook chính.
* **Ảnh hưởng của câu lệnh điều kiện (`when`)**:
  * > [!IMPORTANT]
    > Khi đặt điều kiện `when` ở câu lệnh `include_tasks`, điều kiện chỉ được đánh giá cho bản thân task include đó. Nếu điều kiện đúng, tệp include sẽ được nạp và **tất cả các task con bên trong nó sẽ chạy vô điều kiện** (trừ phi các task con tự có `when` riêng của chúng).

---

## 3. Khai báo Biến truyền vào Task/Playbook ngoài

Để tối ưu hóa tính tái sử dụng, hãy viết các tệp task con một cách tổng quát bằng biến số, sau đó truyền giá trị biến vào khi thực hiện import/include:

* **Tệp task con (`tasks/manage_service.yml`)**:
  ```yaml
  - name: Cài đặt gói phần mềm
    ansible.builtin.dnf:
      name: "{{ package }}"
      state: present
  ```
* **Tệp Playbook chính**:
  ```yaml
  tasks:
    - name: Cài đặt và cấu hình HTTPD
      ansible.builtin.import_tasks: tasks/manage_service.yml
      vars:
        package: httpd
  ```

---

## 4. Kỹ thuật Lọc Máy chủ Đích (Host Patterns)

Từ khóa `hosts:` quyết định máy chủ nào sẽ chạy Play. Việc chọn lựa chính xác nhóm máy chủ qua toán tử logic và ký tự đại diện giúp chạy Playbook an toàn và tường minh.

### 4.1. Ký tự đại diện và Nhóm đặc biệt
* **Ký tự sao `*`**: Đại diện cho mọi chuỗi. Ví dụ: `hosts: '*.example.com'` (khớp mọi host đuôi .example.com), `hosts: '192.168.1.*'`.
* **`all` (hoặc `*`)**: Khớp toàn bộ máy chủ trong inventory.
* **`ungrouped`**: Khớp các máy chủ không nằm trong bất kỳ nhóm tùy biến nào.

### 4.2. Các toán tử logic trong Host Patterns
* **Toán tử VÀ (`&`)**: Khớp máy chủ đồng thời nằm ở cả hai nhóm.
  * Ví dụ: `hosts: 'services,&texas'` (Chỉ các máy chủ thuộc nhóm `services` đồng thời cũng phải thuộc nhóm `texas`).
* **Toán tử PHỦ ĐỊNH (`!`)**: Loại trừ máy chủ hoặc nhóm cụ thể.
  * Ví dụ: `hosts: 'services,!db2-california.example.com'` (Chọn tất cả các host trong nhóm `services` ngoại trừ host db2-california).

> [!WARNING]
> Các ký tự toán tử đặc biệt như `!`, `*`, `&` trùng với quy ước cú pháp của tệp YAML. Do đó, khi viết host patterns chứa các ký tự này, **bắt buộc phải bao quanh bằng dấu nháy đơn** để tránh lỗi parse lỗi cú pháp.
> * Sai: `hosts: !db_servers`
> * Đúng: `hosts: '!db_servers'`

### 4.3. Xem trước danh sách máy chủ bị tác động (Preview Hosts)
Để đảm bảo an toàn trước khi chạy thật một Playbook có cấu hình host phức tạp, sử dụng cờ `--list-hosts`:
```bash
ansible-navigator run playbook.yml --list-hosts
```
Lệnh này chỉ in ra danh sách các IP/Hostname sẽ bị tác động bởi playbook mà không thực hiện bất kỳ thay đổi nào.
