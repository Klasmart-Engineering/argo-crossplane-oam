SECRETS_DIR="./demo/secrets"
CONFIG_FILE="$SECRETS_DIR/config.yaml"
ARGO_DIR="./demo/charts/argo-cd"
# ARGO_VALUE_FILE="$ARGO_DIR/values.yaml"
ARGO_VALUE_FILE="./demo/values/argocd/values.yaml"
CRED_TEMP_FILE="$ARGO_DIR/templates/argocd-configs/repo-creds.yaml"
CRED_FILE="$ARGO_DIR/templates/argocd-configs/repo-creds.enc.yaml"
PRIVATE_KEY=$(yq e '.argo.privateKey' $CONFIG_FILE)
BASE_REPO=$(yq e '.argo.baseRepo' $CONFIG_FILE)
MANIFEST_REPO=$(yq e '.argo.manifestRepo' $CONFIG_FILE)
ARGO_PWD=$(yq e '.argo.adminPassword' $CONFIG_FILE)
BCRYPT_PWD=$(htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/')
SOPS_PUBLIC_KEY=$(yq e '.sops.publicKey' $CONFIG_FILE)

# File name should match temp file variable
cat <<EOF > ./demo/charts/argo-cd/templates/argocd-configs/repo-creds.yaml
apiVersion: isindir.github.com/v1alpha3
kind: SopsSecret
metadata:
  name: argo-secrets
  namespace: argo
spec:
  suspend: false
  secretTemplates:
    - name: repo-cred
      labels:
        argocd.argoproj.io/secret-type: repo-creds
      stringData:
        type: git
        url:
      data:
        sshPrivateKey:
    - name: demo-manifest-repo
      labels:
        argocd.argoproj.io/secret-type: repository
      stringData:
        type: git
        url:
EOF

url="$BASE_REPO" yq e '.spec.secretTemplates[0].stringData.url = env(url)' -i $CRED_TEMP_FILE
key="$PRIVATE_KEY" yq e '.spec.secretTemplates[0].data.sshPrivateKey = env(key)' -i $CRED_TEMP_FILE
url="$MANIFEST_REPO" yq e '.spec.secretTemplates[1].stringData.url = env(url)' -i $CRED_TEMP_FILE

sops -e --age $SOPS_PUBLIC_KEY  --encrypted-suffix='Templates' $CRED_TEMP_FILE > $CRED_FILE
rm $CRED_TEMP_FILE

password="$BCRYPT_PWD" yq e '.configs.secret.argocdServerAdminPassword = env(password)' -i $ARGO_VALUE_FILE

cd $ARGO_DIR

helm dep update