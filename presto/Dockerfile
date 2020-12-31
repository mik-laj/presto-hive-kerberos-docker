ARG PRESTO_VERSION="330"
FROM prestosql/presto:${PRESTO_VERSION}

# Obtain root privileges
USER 0

# Setup entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/lib/presto/bin/run-presto"]

# Expose HTTPS
EXPOSE 7778

# Restore user
USER presto:presto