# Chương 7: Tái sử dụng Code với Roles & Collections

Chương này đi sâu vào khái niệm Ansible Role, cấu trúc thư mục tiêu chuẩn của một Role, cách sử dụng và cấu hình Role trong Playbook, cách quản lý các phụ thuộc qua tệp `requirements.yml` và khái niệm Ansible Content Collections.

---

## 1. Khái niệm và Vai trò của Ansible Roles

Khi Playbook phình to và xử lý nhiều tác vụ phức tạp, việc copy các task giống nhau sang các playbook khác nhau sẽ gây ra lỗi và khó bảo trì.
* **Ansible Role** là giải pháp đóng gói mã nguồn tự động hóa thành một đơn vị module độc lập, có cấu trúc thư mục tiêu chuẩn rõ ràng.
* **Lợi ích**:
  * **Tách biệt dữ liệu và logic**: Giúp logic của Role mang tính tổng quát, các tham số cụ thể được cấu hình linh hoạt thông qua biến số truyền vào.
  * **Tái sử dụng**: Có thể chia sẻ Role giữa nhiều dự án, phòng ban hoặc tải lên các thư viện dùng chung.
  * **Phát triển song song**: Nhiều lập trình viên có thể viết các Role độc lập cùng một lúc mà không sợ xung đột code.

---

## 2. Cấu trúc Thư mục chuẩn của một Ansible Role

Một Role có cấu trúc thư mục cố định để Ansible tự động nhận diện các tài nguyên liên quan mà không cần chỉ định đường dẫn tuyệt đối:

```text
roles/rolename/
├── defaults/
│   └── main.yml         # Khai báo các biến mặc định (Độ ưu tiên THẤP NHẤT)
├── vars/
│   └── main.yml         # Khai báo biến nội bộ của role (Độ ưu tiên TRUNG/CAO)
├── tasks/
│   └── main.yml         # Chứa danh sách các task thực thi chính của role
├── handlers/
│   └── main.yml         # Khai báo các handler của role
├── files/               # Thư mục chứa các tệp tĩnh (được gọi trực tiếp bằng copy/script)
├── templates/           # Thư mục chứa các tệp template Jinja2 (.j2)
├── meta/
│   └── main.yml         # Khai báo siêu dữ liệu (tác giả, license, platforms) và vai trò phụ thuộc (dependencies)
├── tests/               # Chứa inventory và playbook mẫu để kiểm thử role
└── README.md            # Tài liệu hướng dẫn sử dụng role
```

> [!TIP]
> Bạn không cần phải giữ lại toàn bộ các thư mục trên. Nếu một role không sử dụng template hay files, hãy xóa bỏ thư mục đó để cấu trúc thư mục role được gọn gàng, dễ nhìn.

---

## 3. Khác biệt giữa defaults/main.yml và vars/main.yml

| Đặc tính |defaults/main.yml | vars/main.yml |
| :--- | :--- | :--- |
| **Độ ưu tiên** | **Thấp nhất** (Dễ bị ghi đè nhất) | **Trung/Cao** (Khó bị ghi đè) |
| **Mục đích sử dụng** | Định nghĩa các giá trị mặc định ban đầu mà người dùng playbook thường xuyên muốn thay đổi (ví dụ: Port, Username, Phiên bản gói cài đặt). | Định nghĩa các hằng số hoặc biến nội bộ phục vụ logic hoạt động cốt lõi của role, không khuyến khích người dùng sửa đổi. |

---

## 4. Cách gọi và sử dụng Roles trong Playbook

Có hai phương pháp chính để gọi Role trong một Play:

### 4.1. Sử dụng khối lệnh `roles` chuyên biệt (Cách truyền thống)
Khai báo trực tiếp dưới từ khóa `roles` ở cấp Play:
```yaml
---
- name: Cai dat Web Server
  hosts: webservers
  roles:
    - role: common_setup
    - role: apache
      vars:
        http_port: 8080 # Truyền biến ghi đè mặc định của role
```

