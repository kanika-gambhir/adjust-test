
# Create Resource Groups
resource "azurerm_resource_group" "arg" {
  name     = "${var.project}RSG01"
  location = "${var.region}"
 
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.project}AKS01"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name       = "default"
    node_count = "2"
    vm_size    = "standard_d2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "local_file" "deploy" {
  content = <<YAML

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui-dep
  labels:
    app: ui
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ui
  template:
    metadata:
      labels:
        app: ui
    spec:
      containers:
      - name: ruby
        image: docker.io/kanika02/rubyapp_adjust:$(imagetag)
        livenessProbe:
          exec:
            command: 
            - curl
            - http://localhost
          initialDelaySeconds: 5
          periodSeconds: 3
        readinessProbe:
          exec:
            command: 
            - curl
            - http://localhost/healthcheck
          initialDelaySeconds: 5          
          periodSeconds: 3		
        ports:
        - containerPort: 80
---
kind: Service
apiVersion: v1
metadata:
  name: ui-service

spec:
  type: LoadBalancer
  selector:
    app: ui
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

YAML

  filename = "${path.module}/deploy.yml"
}

resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.cluster.kube_admin_config_raw}"
  filename = "${path.module}/kubeconfig"
}


resource "null_resource" "kubectl-1" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_file.kubeconfig.filename} apply -f ${local_file.deploy.filename} && sleep 300"
  }
  triggers = {
        change_in_deploy = "${local_file.deploy.content}"
    }
}


provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)}"
  insecure = "true"
  
} 

data "kubernetes_service" "ui-service" {
  metadata {
    name = "ui-service"
  }
  depends_on = ["null_resource.kubectl-1"]
}

output "applicationendpoint" {

  value = "${data.kubernetes_service.ui-service.status.0.load_balancer.0.ingress.0.ip}"
  
}

