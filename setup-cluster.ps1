# kubectl alias & autocomplete
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/
alias k=kubectl

# install cluster
brew install minikube

minikube config view
# - memory: 8GB
# - rootless: false
# - cpus: 6
# - driver: docker
# - insecure-registry: true

minikube addons enable dashboard
# minikube addons enable ingress
# minikube addons enable registry
# https://minikube.sigs.k8s.io/docs/handbook/registry/

minikube start # cca 30s

# dapr
dapr init -k --wait
dapr status -k

# zipkin
k create deployment zipkin --image openzipkin/zipkin
k expose deployment zipkin --type ClusterIP --port 9411
k port-forward svc/zipkin 9411:9411
# check: k describe svc zipkin

# monitoring namespace
k create namespace monitoring

# prometheus
# https://docs.dapr.io/operations/observability/metrics/prometheus/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus -n monitoring
# check: kubectl get svc -n monitoring
# The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster: 
# prometheus-server.monitoring.svc.cluster.local
# Get the Prometheus server URL by running these commands in the same shell:
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
k --namespace monitoring port-forward $POD_NAME 9091


# grafana
helm repo add grafana https://grafana.github.io/helm-charts     
helm repo update 
helm install grafana grafana/grafana -n monitoring 
# check: k get svc -n monitoring

k get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
k port-forward svc/grafana 8090:80 -n monitoring

## login: http://localhost:8090/
## admin
## [pwd]

# Add data source & dashboards Dapr to Grafana, master release on https://github.com/dapr/dapr/tree/master/grafana, or check correct version assets https://github.com/dapr/dapr/releases
# Add data source Prometheus: (url consists of name of pod and namespace) 
# - Url: http://prometheus-server.monitoring
# - Name: Dapr
# - Type: Prometheus

# keycloak (todo)

# camunda 
helm repo add camunda https://helm.camunda.io
helm repo update
Helm install camunda camunda/camunda-platform -n camunda -f camunda-values.yaml

# setup Nginx ingress if needed, example in Ingress folder