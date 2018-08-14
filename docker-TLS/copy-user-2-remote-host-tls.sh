#!/bin/bash
# 	docker-TLS/copy-user-2-remote-host-tls.sh  3.42.391  2018-08-12_10:59:20_CDT  https://github.com/BradleyA/docker-scripts  uadmin  three-rpi3b.cptx86.com 3.41-8-g21e9f27  
# 	   sync to standard script design changes 
# 	copy-user-2-remote-host-tls.sh	3.29.361	2018-06-22_11:36:41_CDT uadmin two.cptx86.com 3.28-19-ga977649 
# 	   format output to help user 
###
DEBUG=0                 # 0 = debug off, 1 = debug on
#	set -x
#	set -v
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
###
display_help() {
echo -e "\n${NORMAL}${0} - Copy user TLS public, private keys and CA to remote host."
echo -e "\nUSAGE\n   ${0} <REMOTEHOST> [<TLSUSER>] [<USERHOME>] [<ADMTLSUSER>] [SSHPORT]"
echo    "   ${0} [--help | -help | help | -h | h | -? | ?]"
echo    "   ${0} [--version | -version | -v]"
echo -e "\nDESCRIPTION\nAn administration user can run this script to copy TLSUSER public, private"
echo    "keys, and CA to a remote host."
echo -e "\nOPTIONS"
echo    "   REMOTEHOST   name of host to copy certificates to"
echo    "   TLSUSER      user requiring new TLS keys on remote host, default is user"
echo    "                running script"
echo    "   USERHOME     location of admin user directory, default is /home/"
echo    "                Many sites have different home directories (/u/north-office/)"
echo    "   ADMTLSUSER   site administrator account creating TLS keys, default is user"
echo    "                running script"
echo    "                site administrator will have accounts on all systems"
echo    "   SSHPORT      SSH server port, default is port 22"
echo -e "\nDOCUMENTATION\n   https://github.com/BradleyA/docker-scripts/tree/master/docker-TLS"
echo -e "\nEXAMPLES\n   ${0} two.cptx86.com bob /u/north-office/ uadmin 12323\n"
echo    "   Administrator copies TLS keys and CA to remote host, two.cptx86.com, for"
echo    "   user bob, using local home directory, /u/north-office/, administrator user,"
echo    "   uadmin, on port 12323."
if ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        echo -e "${NORMAL}${0} ${LINENO} [${BOLD}WARNING${NORMAL}]:     Your language, ${LANG}, is not supported.\n\tWould you like to help?\n" 1>&2
fi
}
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] || [ "$1" == "?" ] ; then
	display_help
	exit 0
fi 
if [ "$1" == "--version" ] || [ "$1" == "-version" ] || [ "$1" == "version" ] || [ "$1" == "-v" ] ; then
        head -2 ${0} | awk {'print$2"\t"$3'}
        exit 0
fi
###
REMOTEHOST=$1
TLSUSER=${2:-${USER}}
USERHOME=${3:-/home/}
ADMTLSUSER=${4:-${USER}}
SSHPORT=${5:-22}
if [ "${DEBUG}" == "1" ] ; then echo -e "> DEBUG ${LINENO}  REMOTEHOST >${REMOTEHOST}< TLSUSER >${TLSUSER}< USERHOME >${USERHOME}< ADMTLSUSER >${ADMTLSUSER}< SSHPORT >${SSHPORT}<" 1>&2 ; fi
#	Check if admin user has home directory on system
if [ ! -d ${USERHOME}${ADMTLSUSER} ] ; then
	display_help
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}ERROR${NORMAL}]:	${ADMTLSUSER} does not have a home directory\n\ton this system or ${ADMTLSUSER} home directory is not ${USERHOME}${ADMTLSUSER}"	1>&2
	exit 1
fi
#	Check if ${USERHOME}${ADMTLSUSER}/.docker/docker-ca directory on system
if [ ! -d ${USERHOME}${ADMTLSUSER}/.docker/docker-ca ] ; then
	display_help
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}ERROR${NORMAL}]:	default directory,"	1>&2
	echo -e "\t${USERHOME}${ADMTLSUSER}/.docker/docker-ca,\n\tnot on system."	1>&2
	echo -e "\tRunning create-site-private-public-tls.sh will create directories"
	echo -e "\tand site private and public keys.  Then run sudo"
	echo -e "\tcreate-new-openssl.cnf-tls.sh to modify openssl.cnf file."
	exit 1
