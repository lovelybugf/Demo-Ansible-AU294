# Chương 8: Tự động hóa Tác vụ Quản trị Hệ thống Linux

Chương này tổng hợp các module và System Roles cốt lõi để tự động hóa các công việc quản trị Linux hàng ngày, bao gồm quản trị người dùng, SSH/Sudo, phần mềm/subscription, tiến trình/boot, đĩa lưu trữ (LVM/Swap) và mạng/firewall.

---

## 1. Sử dụng RHEL System Roles

**RHEL System Roles** là bộ các Ansible Role được thiết kế, thử nghiệm và hỗ trợ chính thức bởi Red Hat giúp cấu hình các hệ thống con của Linux một cách nhất quán qua nhiều phiên bản RHEL mà không cần viết logic điều kiện phức tạp.
* **timesync (`redhat.rhel_system_roles.timesync`)**: Tự động cấu hình đồng bộ thời gian NTP. Role tự chọn dùng `chronyd` (RHEL 8+) hoặc `ntpd` (RHEL cũ).
* **firewall (`redhat.rhel_system_roles.firewall`)**: Quản lý tường lửa, tự trỏ vào backend `firewalld` (RHEL 7+) hoặc `iptables` (RHEL cũ).
* **network (`redhat.rhel_system_roles.network`)**: Cấu hình mạng thông qua NetworkManager API.
* **selinux (`redhat.rhel_system_roles.selinux`)**: Quản lý chế độ SELinux (enforcing/permissive), booleans, ports và contexts.
  * *Xử lý khởi động lại khi đổi trạng thái SELinux*: Đặt role trong khối `block/rescue`, nếu role yêu cầu reboot (biến `selinux_reboot_required` trả về `true`), playbook tự động chạy `ansible.builtin.reboot` rồi áp dụng lại role.

---

## 2. Quản lý Phần mềm và Kho lưu trữ (Software & Subscriptions)

### 2.1. Quản lý gói cài đặt bằng `ansible.builtin.dnf`
* **`state`**: `present` (cài đặt nếu thiếu), `absent` (gỡ bỏ), `latest` (nâng cấp lên bản mới nhất).
* Các tham số bổ sung: `enablerepo` (bật repo tạm thời), `disablerepo` (tắt repo tạm thời), `download_only: true` (chỉ tải về không cài), `autoremove: true` (tự động xóa dependencies thừa).
* **Tối ưu hóa**: Để cài nhiều gói phần mềm trong một giao dịch duy nhất (nhanh hơn), hãy viết danh sách dưới tham số `name` thay vì dùng vòng lặp `loop`:
  ```yaml
  ansible.builtin.dnf:
    name:
      - httpd
      - httpd-tools
    state: present
  ```

### 2.2. Kiểm tra phần mềm đã cài đặt (`package_facts`)
* Module `ansible.builtin.package_facts` thu thập danh sách phần mềm đã cài đặt và lưu vào biến `ansible_facts['packages']`. Dùng để rẽ nhánh điều kiện:
  ```yaml
  when: "'httpd' in ansible_facts['packages']"
  ```

### 2.3. Cấu hình Kho lưu trữ (Repository & GPG keys)
* **`ansible.builtin.yum_repository`**: Khai báo tệp `.repo` trong `/etc/yum.repos.d/`.
  * Các tham số chính: `file` (tên file không cần đuôi .repo), `name`, `baseurl`, `gpgcheck`, `state`.
* **`ansible.builtin.rpm_key`**: Nhập khóa GPG để xác thực gói tin. Hỗ trợ xác thực vân tay khóa qua tham số `fingerprint`.

### 2.4. Đăng ký Bản quyền Hệ thống (`rhc` Role)
* Role `redhat.rhel_system_roles.rhc` giúp đăng ký bản quyền RHEL tự động lên Red Hat Subscription Management. Hỗ trợ tự động attach subscription (qua cơ chế Simple Content Access - SCA trên RHEL 10) và bật repo mặc định (`baseos`, `appstream`).

---

## 3. Quản trị Người dùng, SSH và Sudoers

* **`ansible.builtin.user`**: Quản lý tài khoản người dùng Linux.
  * Sử dụng tham số `groups` kèm `append: true` để bổ sung nhóm mà không xóa các nhóm phụ cũ.
  * Mật khẩu truyền vào bắt buộc phải được mã hóa băm (hashed).
  * Sử dụng `system: true` để tạo tài khoản dịch vụ hệ thống không có shell đăng nhập.
* **`ansible.posix.authorized_key`**: Quản lý khóa công khai SSH trong file `authorized_keys` của user:
  ```yaml
  ansible.posix.authorized_key:
    user: devops
    key: "{{ lookup('ansible.builtin.file', '~/.ssh/id_rsa.pub') }}"
    state: present
  ```
