FROM oraclelinux:9-slim
RUN microdnf install -y mysql python3-pip gzip \
    gnupg2 && microdnf clean all && \
    pip3 install --no-cache-dir s3cmd
WORKDIR /database
COPY infrastructure/database/backup/db-backup.sh .
COPY infrastructure/database/backup/db-backup-policy.sh .
RUN chmod +x db-backup.sh db-backup-policy.sh
CMD ["bash", "./db-backup.sh"]