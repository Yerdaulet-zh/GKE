from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import time

# Initialize the FastAPI application
app = FastAPI(
    title="GKE Demo Service",
    description="A simple service with readiness and liveness checks for Kubernetes.",
    version="1.0.0"
)

# Mock data store
items_db = {
    1: {"name": "Cube", "price": 10.50, "tags": ["toy", "puzzle"]},
    2: {"name": "Sphere", "price": 5.00, "tags": ["toy", "ball"]},
}

# --- Pydantic Models ---

class Item(BaseModel):
    name: str
    price: float
    tags: list[str] = []

class Status(BaseModel):
    status: str
    timestamp: float

# --- Liveness and Readiness Probes ---

# Liveness Probe (for K8s health checks)
@app.get("/healthz", response_model=Status, tags=["Probes"], 
         summary="Liveness Check")
async def healthz():
    """
    Indicates the service is alive. 
    If this fails, K8s should restart the pod.
    """
    return {"status": "ok", "timestamp": time.time()}

# Readiness Probe (for K8s traffic routing)
# NOTE: In a real app, this would check database connections, external APIs, etc.
@app.get("/ready", response_model=Status, tags=["Probes"], 
         summary="Readiness Check")
async def ready():
    """
    Indicates the service is ready to handle traffic.
    If this fails, K8s should stop sending traffic to the pod.
    """
    # Simulate a check for external dependencies
    # if not db_connection_ok:
    #     raise HTTPException(status_code=503, detail="Database not ready")
    return {"status": "ready", "timestamp": time.time()}

# --- Application Endpoints ---

@app.get("/", summary="Root Endpoint")
async def root():
    return {"message": "Welcome to the GKE FastAPI Demo!", "version": app.version}

@app.get("/info", summary="General Info")
async def get_info():
    return {
        "service": app.title,
        "environment": "GKE/Kubernetes",
        "author": "Gemini Model"
    }

@app.get("/items/{item_id}", response_model=Item, summary="Get Item by ID")
async def get_item(item_id: int):
    """
    Retrieves a single item from the mock database.
    """
    if item_id not in items_db:
        raise HTTPException(status_code=404, detail="Item not found")
    return items_db[item_id]

@app.post("/items/", response_model=Item, status_code=201, summary="Create New Item")
async def create_item(item: Item):
    """
    Adds a new item to the mock database.
    """
    new_id = max(items_db.keys()) + 1 if items_db else 1
    items_db[new_id] = item.model_dump()
    return items_db[new_id]

