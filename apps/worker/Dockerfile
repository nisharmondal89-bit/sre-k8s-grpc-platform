FROM python:3.12-slim
WORKDIR /app
COPY worker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY proto/task.proto .
RUN python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. task.proto
COPY worker/server.py .
EXPOSE 50051 8000
CMD ["python", "server.py"]

