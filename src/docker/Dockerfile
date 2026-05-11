# Use postgres:18-bookworm as the base image for in order to be able to install 
# PostgreSQL Anonymizer with apt-get (not available for Debian 13 at the time of 
# writing).
FROM postgres:18-bookworm

# Add the PostgreSQL PGDG apt repo (needed for postgresql-18-postgis-3)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
  && install -d /usr/share/postgresql-common/pgdg \
  && curl -fsSL -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
       https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
       https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
       > /etc/apt/sources.list.d/pgdg.list \
  # Install PostGIS, pgTAP
  && apt-get update && apt-get install -y --no-install-recommends \
       postgresql-18-postgis-3 \
       postgresql-18-pgtap \
  # Add Dalibo repo for PostgreSQL Anonymizer
  && echo "deb http://apt.dalibo.org/labs bookworm-dalibo main" \
       > /etc/apt/sources.list.d/dalibo-labs.list \
  && curl -fsSL -o /etc/apt/trusted.gpg.d/dalibo-labs.gpg \
       https://apt.dalibo.org/labs/debian-dalibo.gpg \
  && apt-get update && apt-get install -y --no-install-recommends \
       postgresql_anonymizer_18 \
  # Clean up
  && apt-get purge --autoremove -y curl \
  && rm -rf /var/lib/apt/lists/*

COPY --chown=postgres:postgres ./postgresql.conf /etc/postgresql.conf
CMD ["postgres", "-c", "config_file=/etc/postgresql.conf"]