curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh

mv kubectl-crossplane /usr/local/bin

kubectl crossplane install provider crossplane/provider-aws:v0.20.0

# install a secret and providerconfig for localstack   
kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-aws/master/examples/providerconfig/localstack.yaml

# patch provider config to point to the right endpoint
kubectl patch providerconfig example --type=json --patch='[{"op": "replace", "path": "/spec/endpoint/url/static", "value": "http://localstack.default.svc.cluster.local:4566"}]'

kubectl get providers.pkg.crossplane.io,providerconfigs.aws.crossplane.io
