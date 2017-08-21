FROM vault:0.7.3

COPY vault.conf /vault/config/
COPY standard.policy /vault/config/
COPY dbread.policy /vault/config/

COPY certs/support.montagu.crt /vault/config/
COPY certs/QuoVadisOVIntermediateCertificate.crt /vault/config/
RUN cat /vault/config/support.montagu.crt \
        /vault/config/QuoVadisOVIntermediateCertificate.crt \
        > /vault/config/ssl_certificate

WORKDIR /app
COPY scripts/*.sh ./

ENTRYPOINT /app/entrypoint.sh
