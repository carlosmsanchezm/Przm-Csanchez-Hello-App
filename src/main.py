import os
from fastapi import FastAPI

app = FastAPI(title="Hello App")

@app.get("/")
def read_root():
    return {"message": os.getenv("MESSAGE", "Hello from your app!")}

@app.get("/healthz")
def healthz():
    return {"status": "ok"}