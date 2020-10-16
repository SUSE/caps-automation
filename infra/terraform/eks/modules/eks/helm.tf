provider "helm" {
    #Helm 3
    version = "~> 1.3.2"

    kubernetes {
        config_path = "./kubeconfig_${var.name}"
    }
}
