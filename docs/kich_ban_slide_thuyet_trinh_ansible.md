# KỊCH BẢN CHI TIẾT SLIDE THUYẾT TRÌNH: TỔNG QUAN HỆ THỐNG ANSIBLE

Kịch bản này được thiết kế để bạn làm slide thuyết trình chuyên nghiệp. Mỗi slide bao gồm: **Bố cục trực quan đề xuất (Visuals)**, **Nội dung hiển thị trên Slide (Slide Content)** và **Lời thoại chi tiết của người thuyết trình (Speaker Notes)** bằng tiếng Việt tự nhiên và chuyên sâu.

---

## Slide 1: Trang tiêu đề
*   **Tiêu đề**: Tự động hóa Quản trị Hệ thống với Ansible: Từ Cơ bản đến Nâng cao
*   **Tiêu đề phụ**: Thiết lập, Vận hành và Tái cấu trúc mã nguồn thông qua Ansible Roles
*   **Người trình bày**: [Tên của bạn]
*   **Visuals**: Logo Ansible và hình minh họa một mạng lưới máy chủ kết nối về một tâm điều khiển (Agentless Architecture).
*   **Speaker Notes**:
    > *"Xin chào mọi người. Hôm nay tôi xin phép trình bày về chuyên đề 'Tự động hóa Quản trị Hệ thống với Ansible'. Trong buổi thuyết trình này, chúng ta sẽ cùng đi qua lộ trình từ cách chuẩn bị một máy chủ chạy Ansible, cách tổ chức thư mục dự án chuẩn chỉnh, cách viết mã nguồn, công cụ vận hành hiện đại Ansible Navigator, phân biệt cơ chế tái sử dụng mã nguồn và cuối cùng là đi sâu vào cấu trúc và sức mạnh của Ansible Roles - trái tim của khả năng mở rộng hệ thống."*

---

## Slide 2: Ansible là gì & Dùng làm gì?
*   **Tiêu đề**: Ansible là gì và được dùng làm gì?
*   **Visuals**: Sơ đồ 3 khối chức năng lớn kết nối với nhau:
    1. `Configuration Management` (Quản lý cấu hình)
    2. `Application Deployment` (Triển khai ứng dụng)
    3. `Orchestration / Cloud / Network` (Điều phối hệ thống / Thiết bị mạng)
*   **Slide Content**:
    *   **Định nghĩa**: Ansible là công cụ tự động hóa hạ tầng dưới dạng mã (Infrastructure as Code - IaC) giúp đơn giản hóa các tác vụ quản trị IT phức tạp.
    *   **Quản lý cấu hình**: Thiết lập hệ điều hành, cài đặt và cập nhật phần mềm, đồng bộ cấu hình trên hàng trăm máy chủ cùng lúc.
    *   **Triển khai ứng dụng (CI/CD)**: Tự động hóa quy trình deploy code từ môi trường test lên production, khởi chạy ứng dụng không gián đoạn (no-downtime).
    *   **Điều phối (Orchestration)**: Định nghĩa và quản lý các luồng công việc phức tạp liên kết nhiều thành phần (Ví dụ: tắt Load Balancer ➔ nâng cấp Database ➔ cập nhật Web Server ➔ bật lại Load Balancer).
    *   **Mở rộng thiết bị mạng & Cloud**: Tự động cấu hình Router/Switch và khởi tạo tài nguyên đám mây (AWS, Azure, GCP...).
*   **Speaker Notes**:
    > *"Đầu tiên, chúng ta cần trả lời câu hỏi cốt lõi: Ansible là gì và được sử dụng để làm gì trong thực tế?
    > Ansible là một nền tảng tự động hóa IT mạnh mẽ dưới dạng mã (IaC). Thay vì một quản trị viên hệ thống phải gõ lệnh thủ công trên từng máy chủ, Ansible cho phép chúng ta mô tả trạng thái mong muốn của hệ thống bằng code và tự động hóa toàn bộ.
    > 
    > Ứng dụng thực tế của nó trải dài trên 4 lĩnh vực chính: Quản lý cấu hình hệ điều hành đồng loạt; Tự động hóa quy trình triển khai ứng dụng; Điều phối luồng công việc phức tạp giữa nhiều máy chủ khác nhau; Và cuối cùng là cấu hình tự động cho các thiết bị mạng cũng như hạ tầng điện toán đám mây."*

---