#### Thứ tự thực thi của Playbook chứa khối `roles`
Khi chạy một Play chứa đầy đủ các phân đoạn, Ansible sẽ thực thi theo thứ tự nghiêm ngặt sau:
1. Các task trong khối **`pre_tasks`**.
2. Các **Handlers** được kích hoạt bởi `pre_tasks`.
3. Toàn bộ các **Roles** khai báo trong khối `roles` (luôn chạy trước tasks chính).
4. Các task trong khối **`tasks`** chính.
5. Các **Handlers** được kích hoạt bởi `roles` và `tasks`.
6. Các task trong khối **`post_tasks`**.
7. Các **Handlers** được kích hoạt bởi `post_tasks`.

### 4.2. Gọi Role dưới dạng một Task (`import_role` và `include_role`)
Đây là phương pháp hiện đại và linh hoạt nhất, giúp kiểm soát chính xác thứ tự chạy của role xen kẽ với các task thông thường:
* **`ansible.builtin.import_role` (Tĩnh)**: Nạp role tại thời điểm parse-time. Vòng lặp và điều kiện `when` của task gọi role sẽ được áp dụng trực tiếp lên từng task con bên trong role đó.
* **`ansible.builtin.include_role` (Động)**: Nạp role tại thời điểm run-time. Vòng lặp và điều kiện `when` chỉ quyết định xem role đó có được chạy hay không. Biến và handler nội bộ của role động không bị lộ ra toàn cục Playbook.

```yaml
  tasks:
    - name: Chạy task chuẩn bị
      ansible.builtin.debug:
        msg: "Bắt đầu cài đặt"
        
    - name: Gọi Apache role động
      ansible.builtin.include_role:
        name: apache
      when: install_webserver | default(true)
```

---

## 5. Tự khởi tạo cấu trúc Role (Role Skeleton)

Sử dụng lệnh `ansible-galaxy` để tự động tạo cấu trúc thư mục trống chuẩn hóa cho một role mới:
```bash
ansible-galaxy role init roles/my_new_role
```

---

## 6. Định nghĩa Vai trò phụ thuộc (Role Dependencies)

Một role phức tạp có thể phụ thuộc vào các role khác (ví dụ: role `app_server` cần chạy role `database` và `web_server` trước).
* Cấu hình khai báo trong tệp `meta/main.yml` của role:
  ```yaml
  dependencies:
    - role: geerlingguy.mysql
      vars:
        mysql_db_name: app_db
    - role: geerlingguy.nginx
  ```

---

## 7. Khai báo cài đặt các Role bên ngoài (Requirements File)

Khi dự án cần tải các role từ Ansible Galaxy, Git repository hoặc tệp nén `.tar`, ta sử dụng tệp quản lý phụ thuộc `roles/requirements.yml`:

```yaml
---
# Tải từ Ansible Galaxy phiên bản mới nhất
- src: geerlingguy.nginx

# Tải từ Ansible Galaxy bản chỉ định
- src: geerlingguy.mysql
  version: "3.2.0"
  name: mysql_db

# Tải từ kho Git riêng qua HTTPS
- src: https://github.com/example/ansible-role-security.git
  scm: git
  version: main
  name: security_hardening
```

* **Lệnh cài đặt**:
  ```bash
  ansible-galaxy role install -r roles/requirements.yml -p roles/
  ```
  *(Sử dụng cờ `-p roles/` để tải các role trực tiếp vào thư mục dự án cục bộ, giúp Execution Environment của `ansible-navigator` có thể truy cập được)*.

---

## 8. Khái niệm Ansible Content Collections

* Trước đây, tất cả module và plugin đều đi kèm trực tiếp trong nhân Ansible. Điều này gây khó khăn cho các bên thứ ba (như Cisco, AWS, F5) khi muốn cập nhật module của họ mà không phải chờ bản cập nhật nhân của Ansible.
* **Collections** là giải pháp phân tách nội dung. Một Collection chứa các Module, Roles, Plugins liên quan tới nhau, được đóng gói và đặt tên theo định dạng Không gian tên FQCN (Fully Qualified Collection Name):
  * Cú pháp: `<namespace>.<collection_name>.<resource_name>`
  * Ví dụ: `community.mysql.mysql_user` (Module quản lý user mysql từ collection mysql của community).
* **Quản lý cài đặt Collections**:
  Khai báo danh sách collection cần dùng trong `collections/requirements.yml`:
  ```yaml
  ---
  collections:
    - name: community.general
    - name: redhat.rhel_system_roles
  ```
  * Lệnh cài đặt: `ansible-galaxy collection install -r collections/requirements.yml -p collections/`
