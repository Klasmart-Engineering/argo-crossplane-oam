# ArgoCD Demo


# What is this?
This repo demonstrates how argocd can be used to deploy microservices to environments in Kubernetes Clusters

# Setup

k3d registry delete k3d-registry.localhost && k3d cluster delete k3s-default

k3d registry create registry.localhost --port 12345

## Dependencies

This repo assumes you already have working knowledge on setting up and deploying to kubernetes clusters.  This tutorial uses tilt, which assumes you have a working cluster running that can be connected to from the machine you are running the demo on.

- [age](https://github.com/FiloSottile/age)
- [sops](https://github.com/mozilla/sops#encrypting-using-age)
- [yq](https://mikefarah.gitbook.io/yq/)
- tilt
- helm
- kubectl
- terraform


## Config File

There are several scripts in the repo that will require inputs from you, the end user.  To streamline this process, it's important that you fill out a config file so that the scripts will have all the resources they need.  Under the secrets repo, create a file called `config.yaml`.  This will hold information prior to starting the stack so that the startup can be automated.  Copy and paste this yaml structure into the config file before continuing on:

    github:
      email: # your github email
      token: # your github token
    argo:
      baseRepo: # Base of the repo you want to deploy. ex) if your app is in an org, use the ssh string for the repo all the way up until you hit the repo name
      manifestRepo: # Repo that the manifests are in
      adminPassword: # The Password for the Argo UI
      publicKey: # Leave Blank
      privateKey: # Leave Blank
    sops:
      publicKey: # Leave Blank


### Creating a GitHub OAuth Token

This repo uses the GitHub Terraform provider to create and delete a temporary SSH key pair for the ArgoCD Operator. Before we can run the terraform code, we need to create an OAuth Token for GitHub. The token is used to create a temporary ssh key for the argocd operator to access the repos you want to deploy.  GitHub has a [tutorial](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) on how to do so.  Make sure the token has the ability to configure ssh keys for your profile.

### Sops Config

The Sops configuration is completely automated, so you will not have to worry about this.  We are using Age to create a key pair for encrypting and decrypting secrets with sops.  This is fine for local development, but it makes sense to use tools like KMS if you want to seal secrets for production.

### SSH Key Pair

Like the Sops setup, you won't have to do any manual configuration for the key pair to access your github repositories.  We create a key pair and use Terraform to assign the public key to your github account.  The private key is then encrypted with sops and deployed into Kuberentes to be decrypted and used by Argo to access your repos.

## Deployment

To deploy the demo, you should be able to run `tilt up` to start the application stack.  Once all of the deployments are green in the tilt UI, you should be able to visit the [ArgoCD](localhost:8080) UI.  The UI is being port-forwarded over http, so you will need to proceed through the warning you browser shows.  Once at the login screen, you can enter the password you set in the config file and see your applications!