## Slide 3: Ưu điểm Vượt trội của Ansible (Why Ansible?)
*   **Tiêu đề**: Tại sao chọn Ansible? Các Ưu điểm Vượt trội
*   **Visuals**: Biểu đồ so sánh 3 ô cột nổi bật chứa các biểu tượng:
    *   `Không cần Agent` (Agentless)
    *   `Tính lũy đẳng` (Idempotent)
    *   `Dễ đọc hiểu` (Human-Readable YAML)
*   **Slide Content**:
    *   **Không cần Agent (Agentless)**: Không tốn tài nguyên hệ thống (RAM/CPU) để chạy agent trên máy đích. Không cần bảo trì hay nâng cấp agent. Kết nối an toàn qua SSH/WinRM tiêu chuẩn.
    *   **Tính lũy đẳng (Idempotency)**: Đảm bảo an toàn tuyệt đối. Chạy một playbook nhiều lần luôn đem lại cùng một kết quả. Ansible chỉ thực hiện thay đổi khi phát hiện cấu hình thực tế lệch khỏi thiết kế mong muốn.
    *   **Cú pháp YAML trực quan**: Dễ đọc, dễ hiểu đối với cả Quản trị viên hệ thống lẫn Lập trình viên. Không yêu cầu kỹ năng lập trình nâng cao (như Ruby ở Chef hay Puppet).
    *   **Khả năng tái sử dụng & Đóng gói**: Dễ dàng module hóa mã nguồn qua cấu trúc thư mục quy chuẩn (Ansible Roles) và mở rộng qua Collections.
*   **Speaker Notes**:
    > *"Vậy những ưu điểm vượt trội nào đã giúp Ansible trở thành lựa chọn hàng đầu trên toàn cầu?
    > - Thứ nhất, thiết kế Agentless: Không cần cài đặt bất kỳ phần mềm agent nào lên máy đích giúp triển khai lập tức và loại bỏ rủi ro bảo mật từ các lỗ hổng của agent.
    > - Thứ hai, tính lũy đẳng (Idempotency): Đây là tính năng an toàn tối thượng của IaC. Nếu bạn chạy playbook cấu hình 10 lần, Ansible chỉ thay đổi ở lần thứ nhất; 9 lần sau nó kiểm tra thấy hệ thống đã đúng chuẩn và tự động bỏ qua, tránh việc làm gián đoạn dịch vụ đang chạy.
    > - Thứ ba, ngôn ngữ YAML cực kỳ trực quan, giúp tất cả các thành viên trong dự án dễ dàng đọc hiểu và cùng tham gia vào quá trình phát triển tự động hóa."*

---

## Slide 4: Cấu hình Máy chủ Sẵn sàng với Ansible (Control Node & Managed Host)
*   **Tiêu đề**: Thiết lập Môi trường Tự động hóa Agentless
*   **Visuals**: Sơ đồ kết nối giữa Control Node (ở giữa) và các Managed Host (xung quanh) thông qua SSH.
*   **Slide Content**:
    *   **Control Node** (Máy điều khiển):
        *   Hệ điều hành: Linux (RHEL, Ubuntu, CentOS...).
        *   Yêu cầu: Cài đặt **Python 3** và **Ansible Engine** (`ansible-core`).
    *   **Managed Host** (Máy đích):
        *   Không cần cài Agent (Agentless).
        *   Yêu cầu: Có **Python 3** và cấu hình **SSH daemon**.
    *   **Cơ chế xác thực**:
        *   Sử dụng SSH Key-Based Authentication (`ssh-copy-id`) để kết nối không cần mật khẩu.
        *   Cấu hình Leo thang đặc quyền (`sudo`) không cần mật khẩu (Passwordless Sudo trong `/etc/sudoers.d/`).
*   **Speaker Notes**:
    > *"Điểm mạnh nhất của Ansible so với các đối thủ như Chef hay Puppet là kiến trúc Agentless – nghĩa là chúng ta không cần cài đặt bất kỳ phần mềm agent nào lên hàng trăm máy chủ đích. Thay vào đó, chúng ta chỉ cần cấu hình máy Control Node duy nhất có cài Python và Ansible. 
    > 
    > Đối với các máy đích, điều kiện duy nhất là có sẵn Python và dịch vụ SSH. Để Ansible vận hành hoàn toàn tự động, chúng ta sẽ cấu hình SSH Trust bằng cách copy Public Key của máy điều khiển sang máy đích và thiết lập phân quyền Sudo không mật khẩu (NOPASSWD) cho tài khoản quản trị để Ansible dễ dàng nâng quyền cấu hình hệ thống mà không bị nghẽn ở bước nhập mật khẩu."*

