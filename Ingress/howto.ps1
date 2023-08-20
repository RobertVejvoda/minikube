# Expose ingress for internal Hello World apps

##  Instructions:

# Start minikube with docker

minikube start --vm-driver=docker

# Enable ingress

minikube addons enable ingress
minikube addons list | grep "ingress" 


# Create deployments (NodePort is not needed, ClusterIP is enough)

kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --port=8080 --type=NodePort

kubectl create deployment web2 --image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment web2 --port=8080 --type=NodePort

kubectl get service | grep web

kubectl apply -f example-ingress.yaml
# ingress.networking.k8s.io/example-ingress created

sudo minikube tunnel
# ✅  Tunnel successfully started

# in another console (keep current open) 
curl http://127.0.0.1:51813
                          
# Hello, world!
# Version: 1.0.0
# Hostname: web-84fb9498c7-7bjtg

# in another console
kubectl get ingress example-ingress --watch

# update /private/etc/hosts file, add:
sudo code /private/etc/hosts
#      127.0.0.1    hello1.internal
#      127.0.0.1    hello2.internal
        
ping hello1.internal
# PING test1.com (127.0.0.1): 56 data bytes

curl hello1.internal
 
# Hello, world!
# Version: 1.0.0
# Hostname: web-84fb9498c7-w6bkc

curl hello2.com
# Hello, world!
# Version: 2.0.0
# Hostname: web2-7df4dcf77b-66g5b

# cleanup
stop tunnel

kubectl delete -f example-ingress.yaml
# ingress.networking.k8s.io "example-ingress" deleted

kubectl delete service web
# service "web" deleted

kubectl delete service web2
# service "web2" deleted

kubectl delete deployment web
# deployment.apps "web" deleted

kubectl delete deployment web2
# deployment.apps "web2" deleted
