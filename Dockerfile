FROM alpine/git

LABEL "version"="1.0.0"
LABEL "repository"="https://github.com/sjdaws/adr-reindexer"
LABEL "homepage"="https://github.com/sjdaws/adr-reindexer"
LABEL "maintainer"="Scott Dawson <scott@anz.com>"

# Add tools
RUN apk add --no-cache bash curl gzip tar

# Add adr tools
RUN \
    curl -L https://github.com/npryce/adr-tools/archive/3.0.0.tar.gz -o adr-tools.tar.gz && \
    tar zxvf adr-tools.tar.gz && \
    mv adr-tools-3.0.0/src/ /adr-tools

# Add the reindexing script
ADD reindex.sh /reindex.sh
RUN chmod +x /reindex.sh

# Load the reindexing script
ENTRYPOINT ["/reindex.sh"]
