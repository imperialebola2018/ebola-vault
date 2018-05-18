FROM vault:0.10.1
RUN apk add --update openssl curl

COPY vault.conf /vault/config/
COPY certs/ebola2018_dide_ic_ac_uk.crt /vault/config/
COPY certs/QuoVadisOVIntermediateCertificate.crt /vault/config/
RUN cat /vault/config/ebola2018_dide_ic_ac_uk.crt \
        /vault/config/QuoVadisOVIntermediateCertificate.crt \
        > /vault/config/ssl_certificate

WORKDIR /app
COPY scripts/*.sh ./
COPY ssl-key/ssl_private_key.enc /vault/config/ssl_private_key.enc

ENTRYPOINT /app/entrypoint.sh
