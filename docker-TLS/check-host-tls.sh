#!/bin/bash
# 	docker-TLS/check-host-tls.sh  3.422.894  2019-07-28T10:12:43.958202-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure  uadmin  six-rpi3b.cptx86.com 3.421  
# 	   change DEFAULT_CERTDIR TO DEFAULT_CERT_DAEMON_DIR AND CERTDIR TO CERT_DAEMON_DIR 
# 	docker-TLS/check-host-tls.sh  3.284.751  2019-06-21T21:17:39.403875-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure  uadmin  six-rpi3b.cptx86.com 3.283  
# 	   check-ca-tls.sh draft 
# 	docker-TLS/check-host-tls.sh  3.283.750  2019-06-10T23:51:10.800496-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure  uadmin  six-rpi3b.cptx86.com 3.282  
# 	   docker-TLS/check-ca-tls.sh - complete design - in development #56 
# 	docker-TLS/check-host-tls.sh  3.255.722  2019-06-07T21:01:25.687206-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure  uadmin  six-rpi3b.cptx86.com 3.254  
# 	   docker-TLS/c* - added production standard 8.0 --usage #52 
# 	docker-TLS/check-host-tls.sh  3.245.702  2019-05-07T20:58:06.966364-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure.git  uadmin  six-rpi3b.cptx86.com 3.244  
# 	   docker-TLS/check-host-tls.sh - modify output: add user message about cert expires close #50 
# 	docker-TLS/check-host-tls.sh  3.232.677  2019-04-10T23:04:43.449464-05:00 (CDT)  https://github.com/BradleyA/docker-security-infrastructure.git  uadmin  six-rpi3b.cptx86.com 3.231  
# 	   production standard 6.1.177 Architecture tree 
### production standard 3.0 shellcheck
### production standard 5.1.160 Copyright
#       Copyright (c) 2019 Bradley Allen
#       MIT License is in the online DOCUMENTATION, DOCUMENTATION URL defined below.
### production standard 1.0 DEBUG variable
#       Order of precedence: environment variable, default code
if [ "${DEBUG}" == "" ] ; then DEBUG="0" ; fi   # 0 = debug off, 1 = debug on, 'export DEBUG=1', 'unset DEBUG' to unset environment variable (bash)
#	set -x
#	set -v
BOLD=$(tput -Txterm bold)
NORMAL=$(tput -Txterm sgr0)
### production standard 7.0 Default variable value
DEFAULT_CERT_DAEMON_DIR="/etc/docker/certs.d/daemon/"
### production standard 8.0 --usage
display_usage() {
echo -e "\n${NORMAL}${0} - Check public, private keys, and CA for host"
echo -e "\nUSAGE"
echo -e "   sudo ${0} [<CERT_DAEMON_DIR>]\n"
echo    "   ${0} [--help | -help | help | -h | h | -?]"
echo    "   ${0} [--usage | -usage | -u]"
echo    "   ${0} [--version | -version | -v]"
}
### production standard 0.1.158 --help
display_help() {
display_usage
#       Displaying help DESCRIPTION in English en_US.UTF-8
echo -e "\nDESCRIPTION"
echo    "This script has to be run as root to check public, private keys, and CA in"
echo    "/etc/docker/certs.d/daemon directory(<CERT_DAEMON_DIR>).  This directory was"
echo    "selected to place dockerd TLS certifications because docker registry"
echo    "stores it's TLS certifications in /etc/docker/certs.d.  The certification"
echo    "files and directory permissions are also checked."
echo -e "\nThis script works for the local host only.  To use check-host-tls.sh on a"
echo    "remote hosts (one-rpi3b.cptx86.com) with ssh port of 12323 as uadmin user;"
echo -e "\t${BOLD}ssh -tp 12323 uadmin@one-rpi3b.cptx86.com 'sudo check-host-tls.sh'${NORMAL}"
echo    "To loop through a list of hosts in the cluster use,"
echo    "https://github.com/BradleyA/Linux-admin/tree/master/cluster-command"
echo -e "\t${BOLD}cluster-command.sh special 'sudo check-host-tls.sh'${NORMAL}"
#       Displaying help DESCRIPTION in French fr_CA.UTF-8, fr_FR.UTF-8, fr_CH.UTF-8
if [ "${LANG}" == "fr_CA.UTF-8" ] || [ "${LANG}" == "fr_FR.UTF-8" ] || [ "${LANG}" == "fr_CH.UTF-8" ] ; then
        echo -e "\n--> ${LANG}"
        echo    "<votre aide va ici>" # your help goes here
        echo    "Souhaitez-vous traduire la section description?" # Do you want to translate the description section?
elif ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Your language, ${LANG}, is not supported.  Would you like to translate the description section?" 1>&2
fi
echo -e "\nENVIRONMENT VARIABLES"
echo    "If using the bash shell, enter; 'export DEBUG=1' on the command line to set"
echo    "the DEBUG environment variable to '1' (0 = debug off, 1 = debug on).  Use the"
echo    "command, 'unset DEBUG' to remove the exported information from the DEBUG"
echo    "environment variable.  You are on your own defining environment variables if"
echo    "you are using other shells."
echo    "   DEBUG               (default off '0')"
echo -e "\nOPTIONS"
echo    "   CERT_DAEMON_DIR     dockerd certification directory (default ${DEFAULT_CERT_DAEMON_DIR})"
### production standard 6.1.177 Architecture tree
echo -e "\nARCHITECTURE TREE"   # STORAGE & CERTIFICATION
echo    "/etc/ "
echo    "└── docker/ "
echo    "    └── certs.d/                           <-- Host docker cert directory"
echo    "        └── daemon/                        <-- Daemon cert directory"
echo    "            ├── ca.pem                     <-- Daemon tlscacert"
echo    "            ├── cert.pem                   <-- Daemon tlscert"
echo    "            └── key.pem                    <-- Daemon tlskey"
echo -e "\nDOCUMENTATION"
echo    "   https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS"
echo -e "\nEXAMPLES"
echo    "   Administration user checks local host TLS public, private keys,"
echo    "   CA, and file and directory permissions."
echo -e "\t${BOLD}sudo ${0}${NORMAL}"
}

