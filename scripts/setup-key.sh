SOPS_DIR=""
CONFIG_FILE="./demo/secrets/config.yaml"
KEYS_FILE=keys.txt
KEY_PAIR=$(age-keygen)
PUBLIC_KEY=$(echo $KEY_PAIR | grep -oh "\w*age1\w*")
PRIVATE_KEY=$(echo $KEY_PAIR | grep -oh "\w*AGE-SECRET-KEY-\w*")
CHART_SECRET_FILE="./demo/charts/sops-operator/templates/age_secret.yaml"

if [[ $OSTYPE =~ ^linux ]]; then
    SOPS_DIR=$XDG_CONFIG_HOME/sops/age
else
    SOPS_DIR="$HOME/Library/Application Support/sops/age"
fi

if [[ ! -d $SOPS_DIR ]] ; then
    mkdir "$SOPS_DIR"
fi

if [[ ! -f "$SOPS_DIR/$KEYS_FILE" ]] ; then
    touch "$SOPS_DIR/$KEYS_FILE"
fi

echo "# public key for argocd demo: $PUBLIC_KEY" >> "$SOPS_DIR/$KEYS_FILE"
key=$PUBLIC_KEY yq e ".sops.publicKey = env(key)" -i $CONFIG_FILE
echo $PRIVATE_KEY >> "$SOPS_DIR/$KEYS_FILE"

AGE_KUBE_SECRET=$(kubectl create secret generic --from-file "$SOPS_DIR/$KEYS_FILE" --dry-run=client -o=yaml age-keys)
echo "$AGE_KUBE_SECRET" > $CHART_SECRET_FILE