# CHƯƠNG 6 & 7: VẬN HÀNH QUY MÔ LỚN & ANSIBLE ROLES CHUYÊN SÂU

Tài liệu này tổng hợp toàn bộ kiến thức nâng cao, chi tiết kỹ thuật và các quy tắc vận hành dự án Ansible quy mô lớn, tối ưu hóa mã nguồn theo chương trình chuẩn của Red Hat (RH294).

---

## PHẦN I: CHƯƠNG 6 - QUẢN LÝ DỰ ÁN LỚN (IMPORT, INCLUDE & SYSTEM ROLES)

### 1. Phân biệt chi tiết giữa `import_*` (Tĩnh) và `include_*` (Động)

Đây là câu hỏi cốt lõi xuất hiện nhiều nhất trong cả lý thuyết và thực hành. Việc hiểu rõ thời điểm biên dịch giúp bạn tránh các lỗi logic treo hệ thống.

| Tiêu chí | `import_*` (Tĩnh - Static Reusability) | `include_*` (Động - Dynamic Reusability) |
| :--- | :--- | :--- |
| **Bản chất kỹ thuật** | **Compile-time** (Trình biên dịch chèn trực tiếp nội dung tệp con vào tệp chính trước khi thực thi). | **Runtime** (Chỉ đọc và biên dịch tệp con khi tiến trình chạy playbook chạm tới dòng lệnh đó). |
| **Các câu lệnh** | `import_playbook`<br>`import_tasks`<br>`import_role` | `include_tasks`<br>`include_role`<br>`include_vars` |
| **Sử dụng biến trong tên tệp** | **Không thể**. Ví dụ: `import_tasks: "{{ my_file }}.yml"` $\rightarrow$ **Lỗi cú pháp** do lúc biên dịch biến chưa được gán giá trị. | **Hoàn toàn có thể**. Ví dụ: `include_tasks: "{{ ansible_facts['os_family'] }}.yml"` $\rightarrow$ Chạy tốt. |
| **Cơ chế thừa kế điều kiện `when`** | Điều kiện `when` khai báo ở dòng `import_tasks` sẽ được tự động **nhân bản và gán trực tiếp vào từng task con** bên trong tệp được import. | Điều kiện `when` được kiểm tra trước ở file chính; nếu Sai, toàn bộ file con bị bỏ qua ngay lập tức. |
| **Thừa kế Tags (Thẻ phân loại)** | Tất cả các tags áp dụng cho `import_tasks` sẽ tự động thừa kế bởi toàn bộ các task con bên trong. | Tag chỉ áp dụng cho chính hành động include, không tự động gán trực tiếp xuống các task con. |
| **Khả năng kiểm tra trước (`--list-tasks`)** | Có hiển thị các task con khi chạy kiểm tra danh sách tác vụ. | Không hiển thị các task con (chỉ hiển thị khi chạy thực tế). |

#### Ví dụ minh họa sử dụng `import_playbook` (Xây dựng Master Playbook):
Trong các dự án lớn, người ta thường viết một file `site.yml` tổng hợp để gọi lại tuần tự các playbook con:
```yaml
---
# site.yml (Master Playbook)
- import_playbook: web_servers.yml
- import_playbook: db_servers.yml
```

---

### 2. Thu nạp biến động với `include_vars`
Khác với `vars_files` (nạp biến tĩnh ở đầu Play), `include_vars` là một tác vụ động giúp nạp các tệp chứa biến ở giữa quá trình thực thi Playbook dựa trên kết quả của các task trước đó:
```yaml
- name: Nap bien cau hinh rieng cho tung he dieu hanh
  ansible.builtin.include_vars:
    file: "vars/{{ ansible_facts['os_family'] }}.yml"
```

---

### 3. Red Hat System Roles (Các Role hệ thống có sẵn)
Red Hat cung cấp sẵn các Roles đã được tối ưu hóa và kiểm thử nghiêm ngặt để cấu hình các dịch vụ hệ thống RHEL.
* **Cài đặt**: 
  ```bash
  sudo dnf install rhel-system-roles
  ```
* **Vị trí lưu trữ sau cài đặt**: `/usr/share/ansible/roles/`
* **Các Role phổ biến**:
  * `rhel-system-roles.timesync`: Cấu hình NTP/Chrony đồng bộ thời gian.
  * `rhel-system-roles.firewall`: Cấu hình tường lửa Firewalld.
  * `rhel-system-roles.selinux`: Cấu hình SELinux trạng thái và phân quyền.