#       Date and time function ISO 8601
get_date_stamp() {
DATE_STAMP=$(date +%Y-%m-%dT%H:%M:%S.%6N%:z)
TEMP=$(date +%Z)
DATE_STAMP="${DATE_STAMP} (${TEMP})"
}

#       Fully qualified domain name FQDN hostname
LOCALHOST=$(hostname -f)

#       Version
SCRIPT_NAME=$(head -2 "${0}" | awk {'printf $2'})
SCRIPT_VERSION=$(head -2 "${0}" | awk {'printf $3'})

#       UID and GID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

#       Added line because USER is not defined in crobtab jobs
if ! [ "${USER}" == "${LOGNAME}" ] ; then  USER=${LOGNAME} ; fi
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Setting USER to support crobtab...  USER >${USER}<  LOGNAME >${LOGNAME}<" 1>&2 ; fi

#       Default help, usage, and version arguments
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] ; then
        display_help | more
        exit 0
fi
if [ "$1" == "--usage" ] || [ "$1" == "-usage" ] || [ "$1" == "usage" ] || [ "$1" == "-u" ] ; then
        display_usage | more
        exit 0
fi
if [ "$1" == "--version" ] || [ "$1" == "-version" ] || [ "$1" == "version" ] || [ "$1" == "-v" ] ; then
        echo "${SCRIPT_NAME} ${SCRIPT_VERSION}"
        exit 0
fi

#       INFO
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Started..." 1>&2

#       DEBUG
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Name_of_command >${0}< Name_of_arg1 >${1}< Name_of_arg2 >${2}< Name_of_arg3 >${3}<  Version of bash ${BASH_VERSION}" 1>&2 ; fi

### 
CERT_DAEMON_DIR=${1:-${DEFAULT_CERT_DAEMON_DIR}}
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  CERT_DAEMON_DIR >${CERT_DAEMON_DIR}<<" 1>&2 ; fi
#	Must be root to run this script
if ! [ $(id -u) = 0 ] ; then
	display_help | more
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Use sudo ${0}" 1>&2
#	Help hint
	echo -e "\n\t${BOLD}>>   SCRIPT MUST BE RUN AS ROOT   <<\n${NORMAL}"  1>&2
	exit 1
fi
#	Check for ${CERT_DAEMON_DIR} directory
if [ ! -d "${CERT_DAEMON_DIR}" ] ; then
	display_help | more
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${CERT_DAEMON_DIR} does not exist" 1>&2
	exit 1
