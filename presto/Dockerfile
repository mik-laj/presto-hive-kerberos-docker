FROM starburstdata/presto:350-e.7

# Obtain root privileges
USER 0

# Setup entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/lib/presto/bin/launcher", "run"]

# Expose HTTPS
EXPOSE 7778

# Restore user
USER presto:root