---

## PHẦN II: CHƯƠNG 7 - THIẾT KẾ MÔ-ĐUN HÓA VỚI ANSIBLE ROLES

### 1. Cấu trúc thư mục chuẩn chỉnh của một Custom Role
Khi chạy lệnh `ansible-galaxy role init roles/my_role`, Ansible tạo ra cây thư mục quy chuẩn:

```text
roles/my_role/
├── defaults/
│   └── main.yml      # Biến mặc định (Độ ưu tiên THẤP NHẤT, dễ ghi đè nhất)
├── vars/
│   └── main.yml      # Biến cố định của Role (Độ ưu tiên CAO, khó ghi đè)
├── tasks/
│   └── main.yml      # Logic thực thi chính của Role
├── handlers/
│   └── main.yml      # Các trình xử lý sự kiện (restart dịch vụ...) của riêng Role
├── templates/        # Nơi chứa các file cấu hình động dạng Jinja2 (.j2)
├── files/            # Nơi chứa các file tĩnh (không cần biên dịch) để copy sang máy con
├── meta/
│   └── main.yml      # Khai báo thông tin Role và Role Dependencies (Role phụ thuộc)
└── tests/            # Chứa inventory và playbook chạy thử nghiệm của Role
```

---

### 2. Thứ tự thực thi chuẩn trong một Playbook (Execution Order)
Khi một Playbook chứa cả `pre_tasks`, `roles`, `tasks`, `post_tasks` và các `handlers`, thứ tự chạy được Ansible thực hiện nghiêm ngặt theo các bước sau (đây là câu hỏi thi lý thuyết kinh điển):

```text
1. pre_tasks --> 2. Handlers của pre_tasks --> 3. roles --> 4. tasks --> 5. post_tasks --> 6. Handlers của roles/tasks/post_tasks
```

1. **`pre_tasks`**: Các tác vụ chạy trước tiên (ví dụ: tắt monitor, rút server khỏi Load Balancer).
2. **Handlers** được kích hoạt bởi `pre_tasks`.
3. **`roles`**: Các role được khai báo chạy theo thứ tự liệt kê.
4. **`tasks`**: Các tác vụ thông thường khai báo trong Playbook.
5. **`post_tasks`**: Các tác vụ chạy sau cùng (ví dụ: bật lại monitor, đưa server vào lại Load Balancer).
6. **Handlers** được kích hoạt bởi `roles`, `tasks`, hoặc `post_tasks`.

---

### 3. Quy tắc ưu tiên của Biến (Variable Precedence) trong Role
Ansible có 22 cấp độ ưu tiên của biến. Đối với Role, bạn cần ghi nhớ 4 cấp độ cơ bản sau (sắp xếp từ **thấp đến cao**):

1. **`defaults/main.yml` của Role (Ưu tiên thấp nhất)**:
   * Thường dùng để đặt các cấu hình mặc định (như port=80, user=apache). Người dùng gọi role có thể dễ dàng ghi đè thông số này.
2. **`vars` khai báo trong Playbook chính**:
   * Khi bạn gọi role và khai báo `vars:` ở playbook chính, biến này sẽ đè bẹp biến trong `defaults/main.yml`.
3. **`vars/main.yml` của Role**:
   * Chứa các biến nội bộ của Role mà bạn **không muốn** người dùng ghi đè tùy tiện (ví dụ: đường dẫn hệ thống nội bộ của ứng dụng).
4. **Extra Vars truyền từ dòng lệnh (`-e` hoặc `--extra-vars`) (Ưu tiên cao nhất)**:
   * Đè bẹp tất cả các khai báo ở bất kỳ tệp tin hay vị trí nào khác.

---

### 4. Cách gọi Role linh hoạt trong Playbook

#### Cách 1: Khai báo tĩnh bằng khối `roles:` (Cách truyền thống)
```yaml
- name: Run Web Server Role
  hosts: dev
  roles:
    - role: web_server
      vars:
        http_port: 8080 # Ghi đè biến defaults
```

#### Cách 2: Khai báo động bằng `include_role` (Được khuyên dùng trong lập trình logic)
Cho phép gọi Role như một task bình thường và có thể áp dụng điều kiện `when`:
```yaml
- name: Run tasks
  hosts: dev
  tasks:
    - name: Cai dat database chi tren may Ubuntu
      ansible.builtin.include_role:
        name: db_server
      when: ansible_facts['os_family'] == 'Debian'
```
