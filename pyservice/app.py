from fastapi import FastAPI
import os
import datetime as dt

app = FastAPI()

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "ci-demo-py",
        "version": os.getenv("PY_APP_VERSION", "0.1.0"),
        "commit": os.getenv("PY_APP_COMMIT", "dev"),
        "date": dt.datetime.utcnow().isoformat() + "Z",
    }
