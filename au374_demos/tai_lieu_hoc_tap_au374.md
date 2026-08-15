# GIÁO TRÌNH HỌC TẬP & ÔN THI ANSIBLE NÂNG CAO (RED HAT AU374)
## Hướng Dẫn Lý Thuyết Và Thực Hành Chi Tiết Cho Hệ Thống Red Hat Ansible Automation Platform 2.6

Chào mừng bạn đến với tài liệu ôn tập và thực hành nâng cao dựa trên tài liệu chuẩn của khóa học **Red Hat Advanced Automation with Ansible (AU374 / RH374)**. Tài liệu này được biên soạn chi tiết bằng tiếng Việt để giúp bạn dễ dàng làm chủ các tính năng nâng cao của Ansible Automation Platform 2.6.

---

## MỤC LỤC
1. [Chương 1: Quản Lý Tài Nguyên Dự Án Ansible Bằng Git](#chương-1)
2. [Chương 2: Quản Lý Collections Và Môi Trường Thực Thi (Execution Environments)](#chương-2)
3. [Chương 3: Vận Hành Playbook Trên Automation Controller](#chương-3)
4. [Chương 4: Quản Trị Các Cấu Hình Hệ Thống Với Navigator](#chương-4)
5. [Chương 5: Quản Lý Inventory Và Tổ Chức Biến Nâng Cao](#chương-5)

---

<a name="chương-1"></a>
## CHƯƠNG 1: QUẢN LÝ TÀI NGUYÊN DỰ ÁN ANSIBLE BẰNG GIT

### 1. Nguyên Lý Hoạt Động Của Hệ Thống Git (DVCS)
Git là hệ thống quản lý phiên bản phân tán. Khi bạn thực hiện clone một dự án, Git sẽ tải về toàn bộ lịch sử commits của dự án đó thành một kho chứa cục bộ (**Local Repository**) trên máy của bạn, chứ không chỉ tải về phiên bản mới nhất.

#### Bốn trạng thái của tệp tin trong thư mục Git (Working Tree):
* **Modified (Đã chỉnh sửa)**: Tệp tin đã được bạn chỉnh sửa nội dung trên máy thật nhưng chưa được lưu vết vào Git.
* **Staged (Đã đưa vào vùng chờ)**: Tệp tin đã được đánh dấu thông qua lệnh `git add` để chuẩn bị cho lượt commit tiếp theo.
* **Committed (Đã lưu vết)**: Tệp tin đã được lưu trữ an toàn vào cơ sở dữ liệu của Local Repository thông qua lệnh `git commit`.
* **Clean (Sạch sẽ)**: Tệp tin chưa có bất kỳ sửa đổi nào kể từ lần commit gần nhất.

### 2. Các Lệnh Điều Khiển Git Thực Tế
* **Cấu hình định danh**:
  ```bash
  git config --global user.name "Peter Shadowman"
  git config --global user.email "peter@host.example.com"
  ```
* **Cấu hình hiển thị nhánh trực quan trên Terminal**:
  Thêm các dòng sau vào tệp `~/.bashrc` để terminal tự động hiển thị tên nhánh hiện tại và trạng thái tệp tin:
  ```bash
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export PS1='[\u@\h \W$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")]\$ '
  ```
  *Ký hiệu:* `(main *)` nghĩa là có file bị sửa; `(main +)` nghĩa là file sửa đã add vào staging; `(main %)` nghĩa là có file mới chưa tracked.
* **Lệnh quản lý tệp tin và đồng bộ**:
  * `git status`: Hiển thị chi tiết trạng thái của các file.
  * `git add <file>` hoặc `git add .`: Đưa file vào vùng chờ (Staging Area).
  * `git rm <file>`: Xóa file khỏi thư mục làm việc và đưa trạng thái xóa vào vùng chờ.
  * `git reset <file>`: Đưa file ra khỏi vùng chờ Staging Area (không làm mất nội dung đã sửa trong file).
  * `git revert <commit-hash>`: Tạo ra một commit mới có nội dung hoàn toàn ngược lại với commit chỉ định nhằm mục đích sửa lỗi an toàn.
  * `git fetch`: Tải các cập nhật từ máy chủ remote về nhưng không gộp vào code hiện tại.
  * `git merge`: Gộp các thay đổi từ nhánh khác vào nhánh hiện tại. Nếu cả hai nhánh cùng sửa một dòng code, sẽ xảy ra **Merge Conflict** (Xung đột gộp) và lập trình viên phải sửa thủ công.
  * `git pull`: Tương đương chạy đồng thời `git fetch` và `git merge`.

### 3. Quy Tắc Viết Commit Message Chuẩn Doanh Nghiệp
Một commit message chuẩn mực gồm 3 phần:
1. **Dòng tiêu đề (Subject line)**: Ngắn gọn dưới 50 ký tự, mô tả lý do thay đổi (Ví dụ: `feat: bổ sung cấu hình DNS`).
2. **Dòng trống**: Ngăn cách tiêu đề và phần thân.
3. **Phần mô tả chi tiết (Body)**: Giải thích chi tiết thay đổi là gì, tại sao lại thay đổi và có ảnh hưởng gì tới hệ thống không.
4. **Tham chiếu (References)**: Nêu rõ ID của ticket hoặc task liên quan (Ví dụ: `Ref: #1042`).

### 4. Quản Lý Nhánh (Branches) Và Đồng Bộ Hóa
Nhánh (Branch) thực chất là một con trỏ trỏ tới một commit cụ thể trong cây commit. Sử dụng nhánh giúp song song hóa việc phát triển tính năng mới mà không làm ảnh hưởng đến tính ổn định của nhánh chính (`main`).
* Tạo nhánh mới: `git branch <ten_nhanh>`
* Chuyển nhánh: `git checkout <ten_nhanh>`
* Tạo và chuyển nhánh trong 1 bước: `git checkout -b <ten_nhanh>`
* Đẩy nhánh lên Remote Server và thiết lập theo dõi:
  ```bash
  git push --set-upstream origin <ten_nhanh>
  ```
* **Bảo vệ nhánh (Protected Branches)**: Trên các Git Server (GitHub, GitLab), nhánh `main` thường được cấu hình bảo vệ. Lập trình viên không thể push trực tiếp lên `main` mà phải tạo một nhánh tính năng, đẩy lên server và tạo **Pull Request (PR) / Merge Request (MR)** để người quản trị kiểm duyệt và gộp code.

### 5. Cấu Trúc Dự Án Ansible Trong Git Và File `.gitignore`
Mỗi dự án Ansible độc lập nên được lưu trữ trong một Git Repository riêng. Thư mục chuẩn bao gồm file chạy chính `site.yml`, thư mục `roles/` chứa các role tự viết, thư mục `collections/` chứa các collection phụ thuộc.

Để tránh đẩy mã nguồn tải về làm rác repository, cấu hình tệp `.gitignore` sử dụng quy tắc khớp mẫu:
* Ký tự `*` đại diện cho khớp tên trong cùng một thư mục.
* Ký tự `**` đại diện cho khớp sâu qua nhiều cấp thư mục.
* Ký tự `!` dùng để phủ định quy tắc bỏ qua.

#### File `.gitignore` mẫu:
```ini
# Bỏ qua toàn bộ nội dung trong thư mục roles
roles/**
# Ngoại trừ tệp yêu cầu tải requirements.yml
!roles/requirements.yml

# Bỏ qua toàn bộ collections tải về
collections/*
# Ngoại trừ tệp cấu hình dependencies
!collections/requirements.yml

# Bỏ qua log chạy tạm của navigator
*artifact-*.json
*.log
*.retry
.ansible-navigator/
```

### 6. Kiến Trúc Red Hat Ansible Automation Platform (AAP)
Kiến trúc của AAP (từ phiên bản 2.x trở đi) bao gồm các thành phần cốt lõi:
* **Control Node (Máy điều khiển)**: Máy chạy Ansible, thực thi các lệnh quản trị và điều khiển các máy đích.
* **Managed Hosts (Máy được quản lý)**: Các máy chủ, thiết bị mạng hoặc tài nguyên đám mây nhận lệnh từ Control Node. Ansible không cần cài đặt agent trên các máy này (Agentless), giao tiếp qua SSH hoặc WinRM.
* **Tách biệt Control Plane và Execution Plane**: 
  * Control Plane (Giao diện đồ họa, lập lịch, RBAC) được quản lý bởi Automation Controller.
  * Execution Plane (Nơi thực thi playbook thực tế) chạy trong các container **Execution Environments (EE)** cô lập, giúp không bị xung đột phiên bản Python.
* **Automation Mesh**: Mạng lưới truyền dữ liệu phân tán giúp mở rộng quy mô thực thi.

### 7. Hướng Dẫn Chạy Ansible Navigator (Trình điều khiển chạy Playbook)
`ansible-navigator` là công cụ dòng lệnh hiện đại được khuyên dùng để kiểm tra cú pháp, chạy playbook và quản lý môi trường thực thi (EE).
* **Lệnh chạy playbook cơ bản**:
  ```bash
  ansible-navigator run site.yml
  ```
* **Các tham số dòng lệnh quan trọng**:
  * `--mode stdout` (hoặc `-m stdout`): Chạy ở chế độ dòng lệnh văn bản truyền thống. Nếu không chỉ định, mặc định chạy ở chế độ tương tác vẽ bảng (`interactive`).
  * `--eei <image_name>` (hoặc `--execution-environment-image`): Chỉ định ảnh container chứa môi trường thực thi playbook.
  * `--pp <policy>` (hoặc `--pull-policy`): Chính sách tải ảnh container về (`always`, `missing`, `never`).
  * `--pae false` (hoặc `--playbook-artifact-enable false`): Tắt tạo log chạy dạng JSON để cho phép nhập mật khẩu bảo mật tương tác từ bàn phím.
  * `--syntax-check`: Chỉ kiểm tra cú pháp của playbook mà không thực thi.

---

<a name="chương-2"></a>
## CHƯƠNG 2: QUẢN LÝ COLLECTIONS VÀ MÔ TRƯỜNG THỰC THI (EE)

### 1. Cơ Chế Hoạt Động Của Ansible Content Collections
Ansible Content Collections là định dạng đóng gói và phân phối mã nguồn Ansible (bao gồm các modules, roles, plugins).
* **Namespaces**: Giúp phân vùng và quản lý tên thương hiệu tránh trùng lặp. Tên namespace chỉ chứa chữ thường, số, dấu gạch dưới, dài tối thiểu 2 ký tự và không bắt đầu bằng dấu gạch dưới (Ví dụ: `redhat.satellite`, `community.aws`).
* **FQCN (Fully Qualified Collection Name)**: Định danh đầy đủ của một module.
  * Cú pháp: `<namespace>.<collection_name>.<module_name>`
  * Ví dụ: `ansible.builtin.dnf`, `ansible.posix.mount`.

### 2. Khắc Phục Xung Đột Bằng Redirection (`ansible_builtin_runtime.yml`)
Khi nâng cấp hệ thống từ Ansible 2.9 lên AAP 2, rất nhiều module cũ (như `acl`, `synchronize`) đã bị chuyển vào các collection bên ngoài (`ansible.posix.acl`, `ansible.posix.synchronize`).
Để các playbook cũ vẫn chạy được mà không cần sửa code ngay lập tức, `ansible-core` cung cấp file cấu hình `ansible_builtin_runtime.yml` (nằm trong thư viện python của core) để tự động ánh xạ (redirect) các tên gọi ngắn cũ sang FQCN tương ứng.

### 3. Quy Tắc Cài Đặt Collections Trong Môi Trường AAP 2
Trong AAP 2, playbook được chạy cô lập bên trong các container (Execution Environments). Container này **không thể truy cập** được vào thư mục cài đặt mặc định của Control Node (`~/.ansible/collections`).
Do đó, các collection tự thêm **phải** được cài đặt vào thư mục cục bộ của dự án:
```text
/home/user/project/collections/
```
Khi chạy, `ansible-navigator` sẽ mount toàn bộ thư mục dự án (bao gồm cả thư mục `./collections` này) vào trong container, giúp playbook tìm thấy các collections cần thiết.

#### Cài đặt bằng file `collections/requirements.yml`:
```yaml
---
collections:
  - name: community.crypto
  - name: ansible.posix
    version: 1.6.0
  - name: my_local_collection.tar.gz # Cài từ file nén cục bộ
  - name: https://example.com/collection.tar.gz # Cài từ URL
  - name: git@github.com:ansible-collections/community.mysql.git # Cài từ Git
```
Lệnh thực thi:
```bash
ansible-galaxy collection install -r collections/requirements.yml -p ./collections/
```

### 4. Cấu Hình Nguồn Tải Nâng Cao Trong `ansible.cfg`
Để tải các collections từ các nguồn bảo mật doanh nghiệp (Private Automation Hub / Red Hat Certified Hub), cấu hình tệp `ansible.cfg`:
```ini
[galaxy]
server_list = my_private_hub, hub_certified, galaxy

[galaxy_server.my_private_hub]
url = https://aap.example.com/api/galaxy/content/rh-certified/
token = <token_private_hub>

[galaxy_server.hub_certified]
url = https://console.redhat.com/api/automation-hub/content/published/
auth_url = https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token = <token_redhat_hub>

[galaxy_server.galaxy]
url = https://galaxy.ansible.com/
```
*Mẹo bảo mật*: Để tránh lộ token khi đưa file `ansible.cfg` lên Git, bạn có thể xóa tham số `token = ...` trong file cfg và export nó dưới dạng biến môi trường trước khi chạy lệnh:
```bash
export ANSIBLE_GALAXY_SERVER_MY_PRIVATE_HUB_TOKEN='e8e4...b0c2'
```

### 5. Cấu Trúc Và Quản Lý Execution Environments (EE)
Một EE gồm 4 thành phần chính:
1. **Ansible Core**: Bộ máy chạy cốt lõi.
2. **Collections**: Thư viện modules hỗ trợ.
3. **Python & OS packages**: Các gói phụ thuộc hệ điều hành và thư viện python.
4. **Ansible Runner**: Trình quản lý thực thi công việc.

#### Các câu lệnh quản trị EE:
* Liệt kê các EE khả dụng trên hệ thống:
  ```bash
  ansible-navigator images
  ```
* Xem danh sách collections bên trong một EE cụ thể:
  Chạy `ansible-navigator images`, chọn số thứ tự của image cần xem, chọn mục `2` (Ansible version and collections) để duyệt danh sách chi tiết.
* Chỉ định EE khi chạy playbook qua CLI:
  ```bash
  ansible-navigator run playbook.yml --eei registry.redhat.io/ansible-automation-platform-26/ee-supported-rhel9:latest --pull-policy missing
  ```
  *Chính sách kéo ảnh (Pull Policy):*
  * `always`: Luôn tải ảnh mới nhất từ Registry về.
  * `missing`: Chỉ tải về khi dưới local chưa có (Tối ưu nhất cho môi trường Lab).
  * `never`: Không bao giờ tải, chỉ dùng ảnh có sẵn dưới local.

---

<a name="chương-3"></a>
## CHƯƠNG 3: VẬN HÀNH PLAYBOOK TRÊN AUTOMATION CONTROLLER

### 1. Kiến Trúc decoupled mặt phẳng của AAP 2
AAP 2 thay đổi thiết kế so với phiên bản cũ (Ansible Tower 3.8 trở về trước) bằng việc tách biệt:
* **Control Plane (Mặt phẳng điều khiển)**: Đảm nhận giao diện web, quản lý quyền hạn (RBAC), lập lịch chạy.
* **Execution Plane (Mặt phẳng thực thi)**: Nơi thực hiện công việc thực tế. Việc thực thi chạy trong các container EE giúp giải quyết triệt để vấn đề xung đột phiên bản Python. Trước đây, nếu hai dự án yêu cầu thư viện Python khác nhau, quản trị viên phải cấu hình hàng chục Python Virtual Environments (virtualenv) phức tạp trên máy chủ Tower. Bây giờ, mỗi dự án chỉ cần dùng một container EE độc lập của riêng mình.
* **Automation Mesh**: Giải pháp kết nối mạng phân tán. Giúp máy chủ Controller trung tâm có thể ra lệnh thực thi playbook trên các máy chủ Execution Node nằm sâu trong mạng nội bộ hoặc các phân vùng mạng bị chặn, thông qua cơ chế chuyển tiếp (relay) của các **Hop Nodes**.

### 2. Khởi Tạo Tài Nguyên Trên Giao Diện Web AAP
Để chạy tự động hóa, bạn cần khai báo các tài nguyên sau trên giao diện quản trị:

#### A. Credentials (Xác thực)
* **Machine Credential**: Cung cấp tài khoản/mật khẩu hoặc Khóa SSH cá nhân để Ansible login vào máy con, kèm theo quyền cấu hình `become` (ví dụ sudo pass).
* **Source Control Credential**: Tài khoản/Mật khẩu hoặc SSH key để tải code từ Git repository.
* **Vault Credential**: Nạp mật khẩu giải mã để tự động giải mã các tệp tin chứa mật khẩu/khóa mật bị mã hóa bởi `ansible-vault`.

#### B. Projects
Liên kết tới Git chứa playbook của bạn.
* Cấu hình *Allow branch override* cho phép ghi đè nhánh chạy khi test.

#### C. Inventories
Nơi quản lý danh sách thiết bị. Ngoài việc nhập tay thủ công, bạn có thể cấu hình **Sourced from a Project** để lấy trực tiếp tệp tin `inventory.yml` có sẵn từ Git Project của bạn làm nguồn dữ liệu thiết bị thực tế.

#### D. Job Templates
Tài nguyên kết hợp mọi thứ để thực thi. Cấu hình Job Template có các tham số tương ứng trực tiếp với lệnh CLI:
* `Inventory` tương đương `-i`.
* `Execution Environment` tương đương `--eei`.
* `Limit` tương đương `-l` (Giới hạn chạy trên một số máy cụ thể).
* `Extra variables` tương đương `-e`.
* `Verbosity` tương đương `-v` (Tăng mức độ log chi tiết).

---

<a name="chương-4"></a>
## CHƯƠNG 4: QUẢN TRỊ CÁC CẤU HÌNH HỆ THỐNG VỚI NAVIGATOR

### 1. Phân Tích Chi Tiết Cấu Hình Với `ansible-navigator config`
Lệnh `ansible-navigator config` là công cụ tối ưu nhất để kiểm tra cấu hình thực tế của Ansible Engine bên trong container.

#### Cách đọc bảng cấu hình trong chế độ tương tác (TUI):
* **Cột Name**: Tên tham số nội bộ (ví dụ: `Default become` tương đương khóa `become` trong file cfg).
* **Cột Default**: Hiển thị `True` (nếu đang dùng mặc định, chữ màu xanh) hoặc `False` (nếu đã bị cấu hình ghi đè, chữ màu vàng).
* **Cột Source**: Đường dẫn tuyệt đối tới file `ansible.cfg` thiết lập giá trị đó. Nếu hiển thị `env`, nghĩa là cấu hình được nạp từ biến môi trường.
* **Cột Current**: Giá trị hiện tại đang được áp dụng.

#### Các lệnh dòng lệnh nhanh (Stdout Mode):
* `ansible-navigator config dump -m stdout`: Kết xuất toàn bộ danh sách cấu hình và giá trị.
* `ansible-navigator config view -m stdout`: Xem nội dung file `ansible.cfg` hiện hành.

### 2. Thiết Lập File Cấu Hình `ansible-navigator.yml`
File này dùng để định nghĩa các tùy chọn chạy cho công cụ navigator.
#### Thứ tự ưu tiên quét file cấu hình của Navigator:
1. Đường dẫn trong biến môi trường `ANSIBLE_NAVIGATOR_CONFIG`
2. File `ansible-navigator.yml` tại thư mục hiện hành của dự án.
3. File ẩn `~/.ansible-navigator.yml` tại thư mục Home của người dùng.

#### Cách sinh file cấu hình chuẩn:
```bash
# Sinh file cấu hình mẫu đầy đủ bình luận hướng dẫn
ansible-navigator settings --sample > sample.yml

# Sinh file cấu hình chứa các thiết lập đang chạy thực tế (không kèm bình luận)
ansible-navigator settings --effective > sample.yml
```
*Lưu ý quan trọng khi sửa file sample:* Các dòng cấu hình mẫu bị comment bằng dấu `#`. Khi bạn uncomment, hãy xóa dấu `#` **và đúng 1 khoảng trắng** phía sau để đảm bảo định dạng thụt lề 2 spaces của YAML không bị lỗi.

#### Các cấu hình cốt lõi cần nhớ trong `ansible-navigator.yml`:
```yaml
---
ansible-navigator:
  ansible:
    config:
      path: ./ansible.cfg          # Trỏ đường dẫn tới file config của Ansible Core
  execution-environment:
    container-engine: podman       # Dùng podman làm container engine
    enabled: true                  # Bật EE
    image: quay.io/ansible/creator-ee:latest
    pull:
      policy: missing              # Chỉ tải về khi thiếu
  mode: stdout                     # Chạy chế độ text terminal truyền thống
  playbook-artifact:
    enable: false                  # Tắt tự tạo tệp tin log JSON (Bắt buộc để hỏi mật khẩu khi chạy)
```

---

<a name="chương-5"></a>
## CHƯƠNG 5: QUẢN LÝ INVENTORY VÀ TỔ CHỨC BIẾN NÂNG CAO

### 1. Viết Inventory Định Dạng YAML Chuẩn AU374
So với định dạng INI cũ, định dạng YAML giúp bạn quản lý phân cấp trực quan và gom nhóm các biến cấu hình tốt hơn.

#### File Inventory YAML chuẩn mẫu:
```yaml
all:
  children:
    webservers:
      hosts:
        webserver_1:                 # Bí danh hiển thị (Human Readable Name)
          ansible_host: 10.0.0.10    # Địa chỉ IP kết nối thực tế
          ansible_port: 2222         # Port SSH tùy chỉnh
        webserver_2:
          ansible_host: 10.0.0.11
      vars:
        http_port: 8080              # Biến áp dụng chung cho nhóm webservers
    databases:
      hosts:
        dbserver.example.com:
    ungrouped:                       # Khai báo các máy chủ không thuộc nhóm nào
      hosts:
        monitor.example.com:
```

### 2. Các Quy Tắc Vàng Khi Viết Cú Pháp YAML Để Tránh Lỗi Biên Dịch
YAML là ngôn ngữ nhạy cảm cấu trúc. Hãy tuân thủ các quy tắc sau:
1. **Bảo vệ dấu hai chấm kèm khoảng trắng**: Một dấu hai chấm kèm một khoảng trắng liền kề (`: `) đại diện cho việc gán Key-Value trong YAML. Nếu chuỗi ký tự của bạn chứa cụm này, bạn bắt buộc phải bao quanh bằng dấu nháy đơn hoặc nháy kép.
   * *Lỗi*: `msg: Lỗi hệ thống: Không thể kết nối`
   * *Đúng*: `msg: "Lỗi hệ thống: Không thể kết nối"`
2. **Bảo vệ biến Jinja2 đứng ở đầu dòng**: Nếu giá trị của một khóa bắt đầu bằng dấu mở ngoặc nhọn kép `{{`, YAML sẽ hiểu nhầm đó là bắt đầu một dictionary và báo lỗi. Bạn phải đặt toàn bộ trong dấu nháy kép.
   * *Lỗi*: `dest: {{ web_doc_root }}/index.html`
   * *Đúng*: `dest: "{{ web_doc_root }}/index.html"`
3. **Phân biệt String với Boolean/Float**:
   * Boolean: `active: true` (Không viết dấu nháy).
   * String: `active: "true"` (Có dấu nháy sẽ biến thành chuỗi văn bản).
   * Float: `version: 2.0` (Sẽ bị hiểu là số thực). Nếu muốn lưu phiên bản dạng chuỗi để tránh mất chữ số 0, hãy viết: `version: "2.0"`.

### 3. Tổ Chức Biến Theo Cấu Trúc Thư Mục Con (Subdirectory Layout)
Tài liệu AU374 khuyên khích kỹ sư Ansible sử dụng thư mục con thay thế cho việc viết biến trực tiếp vào file.
Thay vì tạo file `group_vars/webservers.yml` duy nhất, hãy tạo một thư mục trùng tên nhóm: `group_vars/webservers/`. Bên trong thư mục này, ta chia nhỏ thành các tệp YAML tương ứng với từng dịch vụ của nhóm:
```text
group_vars/
├── all/
│   └── common.yml         # Khai báo DNS, NTP, HTTP Proxy chung cho cả hạ tầng
└── webservers/
    ├── apache.yml         # Chỉ chứa các cấu hình liên quan đến dịch vụ Web Apache
    ├── firewall.yml       # Chỉ chứa cấu hình cổng Port mở trên Firewall
    └── ssl.yml            # Chỉ chứa đường dẫn chứng chỉ và cấu hình SSL
```
Ansible sẽ tự động quét toàn bộ thư mục `group_vars/webservers/` và gộp (merge) tất cả các biến này lại tại thời điểm chạy playbook.

### 4. Thứ Tự Ưu Tiên Của Biến (Variable Precedence) Chi Tiết
Khi một biến được khai báo ở nhiều nơi, Ansible sẽ chọn giá trị có mức độ ưu tiên cao nhất theo danh sách (từ thấp đến cao):
1. **role defaults** (Khai báo trong `rolename/defaults/main.yml` - Dễ bị ghi đè nhất).
2. **inventory group_vars/all** (Biến trong file `group_vars/all.yml` của inventory).
3. **playbook group_vars/all** (Biến trong file `group_vars/all.yml` của thư mục playbook).
4. **inventory group_vars** (Biến của nhóm cụ thể trong thư mục inventory).
5. **playbook group_vars** (Biến của nhóm cụ thể trong thư mục playbook).
6. **inventory host_vars** (Biến của host cụ thể trong thư mục inventory).
7. **playbook host_vars** (Biến của host cụ thể trong thư mục playbook).
8. **host facts / cached facts** (Thông tin cấu hình thời gian thực thu thập từ máy con).
9. **play vars** (Biến khai báo trong mục `vars:` của play).
10. **play vars_prompt** (Biến nhập vào tương tác từ bàn phím).
11. **play vars_files** (Biến nạp từ các tệp tin qua `vars_files:`).
12. **role vars** (Biến định nghĩa trong mục `rolename/vars/main.yml` của Role).
13. **block vars** (Biến khai báo trong block).
14. **task vars** (Biến khai báo riêng cho một task cụ thể).
15. **include_vars** (Biến được load động trong lúc chạy qua module `include_vars`).
16. **set_facts / registered vars** (Biến tạo ra thông qua module `set_fact` hoặc kết quả trả về của tác vụ đăng ký qua `register`).
17. **role parameters** (Biến truyền vào khi gọi Role trong Playbook).
18. **include_tasks vars** (Biến truyền vào khi gọi include_tasks).
19. **extra vars** (Biến truyền qua tham số dòng lệnh CLI `-e` - Luôn có quyền lực cao nhất).

### 5. Quản Lý Dynamic Inventories (Inventory động)
Đối với các hệ thống Cloud tự động co giãn (Auto Scaling), danh sách IP thay đổi liên tục nên ta không dùng inventory tĩnh. Thay vào đó, ta sử dụng **Inventory Plug-ins**.

* **Cách tìm plugin**:
  ```bash
  # Xem toàn bộ plugin có sẵn trong EE
  ansible-navigator doc --mode stdout --type inventory --list
  # Xem tài liệu và file cấu hình mẫu cho một plugin cụ thể
  ansible-navigator doc --mode stdout --type inventory redhat.satellite.foreman
  ```
* **Viết file cấu hình plugin**:
  Tệp cấu hình của plugin luôn kết thúc bằng đuôi `.yml` hoặc `.yaml` và phải bắt đầu bằng khai báo FQCN của plugin đó.
  Ví dụ file cấu hình dynamic inventory cho Red Hat Satellite (`satellite.yml`):
  ```yaml
  plugin: redhat.satellite.foreman
  url: https://satellite.example.com
  user: ansibleinventory
  password: Sup3r53cr3t
  host_filters: 'organization="Development"' # Lọc máy chủ
  ```

### 6. Quản Lý Nhiều Inventory Đồng Thời
Ansible hỗ trợ bạn chỉ định đường dẫn inventory là một thư mục chứa nhiều tệp tin (bao gồm cả file static và script dynamic):
```bash
ansible-navigator run -i /home/user/ansible/inventories/ playbook.yml
```
* **Quy tắc gộp**: Ansible sẽ gộp tất cả các nguồn lại. Thứ tự quét các file được thực hiện theo bảng chữ cái (**Alphabetical Order**). Do đó, bạn phải đảm bảo các file độc lập và không phụ thuộc chéo vào nhau để tránh lỗi biên dịch do thứ tự quét không mong muốn.
* **Bỏ qua file**: Ansible tự động bỏ qua các file có đuôi nằm trong cấu hình `inventory_ignore_extensions` (mặc định bỏ qua `.pyc`, `.txt`, `.md`, `.cfg`, `.swp`, ...).