---

## Slide 5: Cấu trúc Thư mục Dự án Ansible Chuẩn hóa
*   **Tiêu đề**: Tổ chức Thư mục Dự án theo Best Practices
*   **Visuals**: Cây thư mục dạng văn bản minh họa:
    ```text
    ansible_project/
    ├── ansible.cfg          # Tệp cấu hình Ansible mặc định
    ├── inventory            # Khai báo địa chỉ và nhóm máy chủ
    ├── playbooks/           # Thư mục chứa các kịch bản triển khai (.yml)
    ├── group_vars/          # Biến toàn cục cho từng nhóm máy chủ
    └── roles/               # Các khối chức năng đóng gói độc lập
    ```
*   **Slide Content**:
    *   **ansible.cfg**: Khai báo các tham số hoạt động (đường dẫn inventory, tắt host key checking, cấu hình mặc định leo quyền sudo).
    *   **inventory**: File tĩnh hoặc động khai báo danh sách địa chỉ IP/Hostname của các máy đích và phân nhóm chúng (ví dụ: `[webservers]`, `[dbservers]`).
    *   **group_vars / host_vars**: Quản lý tập trung các biến cấu hình ứng với từng nhóm hoặc từng máy chủ cụ thể, giúp tách biệt mã nguồn playbook và dữ liệu cấu hình.
*   **Speaker Notes**:
    > *"Một dự án Ansible chuyên nghiệp không bao giờ viết tất cả mọi thứ vào một tệp duy nhất. Chúng ta cần chia nhỏ và quản lý dự án theo một cấu trúc chuẩn hóa.
    > 
    > Ở thư mục gốc, tệp 'ansible.cfg' đóng vai trò điều khiển hành vi của Ansible. File 'inventory' định nghĩa danh sách và các phân nhóm máy chủ. Thư mục 'group_vars' quản lý các biến chung cho từng nhóm, giúp chúng ta dễ dàng thay đổi cấu hình (như cổng kết nối, phiên bản phần mềm) mà không cần can thiệp hay sửa đổi logic trong Playbook nằm ở thư mục 'playbooks'."*

---

## Slide 6: Viết Mã nguồn Ansible (Playbook & YAML Syntax)

*   **Tiêu đề**: Cấu trúc của một Playbook Ansible
*   **Visuals**: Đoạn mã Playbook ví dụ ngắn gọn, sử dụng màu sắc phân biệt các phần:
    ```yaml
    - name: Cài đặt Web Server
      hosts: webservers
      become: true
      tasks:
        - name: Cài Apache
          ansible.builtin.apt:
            name: apache2
            state: present
    ```
*   **Slide Content**:
    *   **Cú pháp YAML**: Khai báo định dạng khóa-giá trị, phân cấp thụt lề bằng khoảng trắng (Space), không dùng phím Tab.
    *   **Play**: Định nghĩa phạm vi tác động (áp dụng lên nhóm máy nào - `hosts`) và các điều kiện thực thi (`become`, `vars`).
    *   **Task**: Các bước công việc cụ thể được thực hiện tuần tự từ trên xuống dưới.
    *   **Module**: Các công cụ được xây dựng sẵn (như `apt`, `copy`, `service`) để thực thi hành động cụ thể trên hệ thống đích, đảm bảo tính **Idempotence** (tính đồng nhất - chỉ thay đổi hệ thống khi cần thiết).
*   **Speaker Notes**:
    > *"Playbook được viết bằng cú pháp YAML cực kỳ dễ đọc. Cấu trúc của một Playbook gồm 3 tầng: Tầng cao nhất là 'Play' xác định đối tượng máy chủ đích nhận tác động. Dưới Play là danh sách các 'Tasks' (nhiệm vụ) được chạy tuần tự. 
    > 
    > Mỗi Task sẽ gọi một 'Module' cụ thể của Ansible để thực hiện công việc. Điểm đặc sắc của các Module Ansible là tính Idempotence (tính lũy đẳng) - nghĩa là nếu phần mềm đã được cài rồi, Ansible sẽ kiểm tra và bỏ qua, chỉ thực hiện thay đổi khi trạng thái thực tế của hệ thống khác biệt với trạng thái mong muốn được khai báo trong code."*

