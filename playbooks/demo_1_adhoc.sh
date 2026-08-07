#!/bin/bash
# ==============================================================================
# DEMO CHUONG 1 & 2: ANSIBLE AD-HOC COMMANDS
# Chay cac lenh nay tu may Control Plane (172.25.250.8)
# ==============================================================================

echo "=== 1. Ping may con de kiem tra ket noi SSH ==="
ansible dev -m ping --become=false

echo "=== 2. Kiem tra thong tin dung luong dia cua may con ==="
ansible dev -m shell -a "df -h" --become=false

echo "=== 3. Xem danh sach cac tep tin trong thu muc home cua may con ==="
ansible dev -m shell -a "ls -la" --become=false

echo "=== 4. Thu thap toan bo thong tin cau hinh (Facts) cua may con ==="
ansible dev -m setup --become=false

echo "=== 5. Chay lenh ad-hoc kiem tra phien ban Python tren may con ==="
ansible dev -m command -a "python3 --version" --become=false
