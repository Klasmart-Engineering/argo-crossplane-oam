resource "github_user_ssh_key" "argo_demo_key" {
  title = "argo-demo-key"
  key   = file("../secrets/key-pair.pub")
}