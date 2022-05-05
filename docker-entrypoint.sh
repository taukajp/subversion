#!/usr/bin/env bash

reporoot=/var/svn/repos

# Create apache2 conf file for svn.
cat <<EOF > /etc/apache2/mods-enabled/dav_svn.conf
Alias /repos ${reporoot}
<Location /repos>
    DAV svn
    SVNParentPath ${reporoot}
    SVNListParentPath on
    AuthType Basic
    AuthName "Subversion Repository"
    AuthUserFile /etc/apache2/auth/svn.passwd
    AuthzSVNAccessFile /etc/apache2/auth/svn.authz
    Require valid-user
</Location>
EOF

# Create default user.
if [ ! -f /etc/apache2/auth/svn.passwd ]; then
  htpasswd -cb /etc/apache2/auth/svn.passwd ${SVN_DEFAULT_USER} ${SVN_DEFAULT_USER_PASSWD}

cat <<EOF > /etc/apache2/auth/svn.authz
[groups]
developers = ${SVN_DEFAULT_USER}
[/]
* = r
@developers = rw
EOF

fi

# Create repository root directory.
if [ ! -d ${reporoot} ]; then
	mkdir -p ${reporoot}
  chown -R www-data:www-data ${reporoot} && chmod -R 775 ${reporoot}
fi

# Create default repository.
repopath=${reporoot}/${SVN_DEFAULT_REPOSITORY}
if [ ! -d $repopath ]; then
  svnadmin create $repopath

  svn mkdir file://${repopath}/trunk file://${repopath}/branches file://${repopath}/tags \
    -m "Create repository."

  chown -R www-data:www-data ${reporoot} && chmod -R 775 ${reporoot}

# cat <<EOF >> /etc/apache2/auth/svn.authz
# [${SVN_DEFAULT_REPOSITORY}:/]
# @developers = rw
# EOF

fi

exec "$@"
