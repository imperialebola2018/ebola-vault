FROM vault:0.9.6
RUN apk add --update openssl curl

COPY vault.conf /vault/config/
COPY certs/support.montagu.crt /vault/config/
COPY certs/QuoVadisOVIntermediateCertificate.crt /vault/config/
RUN cat /vault/config/support.montagu.crt \
        /vault/config/QuoVadisOVIntermediateCertificate.crt \
        > /vault/config/ssl_certificate

WORKDIR /app
COPY scripts/*.sh ./
COPY ssl-key/ssl_private_key.enc /vault/config/ssl_private_key.enc

ENTRYPOINT /app/entrypoint.sh
