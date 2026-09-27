#!/bin/bash
set -e

echo "[1/6] Création du cluster Kind..."
kind create cluster --config kind-config.yaml --name gitops-cluster


echo "[2/6] Installation de Traefik (Ingress Controller)..."
helm repo add traefik https://traefik.github.io/charts 
helm repo update 
helm upgrade --install traefik traefik/traefik --namespace traefik --create-namespace --set service.type=ClusterIP --set-string nodeSelector.ingress-ready=true --set tolerations[0].key=node-role.kubernetes.io/control-plane --set tolerations[0].operator=Exists --set tolerations[0].effect=NoSchedule --set ports.web.hostPort=80 --set ports.websecure.hostPort=443

echo "[3/6] Installation de Prometheus & Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f infra/prometheus-values.yaml

echo "[4/6] Installation d'ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side --force-conflicts
kubectl patch configmap argocd-cmd-params-cm -n argocd -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
kubectl apply -f infra/argocd-ingress.yaml

echo "[5/6] Déploiement de l'application via GitOps..."
kubectl apply -f argocd/application.yaml

echo "[6/6] Récupération des mots de passe ArgoCD/Grafana..."
sleep 5
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d )
GRAFANA_PASSWORD=$(kubectl get secret prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d )

echo "============================================================"
echo "🎉 ENVIRONNEMENT PRÊT !"
echo "============================================================"
echo "🌐 API FastAPI : http://chaos-api.local/api"
echo "📊 Grafana     : http://grafana.local (admin / $GRAFANA_PASSWORD)"
echo "🐙 ArgoCD      : http://argocd.local (admin / $ARGOCD_PASSWORD)"
echo "============================================================"