* **`ansible.builtin.known_hosts`**: Quản lý tệp `known_hosts` hệ thống để lưu fingerprint các máy chủ tin cậy.
* **Cấu hình đặc quyền Sudoer**: Sử dụng `lineinfile` tạo tệp cấu hình trong thư mục `/etc/sudoers.d/`. Bắt buộc dùng tham số `validate` để kiểm tra lỗi cú pháp trước khi lưu tệp:
  ```yaml
  ansible.builtin.lineinfile:
    path: /etc/sudoers.d/devops
    line: "devops ALL=(ALL) NOPASSWD: ALL"
    validate: /usr/sbin/visudo -cf %s # %s là đường dẫn file tạm thời
  ```

---

## 4. Quản lý Tiến trình, Boot target và Khởi động lại (Reboot)

* **Lập lịch chạy 1 lần**: Module `ansible.posix.at` (tương ứng lệnh `at` của Linux).
* **Lập lịch chạy định kỳ**: Module `ansible.builtin.cron` (tương ứng cron job). Các thuộc tính thời gian: `minute`, `hour`, `day`, `month`, `weekday`. Để cấu hình sạch sẽ, sử dụng `cron_file` để lưu cấu hình vào `/etc/cron.d/` thay vì lưu chung trong crontab của user.
* **Quản lý Dịch vụ**: Module `ansible.builtin.systemd_service` quản lý trạng thái dịch vụ và timer units (ví dụ: `dnf-makecache.timer`). Sử dụng `daemon_reload: true` để nạp lại cấu hình systemd khi có thay đổi.
* **Đổi Target khởi động mặc định**: Module `ansible.builtin.systemd` thiết lập mục tiêu boot mặc định (ví dụ `multi-user.target` thay vì GUI):
  ```yaml
  ansible.builtin.systemd:
    name: multi-user.target
    default: true
    scope: system
  ```
* **Khởi động lại hệ thống**: Module `ansible.builtin.reboot` thực hiện khởi động lại máy con và **đợi cho đến khi máy con phản hồi SSH thành công** (thông qua lệnh kiểm tra mặc định là `whoami`) mới chuyển sang chạy task tiếp theo. Có thể điều chỉnh thời gian chờ tối đa qua `reboot_timeout`.

---

## 5. Tự động hóa Lưu trữ đĩa (Storage Tasks)

### 5.1. Mount phân vùng đĩa bằng `ansible.posix.mount`
* Module quản lý ánh xạ thiết bị và ghi nhận vào `/etc/fstab`.
* Giá trị `state`: `mounted` (vừa ghi fstab vừa mount ngay), `present` (chỉ ghi fstab), `unmounted` (mount tạm thời bị ngắt nhưng giữ cấu hình fstab), `absent` (ngắt mount và xóa khỏi fstab).
* Khuyến khích mount đĩa cục bộ thông qua mã định danh duy nhất `UUID` thay vì tên thiết bị `/dev/sdb1` để tránh bị tráo đổi khi khởi động lại.

### 5.2. Quản lý Storage bằng System Role (`storage` Role)
Role `redhat.rhel_system_roles.storage` hỗ trợ cấu hình đĩa vật lý, LVM và Swap tự động thông qua khai báo cấu trúc dữ liệu:
* **Cấu hình Đĩa trơn**: Khai báo đĩa đích trong `storage_volumes` với `type: disk`.
* **Cấu hình LVM (Volume Group & Logical Volume)**:
  ```yaml
  storage_pools:
    - name: vg01              # Tên Volume Group
      type: lvm
      disks:
        - vdb                 # Đĩa vật lý (phải chưa phân vùng)
      volumes:
        - name: lvol01        # Tên Logical Volume
          size: 12g           # Định lượng dung lượng (viết chữ thường g/m/t)
          mount_point: /data  # Thư mục mount
          fs_type: xfs
          state: present
  ```
* **Cấu hình Swap Space**: Định nghĩa phân vùng với `fs_type: swap` bên dưới LVM volumes, hệ thống tự động khởi tạo swap và kích hoạt ghi vào fstab.

### 5.3. Tra cứu Facts ổ đĩa
* `ansible_facts['devices']`: Chứa thông tin cấu trúc đĩa vật lý và phân vùng hiện có.
* `ansible_facts['mounts']`: Chứa thông tin về các phân vùng đang được mount thực tế (được dùng để lọc tính toán dung lượng trống của phân vùng `/`).

---

## 6. Cấu hình Mạng và Firewall (Network Tasks)

* **`redhat.rhel_system_roles.network`**: Cấu hình các kết nối mạng qua biến `network_connections`.
  ```yaml
  network_connections:
    - name: ens4
      type: ethernet
      state: up
      ip:
        address:
          - 172.25.250.30/24
  ```
* **`ansible.builtin.hostname`**: Thiết lập hostname cho máy con mà không sửa file `/etc/hosts` trực tiếp.
* **`ansible.posix.firewalld`**: Khai báo luật tường lửa, hỗ trợ mở cổng `port`, mở dịch vụ `service`, hoặc cấu hình interface vào phân vùng `zone` (ví dụ `zone: external`). Đặt `permanent: true` để lưu luật vĩnh viễn qua các lần reboot.