---

## Slide 7: Vận hành Hiện đại với Ansible Navigator
*   **Tiêu đề**: Trải nghiệm Vận hành Hiện đại bằng Ansible Navigator
*   **Visuals**: Bảng so sánh trực quan giữa Ansible Engine truyền thống và Ansible Navigator:
    | Tính năng | Ansible Engine (CLI) | Ansible Navigator |
    | :--- | :--- | :--- |
    | Môi trường chạy | Trực tiếp trên Host (Dễ lỗi thư viện) | Containerized (Execution Environment) |
    | Khả năng di động | Thấp (Phụ thuộc OS của Control Node) | Rất cao (Đóng gói hoàn chỉnh trong container) |
    | Giao diện log | Dòng lệnh cuộn truyền thống | Giao diện TUI tương tác & Text Mode |
*   **Slide Content**:
    *   **Execution Environments (EE)**: Đóng gói toàn bộ Ansible, Python, OS dependencies, và Ansible Collections vào một Container Image (như `creator-ee`).
    *   **ansible-navigator.yml**: File cấu hình kiểm soát engine (Podman/Docker), image chạy, và chế độ hiển thị logs (`stdout` hoặc `interactive`).
    *   **Lợi ích**: Triển khai playbook nhất quán ở mọi nơi mà không lo lỗi lệch phiên bản thư viện.
*   **Speaker Notes**:
    > *"Trước đây, việc chạy playbook trực tiếp bằng lệnh CLI truyền thống gặp hạn chế lớn về tính di động: nếu máy Control Node nâng cấp Python hoặc thiếu một Collection, playbook sẽ lập tức bị lỗi. 
    > 
    > Red Hat đã đưa ra giải pháp mới mang tên **Ansible Navigator** kết hợp cùng **Execution Environments (EE)**. Toàn bộ môi trường chạy Ansible được đóng gói gọn gàng bên trong một container image chạy qua Podman hoặc Docker. Khi ta gọi lệnh chạy, Navigator sẽ tạo container, gắn thư mục code của ta vào và thực thi. Điều này đảm bảo playbook chạy thành công ở máy cá nhân của ta thì chắc chắn sẽ chạy thành công khi mang lên máy chủ sản xuất (production)."*

---

## Slide 8: Quản lý và Tái sử dụng Code: Import vs Include
*   **Tiêu đề**: Phân tích Cơ chế Tái sử dụng Mã nguồn
*   **Visuals**: Hình ảnh động minh họa thời điểm phân giải mã nguồn:
    *   `import_*` (Static) ➔ Ghép nối tại thời điểm phân tích Playbook (Parsing time).
    *   `include_*` (Dynamic) ➔ Nạp động tại thời điểm thực thi Task (Runtime).
*   **Slide Content**:
    *   **Tĩnh (Static - Import)**:
        *   Cú pháp: `import_playbook`, `import_tasks`.
        *   Hành vi: Ghép toàn bộ nội dung tệp được gọi vào playbook chính ngay trước khi chạy.
        *   Hạn chế: Không thể sử dụng các biến được sinh ra từ các task trước đó để quyết định việc import.
    *   **Động (Dynamic - Include)**:
        *   Cú pháp: `include_tasks`, `include_role`.
        *   Hành vi: Đến lượt task nào thì mới nạp và thực thi tệp đó.
        *   Ưu điểm: Rất linh hoạt, có thể lặp (`loop`) hoặc sử dụng điều kiện `when` dựa trên kết quả chạy thực tế của hệ thống.
*   **Speaker Notes**:
    > *"Khi dự án Ansible lớn lên, chúng ta cần chia nhỏ code ra nhiều file nhỏ để dễ quản lý và tái sử dụng. Ansible cung cấp hai cơ chế là Import (Tĩnh) và Include (Động).
    > 
    > Hãy tưởng tượng 'Import' giống như việc copy-paste code thủ công vào file chính trước khi chạy. Mọi thứ được kiểm tra cú pháp ngay lập tức. Ngược lại, 'Include' hoạt động như một hàm gọi động tại thời điểm runtime. Khi chạy đến dòng include, hệ thống mới nạp file lên. Chính nhờ tính động này, Include cho phép chúng ta chạy vòng lặp trên danh sách các tệp cấu hình khác nhau, hoặc sử dụng câu lệnh điều kiện 'when' dựa trên kết quả khảo sát hệ thống từ các bước trước."*

