# Chương 4: Điều khiển Task: Loops, Conditionals, Handlers & Blocks

Chương này hướng dẫn các kỹ thuật điều khiển luồng thực thi nâng cao trong Playbook, bao gồm vòng lặp (Loops), cấu trúc rẽ nhánh điều kiện (Conditionals), cơ chế kích hoạt sự kiện khi thay đổi (Handlers) và xử lý lỗi hệ thống bằng Blocks.

---

## 1. Vòng lặp trong Ansible (Loops)

Thay vì viết lặp đi lặp lại nhiều task giống nhau cho từng phần tử, Ansible cung cấp cơ chế vòng lặp để duyệt qua danh sách dữ liệu một cách hiệu quả và ngắn gọn.

### 1.1. Vòng lặp đơn giản (Simple Loops)
Sử dụng từ khóa `loop` ở cấp task và truyền danh sách các phần tử. Biến đặc biệt `item` đại diện cho phần tử hiện tại ở mỗi bước duyệt:

```yaml
- name: Đảm bảo các dịch vụ thư điện tử hoạt động
  ansible.builtin.systemd_service:
    name: "{{ item }}"
    state: started
  loop:
    - postfix
    - dovecot
```

### 1.2. Vòng lặp qua Danh sách Từ điển (Dictionaries)
Khi mỗi phần tử chứa nhiều thuộc tính khác nhau, ta có thể định nghĩa danh sách dạng từ điển:

```yaml
- name: Tạo người dùng và gán nhóm tương ứng
  ansible.builtin.user:
    name: "{{ item['name'] }}"
    state: present
    groups: "{{ item['groups'] }}"
  loop:
    - name: jane
      groups: wheel
    - name: joe
      groups: root
```

### 1.3. Cú pháp vòng lặp cũ (`with_X`)
Trong các playbook cũ, bạn sẽ bắt gặp cú pháp `with_items`, `with_file`, `with_sequence`.
* `with_items` tự động làm phẳng (flatten) các danh sách lồng nhau thành một danh sách phẳng duy nhất.
* **Khuyên dùng**: Nên chuyển đổi tất cả sang từ khóa `loop` hiện đại để tối ưu hiệu năng và dễ chuẩn hóa code.

### 1.4. Đăng ký biến lưu kết quả trong vòng lặp (Loop Register)
Khi sử dụng từ khóa `register` kết hợp với `loop`, kết quả trả về của tất cả các lần lặp sẽ được ghi nhận vào một danh sách lớn nằm dưới thuộc tính `.results`:

```yaml
- name: Chạy lệnh echo tuần tự
  ansible.builtin.shell: "echo 'Xin chào {{ item }}'"
  loop:
    - Hùng
    - Dũng
  register: echo_results

- name: In kết quả thu được của từng lần lặp
  ansible.builtin.debug:
    msg: "Kết quả: {{ item['stdout'] }}"
  loop: "{{ echo_results['results'] }}" # Duyệt qua danh sách kết quả đã đăng ký
```

---

## 2. Chạy Task theo Điều kiện (Conditionals)

Sử dụng từ khóa `when` để kiểm tra điều kiện trước khi thực thi một task. Nếu điều kiện đúng (`true`), task sẽ chạy; ngược lại, Ansible sẽ bỏ qua (`skipped`).

### 2.1. Cú pháp và Vị trí đặt câu lệnh `when`
> [!IMPORTANT]
> Từ khóa `when` là một thuộc tính của Task, do đó nó phải được đặt cùng cấp với tên module thực thi, **không thụt lề vào bên trong tham số của module**.

```yaml
- name: Cài đặt Apache trên hệ điều hành RedHat
  ansible.builtin.dnf:
    name: httpd
    state: present
  when: ansible_facts['distribution'] == "RedHat" # Đặt cùng cấp với "dnf"
```

