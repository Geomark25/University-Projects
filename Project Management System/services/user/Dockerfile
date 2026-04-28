FROM python:3.13.7-slim


ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*


COPY userReq.txt .
RUN pip install --no-cache-dir -r userReq.txt


COPY . .

EXPOSE 8000


CMD ["uvicorn", "userService:app", "--host", "0.0.0.0", "--port", "8000"]