fi
#	Check if ${TLSUSER}-user-priv-key.pem file on system
if ! [ -e ${USERHOME}${ADMTLSUSER}/.docker/docker-ca/${TLSUSER}-user-priv-key.pem ] ; then
	display_help
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}ERROR${NORMAL}]:	The ${TLSUSER}-user-priv-key.pem\n\tfile was not found in ${USERHOME}${ADMTLSUSER}/.docker/docker-ca."	1>&2
	echo -e "\tRunning create-user-tls.sh will create public and private keys."
	exit 1
fi
#	Prompt for ${REMOTEHOST} if argement not entered
if [ -z ${REMOTEHOST} ] ; then
	echo    "Enter remote host where TLS keys are to be copied:"
	read REMOTEHOST
fi
#	Check if ${REMOTEHOST} string length is zero
if [ -z ${REMOTEHOST} ] ; then
	display_help
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}ERROR${NORMAL}]:	Remote host is required.\n"	1>&2
	exit 1
fi
#	Check if ${REMOTEHOST} is available on port ${SSHPORT}  # >>> try if $(ssh ${NODE} exit >/dev/null) ; then
if $(nc -z  ${REMOTEHOST} ${SSHPORT} >/dev/null) ; then
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}INFO${NORMAL}]:	${ADMTLSUSER} may receive password and\n\tpassphrase prompt from ${REMOTEHOST}. Running\n\tssh-copy-id ${ADMTLSUSER}@${REMOTEHOST} may stop the prompts."
	ssh -tp ${SSHPORT} ${ADMTLSUSER}@${REMOTEHOST} " cd ~${TLSUSER} " || { echo "${0} ${LINENO} [ERROR]:	${TLSUSER} does not have home directory on ${REMOTEHOST}" ; exit 1; }
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}INFO${NORMAL}]:	Create directory, change\n\tfile permissions, and copy TLS keys to ${TLSUSER}@${REMOTEHOST}."
	cd ${USERHOME}${ADMTLSUSER}/.docker/docker-ca
	mkdir -p ${TLSUSER}/.docker
	chmod 700 ${TLSUSER}/.docker
	cp -p ca.pem ${TLSUSER}/.docker
	cp -p ${TLSUSER}-user-cert.pem ${TLSUSER}/.docker
	cp -p ${TLSUSER}-user-priv-key.pem ${TLSUSER}/.docker
	TIMESTAMP=`date +%Y-%m-%d-%H-%M-%S-%Z`
	cd ${TLSUSER}/.docker
	ln -s ${TLSUSER}-user-cert.pem cert.pem
	ln -s ${TLSUSER}-user-priv-key.pem key.pem
	cd ..
	tar -cf ./${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar .docker
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}INFO${NORMAL}]:	Transfer TLS keys to ${TLSUSER}@${REMOTEHOST}."
	scp -pP ${SSHPORT}  ./${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar ${ADMTLSUSER}@${REMOTEHOST}:/tmp
#	Check if ${TLSUSER} == ${ADMTLSUSER} because sudo is not required for user copying their certs
	if [ ${TLSUSER} == ${ADMTLSUSER} ] ; then
		ssh -tp ${SSHPORT} ${ADMTLSUSER}@${REMOTEHOST} " cd ~${TLSUSER} ; tar -xf /tmp/${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar ; rm /tmp/${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar ; chown -R ${TLSUSER}.${TLSUSER} .docker "
	else
		ssh -tp ${SSHPORT} ${ADMTLSUSER}@${REMOTEHOST} " cd ~${TLSUSER} ; sudo tar -xf /tmp/${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar ; rm /tmp/${TLSUSER}${REMOTEHOST}${TIMESTAMP}.tar ; sudo chown -R ${TLSUSER}.${TLSUSER} .docker "
	fi
#	Remove ${TLSUSER}/.docker and tar file from ${USERHOME}${ADMTLSUSER}/.docker/docker-ca
	cd ..
	rm -rf ${TLSUSER}
#	Display instructions about cert environment variables
	echo -e "\nTo set environment variables permanently, add them to the user's"
	echo -e "\t.bashrc.  These environment variables will be set each time the user"
	echo -e "\tlogs into the computer system.  Edit your .bashrc file (or the"
	echo -e "\tcorrect shell if different) and prepend the following two lines."
	echo -e "\texport DOCKER_HOST=tcp://\`hostname -f\`:2376"
	echo -e "\texport DOCKER_TLS_VERIFY=1"
#
	echo -e "\n${NORMAL}${0} ${LINENO} [${BOLD}INFO${NORMAL}]:	Done."
	exit 0
else
	display_help
	echo -e "${NORMAL}${0} ${LINENO} [${BOLD}ERROR${NORMAL}]:	${REMOTEHOST} not responding on port ${SSHPORT}.\n"	1>&2
	exit 1
fi
###
