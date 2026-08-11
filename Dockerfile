FROM ubuntu:22.04

# Wyłącza zapytania podczas instalacji
ENV DEBIAN_FRONTEND=noninteractive


# update poiera dostępny katalog, install instaluje to co poniżej i posprzątanie już niepotrzebnego katalogu
Run apt-get update && apt-get install -y \
	bash \
	curl \
	python3 \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*


RUN pip3 install oci-cli

#katalog roboczy
WORKDIR /app

Copy 123.sh /app/123.sh
Run chmod +x /app/123.sh

CMD ["/app/123.sh"]
