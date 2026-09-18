from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator
import random
import asyncio

app = FastAPI(title="Chaos API")

# Cela va créer automatiquement la route /metrics
Instrumentator().instrument(app).expose(app)

@app.get("/api")
def read_root():
    return {"message": "Bienvenue sur la Chaos API"}

@app.get("/api/fast")
def fast_endpoint():
    """Retourne une réponse immédiate sans traitement"""
    return {"message": "C'était super rapide !"}

@app.get("/api/slow")
async def slow_endpoint():
    """Simule une latence aléatoire entre 1 et 3 secondes"""
    delay = random.uniform(1.0, 3.0)
    await asyncio.sleep(delay)
    return {"message": f"C'était lent. J'ai dormi {delay:.2f} secondes."}

@app.get("/api/error")
def error_endpoint():
    """Échoue avec une erreur 500 dans environ 33% des cas"""
    if random.random() < 0.33:
        raise HTTPException(status_code=500, detail="Erreur Interne Simulée (Chaos !)")
    return {"message": "Succès ! (Mais j'échoue 33% du temps)"}