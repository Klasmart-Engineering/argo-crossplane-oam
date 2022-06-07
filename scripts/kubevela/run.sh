# 1. build container that includes vela binary
make cross-build

docker build -t oamdev/argo-tool:v1 -f ./scripts/kubevela/Dockerfile .
kind load docker-image oamdev/argo-tool:v1

# 2. restarts argo server and insert plugin configMap, vela init container, vela configMap
kubectl -n argocd apply -f ./scripts/kubevela/vela-cm.yaml
kubectl -n argocd patch cm/argocd-cm -p "$(cat ./scripts/kubevela/argo-cm.yaml)"
kubectl -n argocd patch deploy/argocd-repo-server -p "$(cat ./scripts/kubevela/deploy.yaml)"

# 3. apply argo app to test appfile gitops deployment
kubectl -n argocd apply -f ./scripts/kubevela/app.yaml