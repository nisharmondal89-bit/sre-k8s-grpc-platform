FROM python:3.12-slim
WORKDIR /app
COPY gateway/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY proto/task.proto .
RUN python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. task.proto
COPY gateway/main.py .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

