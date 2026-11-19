import os
import uuid
import grpc
from fastapi import FastAPI, HTTPException
from fastapi.responses import PlainTextResponse
from prometheus_client import generate_latest, Counter
import task_pb2
import task_pb2_grpc

app = FastAPI(title="SRE gRPC Gateway")
WORKER_ADDR = os.getenv("WORKER_ADDR", "worker-service:50051")
HTTP_REQUESTS = Counter("gateway_http_requests_total", "Total HTTP requests", ["endpoint"])

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/metrics", response_class=PlainTextResponse)
def metrics():
    return generate_latest()

@app.post("/run")
def trigger_job(payload: str = "sample-workload"):
    HTTP_REQUESTS.labels(endpoint="/run").inc()
    try:
        with grpc.insecure_channel(WORKER_ADDR) as channel:
            stub = task_pb2_grpc.TaskProcessorStub(channel)
            response = stub.ProcessJob(
                task_pb2.JobRequest(job_id=str(uuid.uuid4())[:8], payload=payload),
                timeout=3.0
            )
        return {
            "job_id": response.job_id,
            "status": response.status,
            "worker_pod": response.processed_by
        }
    except grpc.RpcError as e:
        raise HTTPException(status_code=503, detail=f"gRPC backend unavailable: {e.code()}")

