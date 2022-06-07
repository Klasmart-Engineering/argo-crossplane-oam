
print("""
-----------------------------------------------------------------
✨  GitOps platform demonstration. 
   Includes ArgoCD, Crossplane, Kubevela (OAM), Loki.
-----------------------------------------------------------------
""".strip())

#Extensions
load('ext://helm_resource', 'helm_resource')
load('ext://namespace', 'namespace_create', 'namespace_inject')
load('ext://helm_remote', 'helm_remote')

# Settings
update_settings ( max_parallel_updates = 1 , k8s_upsert_timeout_secs = 120 , suppress_unused_image_warnings = None )

# Cert-manager
namespace_create('cert-manager')
helm_remote('cert-manager', repo_url='https://charts.jetstack.io', repo_name='jetstack', namespace='cert-manager', set=['installCRDs=true'])


#Global
nspath = "./demo/namespaces"
argo_app_path= "./demo/argo-app"
demo_deps_path="./demo/charts"
chart_path="./"

# Configuration Scripts
local_resource('setup-github', cmd='./scripts/setup-github.sh')
# local_resource('setup-argo', cmd='./scripts/setup-argo.sh', resource_deps=['setup-github'])
local_resource('setup-key', cmd='./scripts/setup-key.sh')


# SOPS 
namespace_create('sops')

helm_resource(
  name="sops-operator",
  namespace='sops',
  chart="{}/{}".format(demo_deps_path, "sops-operator"),
  resource_deps=['setup-key']
)

helm_remote(chart='localstack', repo_url='https://helm.localstack.cloud', repo_name='localstack-repo', values='demo/values/localstack/values.yaml')
k8s_resource('localstack', labels=['common-infrastructure'], port_forwards=4566)


# ArgoCD
namespace_create('argocd')
namespace_create('workflow')

helm_remote('argo-cd', repo_url='https://argoproj.github.io/argo-helm', namespace='argocd', values=['demo/values/argocd/values.yaml'])

k8s_resource('argo-cd-argocd-server', labels=['argo'], port_forwards='8080')

helm_remote('argo-workflows', repo_name='argo-workflow', repo_url='https://argoproj.github.io/argo-helm', values=['demo/values/argocd-applicationset/values.yaml'])
# helm_remote('argo-workflows', repo_url='https://argoproj.github.io/argo-helm', repo_name='argo-workflow', namespace='workflow', values=['demo/charts/argocd-applicationset/values.yaml'])

k8s_resource(workload='argo-workflows-server', labels=['argo'])
# k8s_resource(workload='argo-workflows-server', labels=['argo'], port_forwards='2746:2746')


# Crossplane
namespace_create('crossplane-system')
helm_remote('crossplane', repo_name='crossplane-stable', namespace='crossplane-system', repo_url='https://charts.crossplane.io/stable')


# Kubevela (OAM)
namespace_create('vela-system')
helm_remote('vela-core', repo_name='kubevela', namespace='crossplane-system', repo_url='https://charts.kubevela.net/core')

local_resource('localstack-crossplane', cmd='./scripts/localstack-crossplane.sh', resource_deps=['crossplane'])

# k8s_yaml('./scripts/kubevela/app.yaml')

k8s_yaml("{}/{}.yaml".format(argo_app_path, "greeter"))
k8s_resource(
  objects=['greeter:applicationset'],
  # resource_deps=['argocd-applicationset'],
  new_name="greeter-application-set"
)


# Microservice
# Namespaces
namespace_create('production')
namespace_create('staging')
namespace_create('dev')


#Dev Deployment
docker_build('greeter',
            context='.',
            dockerfile='./app/docker/Dockerfile',
            entrypoint='/main',
            only=[
                './app/cmd/main.go',
                './app/go.mod',
                './app/go.sum'
            ],
             live_update=[
                sync('./app/go.mod', '/service/go.mod'),
                sync('./app/go.sum', '/service/go.sum'),
                sync('./app/cmd', '/service/cmd'),
             ]
)

helm_resource(
  name="greeter",
  namespace='dev',
  chart="./chart",
  image_deps= ["greeter"],
  image_keys= [('deployment.image', 'deployment.tag')],
  port_forwards=["5555"]
)