fi

#	Get currect date in seconds
CURRENT_DATE_SECONDS=$(date '+%s')

#	Get currect date in seconds add 30 days
CURRENT_DATE_SECONDS_PLUS_30_DAYS=$(date '+%s' -d '+30 days')
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Variable... CURRENT_DATE_SECONDS >${CURRENT_DATE_SECONDS}< CURRENT_DATE_SECONDS_PLUS_30_DAYS >${CURRENT_DATE_SECONDS_PLUS_30_DAYS=}<" 1>&2 ; fi

#	View dockerd daemon certificate expiration date of ca.pem file
HOST_EXPIRE_DATE=$(openssl x509 -in "${CERT_DAEMON_DIR}/ca.pem" -noout -enddate  | cut -d '=' -f 2)
HOST_EXPIRE_SECONDS=$(date -d "${HOST_EXPIRE_DATE}" '+%s')
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Variable... HOST_EXPIRE_DATE >${HOST_EXPIRE_DATE}< HOST_EXPIRE_SECONDS >${HOST_EXPIRE_SECONDS}<" 1>&2 ; fi

#	Check if certificate has expired
if [ "${HOST_EXPIRE_SECONDS}" -gt "${CURRENT_DATE_SECONDS}" ] ; then

#	Check if certificate will expire in the next 30 day
	if [ "${HOST_EXPIRE_SECONDS}" -gt "${CURRENT_DATE_SECONDS_PLUS_30_DAYS}" ] ; then
		echo -e "\n\tCertificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/ca.pem, is  ${BOLD}GOOD${NORMAL}  until ${HOST_EXPIRE_DATE}"
	else
		echo -e "\n\tCertificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/ca.pem,  ${BOLD}EXPIRES${NORMAL}  on ${HOST_EXPIRE_DATE}"
		get_date_stamp ; echo -e "\n${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Certificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/ca.pem,  ${BOLD}EXPIRES${NORMAL}  on ${HOST_EXPIRE_DATE}" 1>&2
#		Help hint
		echo -e "\n\t${BOLD}Use script  create-site-private-public-tls.sh  to update expired host TLS on your\n\tsite TLS server.${NORMAL}"
	fi
else
	echo -e "\n\tCertificate on ${LOCALHOST},  ${CERT_DAEMON_DIR}/ca.pem,  ${BOLD}HAS EXPIRED${NORMAL}  on ${HOST_EXPIRE_DATE}"
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Certificate on ${LOCALHOST},  ${CERT_DAEMON_DIR}/ca.pem,  ${BOLD}HAS EXPIRED${NORMAL}  on ${HOST_EXPIRE_DATE}" 1>&2
#	Help hint
	echo -e "\n\t${BOLD}Use script  create-site-private-public-tls.sh  to update expired host TLS on your\n\tsite TLS server.${NORMAL}"
fi


#	View dockerd daemon certificate expiration date of cert.pem file
HOST_EXPIRE_DATE=$(openssl x509 -in "${CERT_DAEMON_DIR}/cert.pem" -noout -enddate  | cut -d '=' -f 2)
HOST_EXPIRE_SECONDS=$(date -d "${HOST_EXPIRE_DATE}" '+%s')
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Variable... HOST_EXPIRE_DATE >${HOST_EXPIRE_DATE}< HOST_EXPIRE_SECONDS >${HOST_EXPIRE_SECONDS}<" 1>&2 ; fi

#	Check if certificate has expired
if [ "${HOST_EXPIRE_SECONDS}" -gt "${CURRENT_DATE_SECONDS}" ] ; then

#	Check if certificate will expire in the next 30 day
	if [ "${HOST_EXPIRE_SECONDS}" -gt "${CURRENT_DATE_SECONDS_PLUS_30_DAYS}" ] ; then
		echo -e "\n\tCertificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/cert.pem, is  ${BOLD}GOOD${NORMAL}  until ${HOST_EXPIRE_DATE}"
	else
		echo -e "\n\tCertificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/cert.pem,  ${BOLD}EXPIRES${NORMAL}  on ${HOST_EXPIRE_DATE}"
		get_date_stamp ; echo -e "\n${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Certificate on ${LOCALHOST}, ${CERT_DAEMON_DIR}/cert.pem,  ${BOLD}EXPIRES${NORMAL}  on ${HOST_EXPIRE_DATE}" 1>&2
