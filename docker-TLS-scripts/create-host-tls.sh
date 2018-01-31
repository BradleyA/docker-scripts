#!/bin/bash
#	create-host-tls.sh	3.2	2018-01-31_07:18:02_CST uadmin six-rpi3b.cptx86.com
#	during testing added more checks for files and directories
#	create-host-tls	3.1	2017-12-18_20:16:56_CST uthree
#	Adding version number
#
#	set -x
#	set -v
#
#	Create public and private key and CA for host
#	This script uses two arguements;
#		FQDN - Fully qualified domain name of host requiring new TLS keys
#		NUMBERDAYS - number of days host CA is valid, default 365 days
#	This script creates public and private key and CA in working directory,${HOME}/.docker/docker-ca.
#	Documentation: https://github.com/BradleyA/docker-scripts/tree/master/docker-TLS-scripts
###		
FQDN=$1
NUMBERDAYS=${2:-365}
USERHOME=${3:-/home/}
ADMTLSUSER=${4:-${USER}}
#
#
# >>>>> Add systax --help -? -h -help for scripts
#
#	Check if admin user has home directory on system
if [ ! -d ${USERHOME}${ADMTLSUSER} ] ; then
	echo -e "${0} ${LINENO} [ERROR]:        ${ADMTLSUSER} does not have a home directory\n\ton this system or ${ADMTLSUSER} home directory is not ${USERHOME}${ADMTLSUSER}"  1>&2
	exit 1
fi
#       Check if site CA directory on system
if [ ! -d ${USERHOME}${ADMTLSUSER}/.docker/docker-ca/.private ] ; then
	echo -e "${0} ${LINENO} [ERROR]:        default directory,"     1>&2
	echo -e "${USERHOME}${ADMTLSUSER}/.docker/docker-ca/.private,\n\tnot on system."  1>&2
	echo    "Running create-site-private-public-tls.sh will create directories"
	echo    "and site private and public keys.  Then run sudo"
	echo    "create-new-openssl.cnf-tls.sh to modify openssl.cnf file.  Then run"
	echo    "create-host-tls.sh or create-user-tls.sh as many times as you want."
	exit 1
fi
#
cd ${USERHOME}${ADMTLSUSER}/.docker/docker-ca
#       Check if ca-priv-key.pem file on system
if ! [ -e ${USERHOME}${ADMTLSUSER}/.docker/docker-ca/.private/ca-priv-key.pem ] ; then
	echo -e "${0} ${LINENO} [ERROR]:        Site private key\n\t${USERHOME}${ADMTLSUSER}/.docker/docker-ca/.private/ca-priv-key.pem\n\tis not in this location."   1>&2
	exit 1
fi
#	Prompt for ${FQDN} if argement not entered
if [ -z ${FQDN} ] ; then
	echo -e "Enter fully qualified domain name (FQDN) requiring new TLS keys:"
	read FQDN
fi
#	Check if ${FQDN}-priv-key.pem file exists
if [ -e ${FQDN}-priv-key.pem ] ; then
	echo -e "${0} ${LINENO} [ERROR]:        ${FQDN}-priv-key.pem already\n\texists, renaming existing keys so new keys can be created."   1>&2
	mv ${FQDN}-priv-key.pem ${FQDN}-priv-key.pem`date +%Y-%m-%d_%H:%M:%S_%Z`
	mv ${FQDN}-cert.pem ${FQDN}-cert.pem`date +%Y-%m-%d_%H:%M:%S_%Z`
fi
#
#
#	stop here for the night  need to add comment echo  command to the nex lines
#	alos need to think  through if prompted for FQDN and user hit enter what would happen?
#
#	Check if ${FQDN} string length is nonzero
if [ -n ${FQDN} ] ; then
#	Creating private key for host ${FQDN}
	echo -e "\n${0} ${LINENO} [INFO]:	Creating private key for host\n\t${FQDN}.\n"	1>&2
	openssl genrsa -out ${FQDN}-priv-key.pem 2048
#	Create CSR for host ${FQDN}
	echo -e "${0} ${LINENO} [INFO]:	Generate a Certificate Signing Request\n\t(CSR) for host ${FQDN}.\n"	1>&2
	openssl req -sha256 -new -key ${FQDN}-priv-key.pem -subj "/CN=${FQDN}/subjectAltName=${FQDN}" -out ${FQDN}.csr
#	Create and sign certificate for host ${FQDN}
	echo -e "${0} ${LINENO} [INFO]:	Create and sign a ${NUMBERDAYS} day\n\tcertificate for host ${FQDN}.\n"	1>&2
	openssl x509 -req -days ${NUMBERDAYS} -sha256 -in ${FQDN}.csr -CA ca.pem -CAkey .private/ca-priv-key.pem -CAcreateserial -out ${FQDN}-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
	openssl rsa -in ${FQDN}-priv-key.pem -out ${FQDN}-priv-key.pem
	echo -e "${0} ${LINENO} [INFO]:	Removing certificate signing requests\n\t(CSR) and set file permissions for host ${FQDN} key pairs.\n"	1>&2
	rm ${FQDN}.csr
	chmod 0400 ${FQDN}-priv-key.pem
	chmod 0444 ${FQDN}-cert.pem
else
	echo -e "${0} ${LINENO} [ERROR]:	A Fully Qualified Domain Name\n\t(FQDN) is required to create new host TLS keys."	1>&2
	exit 1
fi
echo -e "${0} ${LINENO} [INFO]:	Instructions for setting up\n\tpublic, private, and certificate files.\n"	1>&2
echo    "Login to host ${FQDN} and create a Docker daemon TLS directory.  "
echo    "		ssh <user>@${FQDN}"
echo    "		sudo mkdir -p /etc/docker/certs.d/daemon"
echo    "Change the directory permission for the Docker daemon TLS directory on\n\thost ${FQDN} and logout."
echo    "		sudo chmod 0700 /etc/docker/certs.d/daemon"
echo    "		logout"
echo    "Copy the keys from the working directory on host two to /tmp directory\n\ton host ${FQDN}."
echo    "		scp ./ca.pem <user>@${FQDN}:'/tmp/ca.pem'"
echo    "		scp ./${FQDN}-cert.pem <user>@${FQDN}:'/tmp/${FQDN}-cert.pem'"
echo    "		scp ./${FQDN}-priv-key.pem <user>@${FQDN}:'/tmp/${FQDN}-priv-key.pem'"
echo    "Login to host ${FQDN} and move key pair files from the /tmp directory\n\tto Docker daemon TLS directory."
echo    "		ssh <user>@${FQDN}"
echo    "		cd /tmp"
echo    "		sudo mv *.pem /etc/docker/certs.d/daemon"
echo    "		sudo chown -R root.root /etc/docker/certs.d/daemon"
echo    "		sudo -i"
echo    "		cd /etc/docker/certs.d/daemon"
echo    "		ln -s ${FQDN}-cert.pem cert.pem"
echo    "		ln -s ${FQDN}-priv-key.pem key.pem"
echo    "		exit"
echo -e "\nAdd the TLS flags to dockerd so dockerd will know you are using TLS.\n\t(--tlsverify, --tlscacert, --tlscert, --tlskey)\n"
echo -e "\nScripts in\n\thttps://github.com/BradleyA/docker-scripts/tree/master/dockerd-configuration-options"
echo -e "will help configure dockerd on systems running Ubuntu 16.04 (systemd)\n\tand Ubuntu 14.04 (Upstart)."
###
