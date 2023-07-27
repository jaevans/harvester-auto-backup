FROM bitnami/kubectl:1.25.12

USER root
RUN useradd -m auto-backup
COPY auto-backup /
RUN chmod +x /auto-backup

USER auto-backup
ENTRYPOINT [ "/auto-backup" ]
CMD ["--help"]