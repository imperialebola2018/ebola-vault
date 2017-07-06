FROM vault:0.7.3

COPY vault.conf /vault/config/
COPY standard.policy /vault/config/
COPY certs/support.montagu.crt /vault/config/ssl_certificate

WORKDIR /app
COPY scripts/*.sh ./

# As soon as we have a real SSL certificate we should remove this line
ENV VAULT_SKIP_VERIFY true
ENTRYPOINT /app/entrypoint.sh
