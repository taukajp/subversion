FROM debian:11

# Environment variables
ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    SVN_DEFAULT_USER="default" \
    SVN_DEFAULT_USER_PASSWD="default" \
    SVN_DEFAULT_REPOSITORY="default"

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # Install packages
    vim \
    apache2 apache2-utils \
    subversion subversion-tools libapache2-mod-svn libsvn-dev \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Enable a svn module
RUN a2enmod dav dav_svn authz_svn

EXPOSE 80

# Add a script to be executed every time the container starts.
COPY docker-entrypoint.sh apache2foreground.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh /usr/bin/apache2foreground.sh
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/apache2foreground.sh"]
