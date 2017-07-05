FROM vault:0.7.3

COPY vault.conf /vault/config/vault.json

WORKDIR /app
COPY entrypoint.sh .

ENTRYPOINT /app/entrypoint.sh