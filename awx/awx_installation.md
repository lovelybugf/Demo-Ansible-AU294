# Hướng dẫn cài đặt AWX trên Kubernetes bằng AWX Operator

## 1. Yêu cầu trước khi cài

- Cluster K8s đang chạy, `kubectl` đã kết nối được.
- Có ít nhất một **StorageClass** khả dụng (bắt buộc, vì Postgres cần PVC để lưu dữ liệu).
- Có quyền tạo namespace, deploy CRD, RBAC (thường cần quyền cluster-admin).

---

## 2. Clone repo awx-operator

```bash
git clone https://github.com/ansible/awx-operator.git
cd awx-operator
git tag                        # xem các bản release
git checkout tags/2.19.1       # chọn bản ổn định, thay bằng tag mới nhất nếu cần
```


---

## 3. Tạo file kustomization.yaml

Tạo file `kustomization.yaml` trong thư mục `awx-operator`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/ansible/awx-operator/config/default?ref=2.19.1
  - awx-demo.yml

images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.19.1
  - name: gcr.io/kubebuilder/kube-rbac-proxy
    newName: registry.k8s.io/kubebuilder/kube-rbac-proxy
    newTag: v0.15.0

namespace: awx
```

> **Lưu ý quan trọng:** Image gốc `gcr.io/kubebuilder/kube-rbac-proxy` đã bị Google **deprecate và gỡ bỏ hoàn toàn từ đầu 2025**. Nếu không override sang `registry.k8s.io/kubebuilder/kube-rbac-proxy`, pod `awx-operator-controller-manager` sẽ bị kẹt ở trạng thái `ImagePullBackOff`/`ErrImagePull` vĩnh viễn (container `kube-rbac-proxy` không pull được, dù container `awx-manager` vẫn chạy bình thường → pod hiện `1/2`).

## 4. Tạo file awx-demo.yml (định nghĩa AWX instance)

```yaml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
```

> Nếu chạy trên OpenShift: đổi thành `service_type: clusterip` + `ingress_type: Route`.

## 5. Cài StorageClass (nếu cluster chưa có)

Kiểm tra:
```bash
kubectl get storageclass
```


Cài `local-path-provisioner` (dùng local disk của node):

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 6. Deploy

```bash
kubectl apply -k .
```

```bash
kubectl config set-context --current --namespace=awx
```

## 7. Theo dõi tiến trình

```bash
kubectl get pods -n awx -w

kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager -n awx
```

```bash
kubectl logs -f job/awx-demo-migration-24.6.1 -n awx
```

## 8. Lấy thông tin đăng nhập và truy cập

Xem NodePort được cấp:
```bash
kubectl get svc -n awx
```
→ tìm service `awx-demo-service`, cột `PORT(S)` dạng `80:3XXXX/TCP`.

Lấy mật khẩu admin:
```bash
kubectl get secret awx-demo-admin-password -n awx -o jsonpath="{.data.password}" | base64 --decode ; echo
```

Truy cập:
```
http://<ip-node-bất-kỳ>:<nodeport>/
```
- Username: `admin`
- Password: lấy từ lệnh trên

---

## 9. Sự cố đã gặp và cách xử lý

### 9.1. `ImagePullBackOff` trên pod operator (container `kube-rbac-proxy`)
- **Nguyên nhân:** image `gcr.io/kubebuilder/kube-rbac-proxy` đã bị gỡ khỏi GCR (deprecated từ đầu 2025).
- **Cách xác minh:** `sudo crictl pull <image>` trên node → báo lỗi `NotFound: failed to resolve image`.
- **Fix:** override image trong `kustomization.yaml` sang `registry.k8s.io/kubebuilder/kube-rbac-proxy:v0.15.0` (xem mục 3).

### 9.2. PVC Postgres kẹt `Pending`, pod không được schedule
- **Nguyên nhân:** cluster chưa có StorageClass, hoặc có nhưng không phải `(default)`.
- **Cách xác minh:** `kubectl get storageclass` trả về rỗng, hoặc `kubectl describe pod <postgres-pod>` báo `pod has unbound immediate PersistentVolumeClaims`.
- **Fix:** cài `local-path-provisioner` và patch làm default (xem mục 5), sau đó xóa PVC cũ để nó tạo lại và bind.

### 9.3. Cách dọn sạch để cài lại từ đầu
```bash
kubectl delete -k .              
kubectl delete pvc --all -n awx 
kubectl delete namespace awx    
```

---

## 10. Tham khảo

- Repo: https://github.com/ansible/awx-operator
