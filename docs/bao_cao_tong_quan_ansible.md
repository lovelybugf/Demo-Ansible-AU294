# BÁO CÁO TỔNG QUAN VỀ ANSIBLE (OVERVIEW REPORT)

Báo cáo này tóm tắt các kiến thức cốt lõi về **Ansible** dựa trên tài liệu lý thuyết chính thức. Nội dung tập trung trả lời 3 câu hỏi lớn: **Ansible là gì? Dùng làm gì? Và có những ưu điểm vượt trội nào?**

---

## 1. Ansible là gì?

**Ansible** là một nền tảng tự động hóa mã nguồn mở chuyên dụng dùng để quản trị hạ tầng dưới dạng mã (**Infrastructure as Code - IaC**). Thay vì cấu hình thủ công từng máy chủ, Ansible cho phép lập trình viên và quản trị viên mô tả trạng thái mong muốn của hệ thống bằng các tệp tin cấu hình văn bản đơn giản.

```mermaid
graph LR
    subgraph Control Node [Máy điều khiển (Control Node)]
        A[Playbooks YAML] --> B[Ansible Engine]
    end
    subgraph Managed Hosts [Máy chủ đích (Managed Hosts)]
        C[Web Server]
        D[Database Server]
        E[Network Switch]
    end
    B -- SSH --> C
    B -- SSH --> D
    B -- API/SSH --> E
    style Control Node fill:#f9f,stroke:#333,stroke-width:2px
    style Managed Hosts fill:#bbf,stroke:#333,stroke-width:2px
```

---

## 2. Các ứng dụng thực tế (Ansible dùng làm gì?)

Ansible giải quyết toàn diện vòng đời vận hành IT thông qua 4 nhóm tác vụ chính:

| Lĩnh vực | Mô tả | Ví dụ thực tế |
| :--- | :--- | :--- |
| **Quản lý cấu hình** *(Configuration Management)* | Đồng bộ cấu hình hệ điều hành và dịch vụ trên hàng loạt server. | Cài đặt package, thay đổi file cấu hình dịch vụ, thiết lập quyền người dùng. |
| **Triển khai ứng dụng** *(Application Deployment)* | Tự động hóa quy trình đưa mã nguồn ứng dụng từ Git lên máy chủ chạy thực tế. | Tải mã nguồn mới, nâng cấp dependencies, khởi chạy dịch vụ (CI/CD). |
| **Điều phối hệ thống** *(Orchestration)* | Quản lý quy trình chạy liên kết giữa nhiều server khác nhau theo một trình tự logic chặt chẽ. | Tắt Load Balancer ➔ Nâng cấp database ➔ Cập nhật Web app ➔ Bật lại Load Balancer. |
| **Cấu hình mạng & Đám mây** *(Network & Cloud Provisioning)* | Khởi tạo tài nguyên đám mây và thiết lập phần cứng thiết bị mạng tự động. | Cấu hình cổng Switch (Cisco/Juniper), tạo máy ảo và mạng ảo VPC (AWS/Azure). |

---

## 3. Các đặc tính vượt trội của Ansible (Ưu điểm)

Sự phổ biến của Ansible đến từ 3 đặc tính cốt lõi tạo nên sự khác biệt so với các đối thủ (như Chef, Puppet):

### 🎛️ 3.1. Kiến trúc không cần Agent (Agentless)
*   **Cơ chế**: Ansible không cài đặt bất kỳ tiến trình ngầm (agent) nào trên máy chủ đích. Nó kết nối qua giao thức tiêu chuẩn có sẵn là **SSH** (với Linux) hoặc **WinRM/WinSSH** (với Windows).
*   **Lợi ích**: 
    *   Tiết kiệm tài nguyên hệ thống (RAM/CPU) trên máy con.
    *   Không tốn công bảo trì, cập nhật phiên bản agent.
    *   Loại bỏ rủi ro bảo mật từ các lỗ hổng phần mềm của agent.

### 🔄 3.2. Tính lũy đẳng (Idempotency)
*   **Cơ chế**: Ansible chỉ thực hiện thay đổi khi phát hiện trạng thái thực tế của hệ thống bị lệch khỏi cấu hình khai báo mong muốn trong code.
*   **Lợi ích**: Đảm bảo an toàn tối đa. Bạn có thể chạy một playbook nhiều lần trên cùng một hạ tầng; Ansible sẽ kiểm tra và chỉ thay đổi những phần chưa đúng trạng thái, tránh hoàn toàn việc ghi đè hoặc gây lỗi hệ thống đang chạy ổn định.

### 📑 3.3. Cú pháp YAML dễ học (Human-Readable)
*   **Cơ chế**: Playbook được viết bằng định dạng YAML (khóa - giá trị) cực kỳ trực quan, dễ đọc giống như văn bản tiếng Anh.
*   **Lợi ích**: Không đòi hỏi kỹ năng lập trình nâng cao (như Ruby ở Chef). Giúp cả Quản trị viên hệ thống (Ops) và Lập trình viên (Dev) đều có thể cùng đọc hiểu, chỉnh sửa và cộng tác hiệu quả.
