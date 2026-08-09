# Chương 3: Sử dụng Biến & Mã hóa Ansible Vault

Chương này đi sâu vào việc định nghĩa, tổ chức biến số một cách khoa học, cơ chế thu thập thông tin hệ thống động (Facts), các biến đặc biệt (Magic Variables) và cách bảo vệ dữ liệu nhạy cảm bằng Ansible Vault.

---

## 1. Khai báo và Sử dụng Biến (Variables)

### 1.1. Quy tắc đặt tên biến
* Chỉ được chứa chữ cái, chữ số và dấu gạch dưới `_`.
* Phải bắt đầu bằng một chữ cái hoặc dấu gạch dưới (Không bắt đầu bằng số).
* Không trùng với các từ khóa hệ thống của Python hoặc từ khóa cấu trúc của Playbook (ví dụ: `hosts`, `tasks`, `import`, `with`, v.v.).

### 1.2. Độ ưu tiên của Biến (Variable Precedence)
Khi một biến được khai báo ở nhiều nơi với các giá trị khác nhau, Ansible sẽ chọn giá trị có **độ ưu tiên cao nhất** theo thứ tự từ thấp đến cao (càng cục bộ/hẹp thì càng ưu tiên):

1. Biến nhóm trong Inventory (Group variables in inventory) - *Thấp nhất*
2. Biến nhóm trong thư mục `group_vars/`
3. Biến host trong Inventory (Host variables in inventory)
4. Biến host trong thư mục `host_vars/`
5. Thông tin hệ thống thu thập động (Host facts)
6. Biến Playbook khai báo trực tiếp (`vars` và `vars_files` trong play)
7. Biến cấp Task (Task variables)
8. Biến truyền trực tiếp qua dòng lệnh CLI (`--extra-vars` hoặc `-e`) - *Cao nhất*

### 1.3. Khai báo biến qua cấu trúc thư mục `group_vars` và `host_vars`
Thay vì nhồi nhét biến vào tệp inventory tĩnh gây khó quản lý, khuyến nghị tách các biến ra hai thư mục nằm cùng cấp với tệp inventory hoặc playbook:
* **`group_vars/`**: Chứa các tệp YAML trùng tên với nhóm máy chủ (ví dụ: `webservers.yml`, `db_servers.yml`, hoặc `all.yml` áp dụng cho tất cả).
* **`host_vars/`**: Chứa các tệp YAML trùng tên với từng máy chủ cụ thể (ví dụ: `web1.example.com.yml`).

> [!NOTE]
> Nếu thư mục này tồn tại ở cả nơi chứa inventory lẫn nơi chứa playbook, Ansible sẽ đọc cả hai, nhưng giá trị ở thư mục nằm cùng cấp với **playbook** sẽ ghi đè và có độ ưu tiên cao hơn.

### 1.4. Truy cập biến dạng Từ điển (Dictionary) và Danh sách (List)
* **Kiểu từ điển (Dictionary)**: Khuyên dùng cú pháp ngoặc vuông thay vì dấu chấm để tránh xung đột với các hàm dựng sẵn của Python:
  * Khuyên dùng: `{{ users['bjones']['first_name'] }}`
  * Không khuyến khích: `{{ users.bjones.first_name }}`
* **Kiểu danh sách (List)**: Truy cập theo chỉ mục index (bắt đầu từ 0):
  * Ví dụ: `{{ users[0]['name'] }}`

### 1.5. Ký tự bắt buộc khi gọi biến trong YAML
> [!IMPORTANT]
> Khi sử dụng cú pháp gọi biến Jinja2 `{{ ... }}` đứng ở **ngay đầu giá trị** của một key trong YAML, bắt buộc phải bao quanh nó bằng dấu nháy kép `""`. Nếu không, trình biên dịch YAML sẽ hiểu nhầm dấu `{` là bắt đầu của một từ điển YAML và báo lỗi cú pháp.
> * **Sai**: `name: {{ pkg_name }}`
> * **Đúng**: `name: "{{ pkg_name }}"`

### 1.6. Đăng ký biến lưu kết quả (Register Variables)
Sử dụng từ khóa `register` để chụp lại toàn bộ đầu ra (stdout, stderr, trạng thái thay đổi) của một task và lưu vào một biến để dùng cho các task sau:
```yaml
- name: Cai dat httpd
  ansible.builtin.dnf:
    name: httpd
    state: present
  register: install_result

- name: In ket qua ra terminal
  ansible.builtin.debug:
    var: install_result # Dùng tham số "var" thì không cần ngoặc kép và {{ }}
```

---

## 2. Thu thập Thông tin Máy con (Ansible Facts)

