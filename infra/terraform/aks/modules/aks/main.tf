resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    environment = "ecosystem-ci"
  }
}

resource "local_file" "kubeconfig-and-ingress" {
  content         = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename        = "./azurek8s"
  file_permission = "0600"

  provisioner "local-exec" {
    command = <<EOT
      helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
      helm install nginx-ingress ingress-nginx/ingress-nginx --create-namespace \
        -n ingress-basic --set controller.replicaCount=2
    EOT

    environment = {
      KUBECONFIG = "./azurek8s"
    }
  }
}