#		Help hint
		echo -e "\n\t${BOLD}Use script  create-host-tls.sh  to update expired host TLS on your\n\tsite TLS server.${NORMAL}"
	fi
else
	echo -e "\n\tCertificate on ${LOCALHOST},  ${CERT_DAEMON_DIR}/cert.pem,  ${BOLD}HAS EXPIRED${NORMAL}  on ${HOST_EXPIRE_DATE}"
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Certificate on ${LOCALHOST},  ${CERT_DAEMON_DIR}/cert.pem,  ${BOLD}HAS EXPIRED${NORMAL}  on ${HOST_EXPIRE_DATE}" 1>&2
#	Help hint
	echo -e "\n\t${BOLD}Use script  create-host-tls.sh  to update expired host TLS on your site\n\tTLS server.${NORMAL}"
fi

#	View dockerd daemon certificate issuer data of the ca.pem file
TEMP=$(openssl x509 -in "${CERT_DAEMON_DIR}/ca.pem" -noout -issuer)
echo -e "\n\tView dockerd daemon certificate issuer data of the ca.pem file:\n\t${BOLD}${TEMP}${NORMAL}"

#	View dockerd daemon certificate issuer data of the cert.pem file
TEMP=$(openssl x509 -in "${CERT_DAEMON_DIR}/cert.pem" -noout -issuer)
echo -e "\n\tView dockerd daemon certificate issuer data of the cert.pem file:\n\t${BOLD}${TEMP}${NORMAL}"

#	Verify that dockerd daemon certificate was issued by the CA.
TEMP=$(openssl verify -verbose -CAfile "${CERT_DAEMON_DIR}/ca.pem" "${CERT_DAEMON_DIR}cert.pem")
echo -e "\n\tVerify that dockerd daemon certificate was issued by the CA:\n\t${BOLD}${TEMP}${NORMAL}"

echo -e "\n\tVerify and correct file permissions."

#	Verify and correct file permissions for ${CERT_DAEMON_DIR}/ca.pem
if [ $(stat -Lc %a "${CERT_DAEMON_DIR}/ca.pem") != 444 ]; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${CERT_DAEMON_DIR}ca.pem are not 444.  Correcting $(stat -Lc %a ${CERT_DAEMON_DIR}/ca.pem) to 0444 file permissions." 1>&2
	chmod 0444 "${CERT_DAEMON_DIR}ca.pem"
fi

#	Verify and correct file permissions for ${CERT_DAEMON_DIR}cert.pem
if [ $(stat -Lc %a "${CERT_DAEMON_DIR}/cert.pem") != 444 ]; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${CERT_DAEMON_DIR}cert.pem are not 444.  Correcting $(stat -Lc %a ${CERT_DAEMON_DIR}/cert.pem) to 0444 file permissions." 1>&2
	chmod 0444 "${CERT_DAEMON_DIR}/cert.pem"
fi

#	Verify and correct file permissions for ${CERT_DAEMON_DIR}/key.pem
if [ $(stat -Lc %a "${CERT_DAEMON_DIR}/key.pem") != 400 ]; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${CERT_DAEMON_DIR}key.pem are not 400.  Correcting $(stat -Lc %a ${CERT_DAEMON_DIR}/key.pem) to 0400 file permissions." 1>&2
	chmod 0400 "${CERT_DAEMON_DIR}/key.pem"
fi

#	Verify and correct directory permissions for ${CERT_DAEMON_DIR} directory
if [ $(stat -Lc %a "${CERT_DAEMON_DIR}") != 700 ]; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Directory permissions for ${CERT_DAEMON_DIR} are not 700.  Correcting $(stat -Lc %a ${CERT_DAEMON_DIR}) to 700 directory permissions." 1>&2
	chmod 700 "${CERT_DAEMON_DIR}"
fi

#	Help hint
echo -e "\n\tUse script ${BOLD}create-host-tls.sh${NORMAL} to update host TLS on your\n\tsite TLS server.\n"
 
#	May want to create a version of this script that automates this process for SRE tools,
#	but keep this script for users to run manually,
#	open ticket and remove this comment

#
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Operation finished." 1>&2
###
