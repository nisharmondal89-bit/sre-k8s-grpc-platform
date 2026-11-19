import time
import socket
from concurrent import futures
import grpc
from prometheus_client import start_http_server, Counter, Histogram
import task_pb2
import task_pb2_grpc

JOBS_PROCESSED = Counter("grpc_jobs_processed_total", "Total gRPC jobs processed", ["status"])
JOB_LATENCY = Histogram("grpc_job_duration_seconds", "Time spent processing gRPC job")

class TaskProcessorServicer(task_pb2_grpc.TaskProcessorServicer):
    @JOB_LATENCY.time()
    def ProcessJob(self, request, context):
        time.sleep(0.05)  # Simulate compute work
        JOBS_PROCESSED.labels(status="success").inc()
        return task_pb2.JobResponse(
            job_id=request.job_id,
            status="COMPLETED",
            processed_by=socket.gethostname()
        )

def serve():
    start_http_server(8000)  # Prometheus metrics endpoint
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=4))
    task_pb2_grpc.add_TaskProcessorServicer_to_server(TaskProcessorServicer(), server)
    server.add_insecure_port("[::]:50051")
    server.start()
    print("gRPC Worker running on :50051 | Metrics on :8000")
    server.wait_for_termination()

if __name__ == "__main__":
    serve()

