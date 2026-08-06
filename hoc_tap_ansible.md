# LỘ TRÌNH & TÀI LIỆU HỌC ANSIBLE CHUẨN RED HAT

Tài liệu này được tổng hợp từ hai chương tài liệu tham khảo Red Hat của bạn:
1. **Chapter 1: An Introduction to Ansible** (Giới thiệu & Cấu hình môi trường)
2. **Chapter 2: Introduction to Developing Automation Content** (Xây dựng Inventory, viết Playbooks & Xử lý sự cố)

Tài liệu được thiết kế riêng để bạn thực hành trực tiếp trên máy ảo **RHEL 10.2 VM** bằng công cụ **`ansible-navigator`** kết hợp với **Podman**.

---

## PHẦN I: CÁC KHÁI NIỆM CỐT LÕI BẠN PHẢI NẮM VỮNG

### 1. Cơ chế hoạt động Agentless (Không cần Agent)
* Ansible không cần cài đặt bất kỳ phần mềm chạy ngầm (Agent) nào trên các máy chủ đích (Managed Hosts).
* Nó kết nối tới các máy Linux/Unix qua **SSH** và các máy Windows qua **WinRM**.
* Khi thực thi, nó đẩy các đoạn chương trình nhỏ gọi là **Ansible modules** sang máy đích, chạy xong sẽ tự động xóa sạch.

### 2. Tính nhất quán (Idempotency)
* Đây là tính chất quan trọng nhất của Ansible. Một playbook có thể chạy đi chạy lại nhiều lần nhưng chỉ thực hiện thay đổi khi trạng thái thực tế của máy đích khác với trạng thái mong muốn được định nghĩa trong code.
* Nếu hệ thống đã ở trạng thái mong muốn, Ansible sẽ chỉ báo cáo là `ok` (không có thay đổi nào) thay vì chạy lại từ đầu.

### 3. Quy tắc cú pháp YAML (Dùng viết Playbook)
* Playbook sử dụng định dạng YAML. Định dạng này **không hỗ trợ phím Tab** để thụt đầu dòng, bạn bắt buộc phải dùng **phím cách (Space)**.
* Các phần tử cùng cấp trong danh sách phải thẳng hàng thẳng cột với nhau (thường thụt lề 2 dấu cách cho mỗi cấp con).
* Một tệp playbook thường bắt đầu bằng ba dấu gạch ngang (`---`).

---

## PHẦN II: CẨM NANG LỆNH THỰC HÀNH TRÊN MÁY ẢO RHEL

Dưới đây là các câu lệnh chính thức bạn sẽ dùng hàng ngày trên máy ảo để quản lý và vận hành Ansible:

| Mục đích | Câu lệnh thực hiện trên RHEL VM | Giải thích |
| :--- | :--- | :--- |
| **Kiểm tra cú pháp** | `ansible-navigator run playbook.yml --syntax-check` | Kiểm tra lỗi chính tả, thụt dòng trước khi chạy thật. |
| **Chạy thử (Dry Run)** | `ansible-navigator run playbook.yml --check` | Chạy giả lập để xem hệ thống sẽ thay đổi những gì (báo `changed`), nhưng không ghi đè thực tế. |
| **Chạy thực tế** | `ansible-navigator run playbook.yml` | Thực thi playbook chạy thật. |
| **Tăng độ chi tiết (Debug)** | `ansible-navigator run playbook.yml -v` | Thêm tham số `-v` (tối đa `-vvvvvv`) để xem chi tiết log kết nối và lỗi. |
| **Xem tài liệu Module** | `ansible-navigator doc ansible.builtin.copy -m stdout` | Tra cứu nhanh tài liệu, các tham số và ví dụ của module `copy`. |
| **Xem mẫu cấu hình** | `ansible-navigator -s doc ansible.builtin.user` | Xuất ra bộ khung (schema) trống của module `user` để copy dán vào code. |
| **Kiểm tra Inventory** | `ansible-navigator inventory -i inventory -m stdout --list` | Liệt kê toàn bộ các máy chủ và nhóm máy chủ dưới dạng JSON. |
| **Vẽ sơ đồ Inventory** | `ansible-navigator inventory -i inventory -m stdout --graph` | Hiển thị cấu trúc phân cấp nhóm máy chủ dạng cây trực quan. |

---