### 2.2. Các toán tử so sánh thường dùng
* **So sánh bằng**: `==` (ví dụ: `ansible_facts['machine'] == "x86_64"`)
* **So sánh số học**: `<`, `>`, `<=`, `>=`, `!=`
* **Kiểm tra định nghĩa biến**: `is defined` hoặc `is not defined`
* **Kiểm tra sự tồn tại trong danh sách**: `in` (ví dụ: `ansible_facts['distribution'] in supported_distros`)
* **Toán tử phủ định**: `not` (ví dụ: `not is_prod_environment`)

### 2.3. Kết hợp nhiều điều kiện
* **Phép VÀ (`and`)**: Cả hai vế đều đúng. Có thể viết dạng danh sách (Ansible tự động hiểu là `and`):
  ```yaml
  when:
    - ansible_facts['distribution'] == "RedHat"
    - ansible_facts['distribution_major_version'] == "10"
  ```
* **Phép HOẶC (`or`)**: Một trong hai vế đúng.
* **Gộp nhóm điều kiện**: Sử dụng dấu ngoặc đơn `(...)` để tạo cấu trúc điều kiện phức tạp. Sử dụng toán tử gấp dòng `>` để viết câu điều kiện dài xuống dòng cho dễ đọc:
  ```yaml
  when: >
    ( ansible_facts['distribution'] == "RedHat" and ansible_facts['distribution_major_version'] == "10" )
    or
    ( ansible_facts['distribution'] == "Fedora" and ansible_facts['distribution_major_version'] == "42" )
  ```

### 2.4. Kết hợp Loop và Conditional
Khi kết hợp `loop` và `when`, câu điều kiện `when` sẽ được **đánh giá riêng cho từng phần tử** trong vòng lặp:
```yaml
- name: Cài đặt dịch vụ nếu ổ cứng root còn trống trên 300MB
  ansible.builtin.dnf:
    name: mariadb-server
    state: present
  loop: "{{ ansible_facts['mounts'] }}"
  when: item['mount'] == "/" and item['size_available'] > 300000000
```

---

## 3. Cơ chế trigger sự kiện (Handlers)

**Handlers** là các tác vụ đặc biệt (thường dùng để khởi động lại dịch vụ hoặc reboot hệ thống) nằm trong danh mục riêng ở cuối play. Chúng chỉ được kích hoạt chạy duy nhất một lần khi và chỉ khi có một task thông thường gửi tín hiệu báo hệ thống có sự thay đổi.

### 3.1. Cách cấu hình Handler

```yaml
  tasks:
    - name: Sao chép tệp tin cấu hình HTTPD
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: Restart Apache # Gửi tín hiệu thông báo

  handlers:
    - name: Restart Apache # Tên phải khớp chính xác với notify
      ansible.builtin.systemd_service:
        name: httpd
        state: restarted
```

### 3.2. Quy tắc hoạt động của Handlers
* **Chỉ chạy khi có thay đổi (`changed`)**: Nếu task sao chép tệp cấu hình kiểm tra thấy tệp đích đã giống hệt tệp nguồn, trạng thái task là `ok` (màu xanh), handler sẽ **không** được gọi.
* **Chạy một lần duy nhất vào cuối Play**: Cho dù có 10 task khác nhau cùng gửi `notify: Restart Apache`, dịch vụ Apache chỉ bị restart đúng **1 lần** duy nhất sau khi tất cả các task thông thường trong play chạy xong.
* **Thứ tự thực thi cố định**: Các handler luôn chạy theo thứ tự khai báo trong khối `handlers:`, chứ không theo thứ tự được gọi bởi `notify`.
* **Kích hoạt chạy sớm (Flushing Handlers)**: Nếu muốn khởi động lại dịch vụ ngay lập tức giữa Play để thực hiện task kiểm tra tính khả dụng ở task tiếp theo, sử dụng module meta:
  ```yaml
  - name: Kích hoạt chạy sớm toàn bộ handlers đã nhận thông báo
    ansible.builtin.meta: flush_handlers
  ```

