#!/bin/sh
#
# $FreeBSD$
#

set -e

export ASSUME_ALWAYS_YES="YES"
export PKG_DBDIR="/tmp/pkg"
export PERMISSIVE="YES"
export REPO_AUTOUPDATE="NO"
export PKGCMD="/usr/sbin/pkg -d"

_DVD_PACKAGES="databases/influxdb
databases/phppgadmin
databases/postgresql94-client
databases/postgresql94-contrib
databases/postgresql94-server
devel/git
devel/jenkins
editors/vim-lite
lang/php56
net/phpldapadmin
lang/python27
lang/python
mail/opensmtpd
net/rsync
net/openldap24-client
net/openldap24-server
net-mgmt/collectd5
net-mgmt/zabbix24-agent
net-mgmt/zabbix24-frontend
net-mgmt/zabbix24-server
net-mgmt/iftop
security/openvpn
security/openvpn-auth-ldap
security/ca_root_nss
security/py-keyczar
security/py-fail2ban
security/sudo
shells/zsh
sysutils/ansible
sysutils/tmux
sysutils/zxfer
sysutils/iocage-devel
www/gitlab
www/redmine
www/nginx
www/grafana3
hardenedbsd/secadm-kmod
hardenedbsd/secadm"

# If NOPORTS is set for the release, do not attempt to build pkg(8).
if [ ! -f ${PORTSDIR}/Makefile ]; then
	echo "*** ${PORTSDIR} is missing!    ***"
	echo "*** Skipping pkg-stage.sh     ***"
	echo "*** Unset NOPORTS to fix this ***"
	exit 0
fi

if [ ! -x /usr/local/sbin/pkg ]; then
	/etc/rc.d/ldconfig restart
	/usr/bin/make -C ${PORTSDIR}/ports-mgmt/pkg install clean
fi

export DVD_DIR="dvd/packages"
export PKG_ABI=$(pkg config ABI)
export PKG_ALTABI=$(pkg config ALTABI 2>/dev/null)
export PKG_REPODIR="${DVD_DIR}/${PKG_ABI}"

/bin/mkdir -p ${PKG_REPODIR}
if [ ! -z "${PKG_ALTABI}" ]; then
	(cd ${DVD_DIR} && ln -s ${PKG_ABI} ${PKG_ALTABI})
fi

# Ensure the ports listed in _DVD_PACKAGES exist to sanitize the
# final list.
for _P in ${_DVD_PACKAGES}; do
	if [ -d "${PORTSDIR}/${_P}" ]; then
		DVD_PACKAGES="${DVD_PACKAGES} ${_P}"
	else
		echo "*** Skipping nonexistent port: ${_P}"
	fi
done

# Make sure the package list is not empty.
if [ -z "${DVD_PACKAGES}" ]; then
	echo "*** The package list is empty."
	echo "*** Something is very wrong."
	# Exit '0' so the rest of the build process continues
	# so other issues (if any) can be addressed as well.
	exit 0
fi

# Print pkg(8) information to make debugging easier.
${PKGCMD} -vv
${PKGCMD} update -f
${PKGCMD} fetch -o ${PKG_REPODIR} -d ${DVD_PACKAGES}

# Create the 'Latest/pkg.txz' symlink so 'pkg bootstrap' works
# using the on-disc packages.
mkdir -p ${PKG_REPODIR}/Latest
(cd ${PKG_REPODIR}/Latest && \
	ln -s ../All/$(${PKGCMD} rquery %n-%v pkg).txz pkg.txz)

${PKGCMD} repo ${PKG_REPODIR}

# Always exit '0', even if pkg(8) complains about conflicts.
exit 0