### 2.1. Ansible Facts là gì?
Là các biến đặc biệt chứa thông tin phần cứng, mạng, hệ điều hành hiện tại của máy con, được thu thập tự động bởi module `ansible.builtin.setup` vào đầu mỗi play (gọi là task `Gathering Facts`).
* Tất cả được lưu trong biến lớn `ansible_facts`. Ví dụ: `ansible_facts['hostname']`, `ansible_facts['default_ipv4']['address']`.

### 2.2. Tối ưu hóa và tắt Gathering Facts
Nếu playbook không dùng tới Facts, hãy tắt nó để tăng tốc độ chạy playbook và giảm tải cho máy con:
```yaml
- name: Playbook khong lay facts
  hosts: all
  gather_facts: false
```
* Hoặc chỉ lấy một nhóm facts cụ thể thông qua cấu hình module `setup`:
  ```yaml
  - name: Chi lay thong tin hardware
    ansible.builtin.setup:
      gather_subset:
        - hardware
  ```

### 2.3. Tạo Fact tùy biến cục bộ (Custom Facts)
* Máy con có thể tự định nghĩa facts riêng bằng cách tạo tệp định dạng `.fact` (chỉ chấp nhận INI hoặc JSON) đặt trong thư mục `/etc/ansible/facts.d/` trên máy con.
* Khi Ansible chạy fact gathering, các thông tin này được đọc và lưu vào biến `ansible_facts['ansible_local']`.

### 2.4. Lưu trữ Facts của máy con lên Control Node
Ta có thể xuất thông tin facts thành tệp JSON lưu trên Control Node để phục vụ giám sát bằng cách ủy quyền tác vụ về `localhost`:
```yaml
- name: Lưu facts
  ansible.builtin.copy:
    content: "{{ ansible_facts | to_nice_json }}"
    dest: "/tmp/facts/{{ inventory_hostname }}.json"
  delegate_to: localhost
```

### 2.5. Tạo biến tạm bằng `ansible.builtin.set_fact`
Dùng để tạo hoặc cập nhật giá trị biến động trực tiếp trong quá trình chạy playbook (biến này gắn liền với host hiện hành):
```yaml
- name: Rut ngan bien de doc
  ansible.builtin.set_fact:
    my_ip: "{{ ansible_facts['default_ipv4']['address'] }}"
```

---

## 3. Biến đặc biệt (Magic Variables)

Ansible tự động quản lý một số biến ma thuật để truy xuất thông tin phân bổ cấu hình:
* **`hostvars`**: Cho phép truy cập biến và facts của một máy chủ khác trong inventory. Ví dụ: `{{ hostvars['db1.example.com']['ansible_facts']['default_ipv4']['address'] }}`.
* **`inventory_hostname`**: Tên định danh của máy chủ hiện hành được cấu hình trong Inventory (có thể khác với hostname thực tế của OS).
* **`group_names`**: Liệt kê danh sách tất cả các nhóm mà máy chủ hiện hành đang trực thuộc.
* **`groups`**: Chứa toàn bộ bản đồ inventory (danh sách nhóm và các host tương ứng).

---

## 4. Bảo vệ Dữ liệu Nhạy cảm với Ansible Vault

**Ansible Vault** là công cụ mã hóa đối xứng (AES-256) giúp bảo vệ các thông tin nhạy cảm như mật khẩu, API keys, chứng chỉ bảo mật dưới dạng tệp văn bản mã hóa để lưu an toàn trên Git.

### 4.1. Các lệnh thao tác tệp tin mã hóa cơ bản
* **Tạo tệp mới mã hóa**:
  ```bash
  ansible-vault create secret.yml
  ```
* **Xem nội dung tệp mã hóa (không chỉnh sửa)**:
  ```bash
  ansible-vault view secret.yml
  ```
* **Chỉnh sửa tệp đang mã hóa**:
  ```bash
  ansible-vault edit secret.yml
  ```
* **Mã hóa một tệp đang ở dạng văn bản thuần**:
  ```bash
  ansible-vault encrypt plain.yml
  ```
* **Giải mã vĩnh viễn tệp về dạng văn bản thuần**:
  ```bash
  ansible-vault decrypt secret.yml
  ```
* **Thay đổi mật khẩu mã hóa**:
  ```bash
  ansible-vault rekey secret.yml
  ```

### 4.2. Chạy Playbook chứa dữ liệu mã hóa
Khi chạy playbook có tham chiếu tệp biến bị mã hóa, bắt buộc phải cung cấp mật khẩu giải mã:
* Nhập mật khẩu thủ công:
  ```bash
  ansible-navigator run playbook.yml --ask-vault-pass
  ```
* Sử dụng tệp chứa mật khẩu sẵn (cấu hình trong `ansible.cfg` qua biến `vault_password_file = /path/to/password_file` để tự động chạy không tương tác).
