FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates $$ rm -rf /car/lib/apt/lists/*
#ca-certificates certy roota, dla curl i oci do weryfikacji https, rm -rf /car/lib/apt/lists/* usuwa listy pakietów


RUN pip install --no-cache-dir oci cli
#w nowej linii/komendzie, po instalacji wyzej

WORKDIR /app

COPY 123.sh .

ENTRYPOINT ["bash", "123.sh"]