## PHẦN III: BÀI TẬP THỰC HÀNH TỪ DỄ ĐẾN KHÓ (LÀM TRÊN VM)

Bạn hãy tạo các tệp tin playbook này trong thư mục `~/ansible` trên máy ảo RHEL và chạy thử để nâng cao kỹ năng:

### Bài tập 1: Quản lý người dùng (Module `ansible.builtin.user`)
**Mục tiêu**: Tạo ra một tài khoản người dùng mới tên là `ksec_admin` trên hệ thống, tự động gán UID là `3000` và đảm bảo tài khoản này luôn tồn tại.

*Tạo file `practice_user.yml`:*
```yaml
---
- name: Thuc hanh quan ly User
  hosts: localhost
  gather_facts: false
  become: true  # Can quyen root de tao user
  tasks:
    - name: Dam bao user ksec_admin ton tai voi UID 3000
      ansible.builtin.user:
        name: ksec_admin
        uid: 3000
        state: present
        comment: "Tai khoan admin hoc tap"
```
* **Cách chạy**: `ansible-navigator run practice_user.yml -K` (Tham số `-K` để nhập mật khẩu sudo của `ducnam` là `1`).

---

### Bài tập 2: Quản lý tệp tin và dịch vụ (Module `copy` và `systemd_service`)
**Mục tiêu**: Tạo một tệp cấu hình tạm thời và đảm bảo một dịch vụ hệ thống (ví dụ dịch vụ ghi log `rsyslog`) đang được khởi chạy cùng hệ thống.

*Tạo file `practice_system.yml`:*
```yaml
---
- name: Thuc hanh file va dich vu
  hosts: localhost
  gather_facts: false
  become: true
  tasks:
    - name: Tao mot file thong tin he thong
      ansible.builtin.copy:
        content: "Moi truong Ansible RHEL 10 hoat dong vao luc: {{ ansible_date_time.iso8601 | default('unknown') }}\n"
        dest: /tmp/ansible_status.txt
        mode: '0644'

    - name: Dam bao dich vu rsyslog luon chay va khoi dong cung OS
      ansible.builtin.systemd_service:
        name: rsyslog
        state: started
        enabled: true
```

---

### Bài tập 3: Viết Playbook có nhiều Play (Multi-Play Playbook)
**Mục tiêu**: Thực hành viết một playbook chứa nhiều block `Play` khác nhau, chạy tuần tự trên các nhóm host khác nhau hoặc với các tài khoản khác nhau.

*Tạo file `practice_multi_play.yml`:*
```yaml
---
- name: Play thu nhat - Chay khong can quyen root
  hosts: localhost
  gather_facts: false
  become: false
  tasks:
    - name: Ping kiem tra cuc bo
      ansible.builtin.ping:

- name: Play thu hai - Yeu cau quyen root de ghi file he thong
  hosts: localhost
  gather_facts: false
  become: true
  tasks:
    - name: Ghi loi chao vao file /etc/motd (Message of the Day)
      ansible.builtin.copy:
        content: "Chao mung ban den voi may chu Ansible Control Node RHEL 10.2!\n"
        dest: /etc/motd
```

---

## PHẦN IV: CÁC LƯU Ý QUAN TRỌNG KHI HỌC THEO CHUẨN RED HAT

1. **Luôn dùng FQCN (Fully Qualified Collection Name)**:
   * Tránh ghi tên module ngắn gọn như `copy`, `user`, `service`.
   * Hãy tập thói quen ghi đầy đủ họ tên của module: `ansible.builtin.copy`, `ansible.builtin.user`, `ansible.builtin.systemd_service`. Điều này giúp tránh xung đột module khi dự án lớn lên.
2. **Luôn đặt tên (`name`) cho Play và Task**:
   * Tệp playbook chạy bằng `ansible-navigator` hiển thị nhật ký theo tên. Việc đặt tên rõ ràng giúp bạn biết chính xác tác vụ nào đang chạy và lỗi xảy ra ở đâu khi debug.
3. **Tránh lạm dụng các module dòng lệnh tự do (`command`, `shell`, `raw`)**:
   * Tài liệu Red Hat nhấn mạnh các module này không có tính chất *Idempotent* (mỗi lần chạy đều báo `changed` dù không có gì thay đổi). Chỉ sử dụng khi không có module chuyên dụng nào khác đáp ứng được công việc.
