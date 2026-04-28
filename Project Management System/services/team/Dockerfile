FROM python:3.13.7-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app


RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*


COPY teamReq.txt .
RUN pip install --no-cache-dir -r teamReq.txt

COPY . .


EXPOSE 8001


CMD ["uvicorn", "teamService:app", "--host", "0.0.0.0", "--port", "8001"]