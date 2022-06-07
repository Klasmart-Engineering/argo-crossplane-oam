SECRETS_DIR="./demo/secrets"
GITHUB_REPO="./demo/github"
KEY_NAME="key-pair"
CONFIG_FILE="$SECRETS_DIR/config.yaml"
EMAIL=$(yq e '.github.email' "$CONFIG_FILE")
export GITHUB_TOKEN=$(yq e '.github.token' "$CONFIG_FILE")

ssh-keygen -t ed25519 -C "$EMAIL" -f "$SECRETS_DIR/$KEY_NAME" -q -N "" <<< y

PUBLIC_KEY=$(cat "$SECRETS_DIR/$KEY_NAME.pub" | base64)
PRIVATE_KEY=$(cat "$SECRETS_DIR/$KEY_NAME" | base64)

key=$PUBLIC_KEY yq e ".argo.publicKey = env(key)" -i "$CONFIG_FILE"
key="$PRIVATE_KEY" yq e ".argo.privateKey = env(key)" -i "$CONFIG_FILE"

cd $GITHUB_REPO
terraform init
terraform apply -auto-approve