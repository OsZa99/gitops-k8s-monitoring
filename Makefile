.PHONY: up down start stop traffic test help

help:
	@echo "Commandes disponibles :"
	@echo "  make up      - Crée le cluster et installe tout l'environnement (A à Z)"
	@echo "  make down    - Supprime complètement le cluster"
	@echo "  make start   - Redémarre le cluster"
	@echo "  make stop    - Arrête le cluster"
	@echo "  make traffic - Lance la simulation de trafic / chaos"
	@echo "  make test    - Teste unitairement l'endpoint /api/fast"

up:
	@bash scripts/setup.sh

down:
	@echo "Suppression du cluster..."
	kind delete cluster --name gitops-cluster

start:
	@echo "Redémarrage du cluster..."
	docker start gitops-cluster-control-plane gitops-cluster-worker gitops-cluster-worker2

stop:
	@echo "Arrêt du cluster..."
	docker stop gitops-cluster-control-plane gitops-cluster-worker gitops-cluster-worker2

traffic:
	@bash scripts/generate_traffic.sh

test:
	@curl -s http://chaos-api.local/api/fast | grep -o "C'était super rapide !" && echo " ✅ API OK" || echo " ❌ Erreur API"