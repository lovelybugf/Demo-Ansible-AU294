# K8s Cluster Operations Playbooks (GitOps Repository)

Kho lưu trữ kịch bản Ansible mẫu chuẩn dùng để quản trị và vận hành cụm Kubernetes 2 Nodes (`k8s-master` & `k8s-worker`) thông qua **AWX**.

## 📁 Cấu trúc dự án
*   **`playbooks/`**: Chứa các kịch bản chạy tác vụ cụ thể trên cụm.
    *   `system_update.yml`: Cập nhật hệ điều hành và nâng cấp phần mềm an toàn.
    *   `check_k8s_status.yml`: Kiểm tra trạng thái cụm K8s (chỉ chạy lệnh trên Master Node).
    *   `disk_space_cleanup.yml`: Giám sát và dọn dẹp dung lượng lưu trữ trên phân vùng `/data`.
*   **`group_vars/`**: Định nghĩa biến môi trường cho các nhóm máy chủ.
*   **`roles/`**: Đóng gói các tác vụ cấu hình dùng chung.

## 🚀 Hướng dẫn tích hợp với AWX
1.  **Tạo Repo mới trên GitHub** và đẩy toàn bộ nội dung thư mục này lên Repo đó.
2.  Trên giao diện **AWX**, tạo một **Project** mới và dán link GitHub của bạn vào mục **Source Control URL**.
3.  Tạo các **Job Templates** tương ứng với các playbook trong thư mục `playbooks/` để thực thi chỉ với một nút bấm.