---

## Slide 9: Trái tim của Tự động hóa: Ansible Roles
*   **Tiêu đề**: Khái niệm & Sức mạnh của Ansible Roles
*   **Visuals**: Mô hình hóa: Một Playbook chính cực kỳ ngắn gọn gọi các Roles độc lập (Role: Web Server, Role: Database, Role: Hardening).
*   **Slide Content**:
    *   **Định nghĩa**: Roles là cơ chế đóng gói và module hóa mã nguồn tự động hóa của Ansible theo một chuẩn cấu trúc thư mục quy định sẵn.
    *   **Mục tiêu**:
        *   **Chia để trị (Decoupling)**: Phân tách các dịch vụ phức tạp thành các khối chức năng riêng biệt.
        *   **Tái sử dụng cực cao**: Viết một lần, sử dụng cho nhiều dự án khác nhau.
        *   **Chia sẻ dễ dàng**: Đóng gói và chia sẻ thông qua Ansible Galaxy.
    *   **Triết lý thiết kế**: Giúp Playbook chính trở nên cực kỳ sạch sẽ, chỉ đóng vai trò map giữa nhóm máy chủ (Hosts) và các Roles cần áp dụng.
*   **Speaker Notes**:
    > *"Bây giờ, chúng ta sẽ đi vào phần trọng tâm và mạnh mẽ nhất của Ansible: **Ansible Roles**.
    > 
    > Nếu Playbook là nơi bạn mô tả tất cả các bước cấu hình thì Roles là công cụ giúp bạn đóng gói các bước cấu hình đó thành các module chuyên biệt, độc lập. Ví dụ, thay vì viết một file playbook dài hàng nghìn dòng cấu hình LAMP stack, bạn sẽ chia nhỏ thành 3 Roles độc lập: Role Web, Role Database và Role Cấu hình bảo mật hệ thống. 
    > 
    > Thiết kế này giúp code của bạn có khả năng tái sử dụng vô hạn. Khi viết một dự án mới cần cài web server, bạn chỉ cần gọi lại Role Web đã viết trước đó mà không phải copy lại từng dòng code."*

---

## Slide 10: Cấu trúc Thư mục Chuẩn của một Ansible Role (Đi sâu chi tiết)
*   **Tiêu đề**: Giải phẫu Thư mục của một Role
*   **Visuals**: Sơ đồ cây thư mục chi tiết của một Role tiêu chuẩn:
    ```text
    roles/my_role/
    ├── defaults/      # Biến mặc định (Độ ưu tiên thấp nhất)
    │   └── main.yml
    ├── vars/          # Biến cố định (Độ ưu tiên cao)
    │   └── main.yml
    ├── tasks/         # Logic thực thi chính
    │   └── main.yml
    ├── handlers/      # Các tác vụ phản hồi (restart service...)
    │   └── main.yml
    ├── templates/     # Các file cấu hình mẫu Jinja2 (.j2)
    ├── files/         # File tĩnh cần copy sang máy đích
    ├── meta/          # Khai báo thông tin mô tả và phụ thuộc
    └── tests/         # Kịch bản chạy thử nghiệm role
    ```
*   **Slide Content**:
    *   **tasks/main.yml**: Điểm khởi đầu thực thi của Role, chứa danh sách các task chính.
    *   **handlers/main.yml**: Chứa các task chỉ chạy khi được thông báo (`notify`) từ các task ở phần `tasks` (ví dụ: Restart Nginx khi file cấu hình thay đổi).
    *   **defaults vs vars**:
        *   `defaults`: Các biến cấu hình mặc định, rất dễ bị ghi đè bởi người dùng gọi Role.
        *   `vars`: Các biến cố định nội bộ của Role, không khuyến khích người dùng ghi đè.
    *   **templates**: Chứa các file cấu hình động viết bằng Jinja2 (ví dụ: `nginx.conf.j2` chứa các biến IP, Port được render động).