---

## 4. Kiểm soát lỗi hệ thống (Task Failure Handling)

Khi một task thất bại (lỗi kết nối, thiếu gói cài đặt, lệnh trả về mã lỗi khác 0), mặc định Ansible sẽ dừng ngay lập tức việc chạy Playbook trên host bị lỗi đó.

### 4.1. Bỏ qua lỗi (`ignore_errors`)
Dùng cho tác vụ phụ không ảnh hưởng tới toàn cục, cho phép chạy tiếp playbook dù task bị lỗi:
```yaml
- name: Dừng dịch vụ phụ (nếu có cài đặt)
  ansible.builtin.systemd_service:
    name: optional_service
    state: stopped
  ignore_errors: true # Báo đỏ nhưng vẫn chạy tiếp task sau
```

### 4.2. Bảo toàn Handlers khi gặp lỗi (`force_handlers`)
Nếu Playbook bị dừng giữa chừng do lỗi ở task sau, các handler đã được `notify` ở các task trước đó sẽ bị hủy bỏ. Thiết lập `force_handlers: true` ở cấp Play để bắt buộc thực thi các handler đã được notify trước khi thoát:
```yaml
- name: Playbook bảo toàn cấu hình
  hosts: all
  force_handlers: true # Luôn chạy handler đã notify kể cả khi lỗi
```

### 4.3. Tự định nghĩa điều kiện Thất bại (`failed_when`)
Nhiều lệnh chạy trả về mã lỗi thành công (rc = 0) nhưng kết quả thực tế lại lỗi (ví dụ API trả về trạng thái JSON là `ERROR`). Ta dùng `failed_when` để ép task báo lỗi:
```yaml
- name: Kiểm tra trạng thái máy ảo
  openstack.cloud.server_info:
    name: test-vm
  register: vm_info
  failed_when: vm_info.openstack_servers[0].status != "ACTIVE"
```

### 4.4. Tự định nghĩa điều kiện Thay đổi (`changed_when`)
Giúp giữ tính nhất quán (Idempotency). Một số lệnh validate (ví dụ `nginx -t`) chỉ kiểm tra cú pháp và không làm thay đổi hệ thống. Mặc định Ansible báo `changed` (vàng), ta cần ép nó báo `ok` (xanh):
```yaml
- name: Kiểm tra cấu hình Nginx
  ansible.builtin.command: nginx -t
  changed_when: false # Luôn báo OK (xanh) để tránh kích hoạt sai handler liên quan
```

---

## 5. Sử dụng cấu trúc Blocks để quản lý lỗi (Try-Catch-Finally)

**Blocks** cho phép nhóm các task lại với nhau để áp dụng chung thuộc tính (như `when`, `become`) và cung cấp cơ chế xử lý lỗi tương tự như khối lệnh `try-catch-finally` trong lập trình:

* **`block`**: Chứa các tác vụ chính muốn thực hiện.
* **`rescue`**: Chứa tác vụ sửa sai/khôi phục (Rollback). Chỉ chạy khi có bất kỳ task nào trong phần `block` bị lỗi.
* **`always`**: Luôn thực thi sau khi hoàn thành phần `block` hoặc `rescue`, bất kể tác vụ thành công hay thất bại (thường dùng dọn dẹp tài nguyên tạm, restart dịch vụ cốt lõi).

```yaml
  tasks:
    - name: Thực hiện nâng cấp database có cơ chế phục hồi
      block:
        - name: Chạy script nâng cấp cơ sở dữ liệu
          ansible.builtin.shell: /usr/local/bin/upgrade-db.sh
      rescue:
        - name: Thực hiện khôi phục dữ liệu cũ do nâng cấp lỗi
          ansible.builtin.shell: /usr/local/bin/rollback-db.sh
      always:
        - name: Đảm bảo cơ sở dữ liệu luôn được khởi động lại
          ansible.builtin.systemd_service:
            name: mariadb
            state: restarted
```
