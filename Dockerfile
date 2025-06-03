FROM python:3.11-slim
WORKDIR /app
RUN pip install flask
COPY app.py .
EXPOSE 8000
CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]