*   **Speaker Notes**:
    > *"Ansible quy định một cấu trúc thư mục rất chặt chẽ cho một Role. Khi bạn gọi một Role, Ansible sẽ tự động tìm kiếm tệp 'main.yml' bên trong các thư mục con để thực thi mà bạn không cần phải khai báo đường dẫn thủ công.
    > 
    > Trong cấu trúc này:
    > - Thư mục **tasks** chứa logic cài đặt chính.
    > - Thư mục **handlers** chứa các tác vụ phản hồi như restart dịch vụ, tránh việc khởi động lại dịch vụ không cần thiết khi hệ thống không có thay đổi.
    > - Sự khác biệt giữa **defaults** và **vars** nằm ở độ ưu tiên: Biến trong defaults có độ ưu tiên thấp nhất, đóng vai trò là cấu hình mẫu để người dùng dễ dàng ghi đè từ bên ngoài. Biến trong vars có độ ưu tiên cao, dùng để lưu các giá trị hằng số nội bộ của Role mà bạn muốn bảo vệ."*

---

## Slide 11: Thực chiến: Cách gọi và Thứ tự Thực thi Role
*   **Tiêu đề**: Triển khai Role vào Playbook Thực tế
*   **Visuals**: Mã nguồn Playbook mẫu gọi Role và sơ đồ thứ tự chạy:
    ```yaml
    - hosts: webservers
      pre_tasks:
        - name: Nhiệm vụ chạy trước
      roles:
        - common
        - web_server
      post_tasks:
        - name: Nhiệm vụ chạy sau
    ```
*   **Slide Content**:
    *   **Cách gọi Role**: Khai báo trực tiếp dưới từ khóa `roles:` trong Playbook.
    *   **Thứ tự thực thi nghiêm ngặt**:
        1.  `pre_tasks` (Nếu có khai báo).
        2.  `handlers` được kích hoạt từ pre_tasks.
        3.  **Các Roles** được liệt kê chạy tuần tự từ trên xuống dưới.
        4.  `tasks` khai báo thông thường trong Playbook (Nếu có).
        5.  `handlers` được kích hoạt từ roles và tasks thông thường.
        6.  `post_tasks` (Nếu có khai báo).
        7.  `handlers` được kích hoạt từ post_tasks.
*   **Speaker Notes**:
    > *"Để chạy một Role, chúng ta chỉ cần khai báo tên của Role đó dưới thẻ 'roles' trong playbook chính. 
    > 
    > Một điểm cực kỳ quan trọng cần lưu ý khi thiết kế hệ thống lớn là thứ tự thực thi. Ansible có một quy trình chạy rất khoa học: Đầu tiên nó sẽ chạy các 'pre_tasks' để dọn dẹp hoặc chuẩn bị môi trường. Sau đó, nó thực thi tuần tự các Roles được liệt kê. Tiếp đến là các tasks thông thường trong playbook chính, và cuối cùng là các 'post_tasks' để kiểm tra chất lượng dịch vụ. 
    > 
    > Hiểu rõ thứ tự này giúp các bạn kiểm soát chính xác thời điểm các dịch vụ được khởi động và các tệp cấu hình được áp dụng."*

---

## Slide 12: Tổng kết & Hỏi đáp (Q&A)
*   **Tiêu đề**: Tóm tắt các Điểm cốt lõi
*   **Visuals**: Bản đồ tư duy (Mindmap) kết nối:
    `Thiết lập máy chủ` ➔ `Cấu trúc dự án` ➔ `Playbook (YAML)` ➔ `Navigator` ➔ `Import/Include` ➔ `Roles`.
*   **Slide Content**:
    *   Ansible là giải pháp tự động hóa mạnh mẽ, tinh gọn (Agentless) và dễ tiếp cận.
    *   Tổ chức thư mục dự án rõ ràng giúp dễ bảo trì và làm việc nhóm.
    *   Sử dụng Ansible Navigator để chuẩn hóa môi trường thực thi (EE) nhất quán.
    *   Sử dụng Roles để module hóa, đóng gói mã nguồn và xây dựng thư viện tự động hóa cho doanh nghiệp.
*   **Speaker Notes**:
    > *"Tóm lại, tự động hóa với Ansible không chỉ là viết các dòng lệnh đơn lẻ, mà là xây dựng một hệ thống mã nguồn cấu hình có cấu trúc, có thể tái sử dụng và kiểm soát nhất quán. Bằng việc áp dụng Ansible Roles và vận hành qua Ansible Navigator, chúng ta có thể tự tin quản trị hạ tầng từ vài máy chủ cho đến hàng ngàn máy chủ một cách ổn định, an toàn và chuyên nghiệp.
    > 
    > Cảm ơn mọi người đã chú ý lắng nghe. Sau đây là phần thảo luận và giải đáp thắc mắc (Q&A)."*
