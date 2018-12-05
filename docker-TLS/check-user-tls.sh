#!/bin/bash
# 	docker-TLS/check-user-tls.sh  3.88.445  2018-12-05T16:30:20.949894-06:00 (CST)  https://github.com/BradleyA/docker-scripts  uadmin  six-rpi3b.cptx86.com 3.87  
# 	   added DEBUG environment variable, include process ID in ERROR, INFO, WARN, DEBUG statements, display_help | more , shellcheck #30 
#
### check-user-tls.sh - Check public, private keys, and CA for a user
#       Order of precedence: environment variable, default code
if [ "${DEBUG}" == "" ] ; then DEBUG="0" ; fi   # 0 = debug off, 1 = debug on, 'export DEBUG=1', 'unset DEBUG' to unset environment variable (bash)
#	set -x
#	set -v
BOLD=$(tput -Txterm bold)
NORMAL=$(tput -Txterm sgr0)
###
display_help() {
echo -e "\n${NORMAL}${0} - Check public, private keys, and CA for a user"
echo -e "\nUSAGE\n   ${0} [<TLSUSER>] [<USERHOME>]"
echo    "   ${0} [--help | -help | help | -h | h | -?]"
echo    "   ${0} [--version | -version | -v]"
echo -e "\nDESCRIPTION\nUsers can check their public, private keys, and CA in /home or other"
echo    "non-default home directories.  The file and directory permissions are also"
echo    "checked.  Administrators can check other users certificates by using"
echo    "   sudo ${0} <user-name>."
echo -e "\nEnvironment Variables"
echo    "If using the bash shell, enter; 'export DEBUG=1' on the command line to set"
echo    "the DEBUG environment variable to '1' (0 = debug off, 1 = debug on).  Use the"
echo    "command, 'unset DEBUG' to remove the exported information from the DEBUG"
echo    "environment variable.  You are on your own defining environment variables if"
echo    "you are using other shells."
echo    "   DEBUG       (default '0')"
echo -e "\nOPTIONS"
echo    "   TLSUSER   user, default is user running script"
echo    "   USERHOME  location of user home directory, default /home/"
echo    "      Many sites have different home directory locations (/u/north-office/)"
echo -e "\nDOCUMENTATION\n   https://github.com/BradleyA/docker-scripts/tree/master/docker-TLS"
echo -e "\nEXAMPLES\n   ${0}\n\n   User can check their certificates"
echo -e "\n   ${0} sam /u/north-office/\n\n   User sam checks their certificates in a non-default home directory"
echo -e "\n   sudo ${0} bob\n\n   Administrator checks user bob certificates"
echo -e "\n   sudo ${0} sam /u/north-office/\n\n   Administrator checks user sam certificates in a different home directory"
#       After displaying help in english check for other languages
if ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  ${LANG}, is not supported, Would you like to help translate?" 1>&2
#       elif [ "${LANG}" == "fr_CA.UTF-8" ] ; then
#               get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Display help in ${LANG}" 1>&2
#       else
#               get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Your language, ${LANG}, is not supported.  Would you like to translate?" 1>&2
fi
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

#       Default help and version arguments
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] ; then
        display_help | more
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
TLSUSER=${1:-${USER}}
USERHOME=${2:-/home/}
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  TLSUSER >${TLSUSER}< USERHOME >${USERHOME}<" 1>&2 ; fi

#	Root is required to check other users or user can check their own certs
if ! [ $(id -u) = 0 -o ${USER} = ${TLSUSER} ] ; then
	display_help | more
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Use sudo ${0}  ${TLSUSER}" 1>&2
	echo -e "${BOLD}\n>>   SCRIPT MUST BE RUN AS ROOT TO CHECK <another-user>/.docker DIRECTORY. <<\n${NORMAL}"	1>&2
	exit 1
fi

#	Check if user has home directory on system
if [ ! -d ${USERHOME}${TLSUSER} ] ; then 
	display_help | more
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${TLSUSER} does not have a home directory on this system or ${TLSUSER} home directory is not ${USERHOME}${TLSUSER}." 1>&2
	exit 1
fi

#	Check if user has .docker directory
if [ ! -d ${USERHOME}${TLSUSER}/.docker ] ; then 
	display_help | more
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${TLSUSER} does not have a .docker directory." 1>&2
	exit 1
fi

#	Check if user has .docker ca.pem file
if [ ! -e ${USERHOME}${TLSUSER}/.docker/ca.pem ] ; then 
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${TLSUSER} does not have a .docker/ca.pem file." 1>&2
	exit 1
fi

#	Check if user has .docker cert.pem file
if [ ! -e ${USERHOME}${TLSUSER}/.docker/cert.pem ] ; then 
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${TLSUSER} does not have a .docker/cert.pem file." 1>&2
	exit 1
fi

#	Check if user has .docker key.pem file
if [ ! -e ${USERHOME}${TLSUSER}/.docker/key.pem ] ; then 
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  ${TLSUSER} does not have a .docker/key.pem file." 1>&2
	exit 1
fi

#	View user certificate expiration date of ca.pem file
TEMP=$(openssl x509 -in  ${USERHOME}${TLSUSER}/.docker/ca.pem -noout -enddate)
echo -e "\n${NORMAL}View ${USERHOME}${TLSUSER}/.docker certificate ${BOLD}expiration date of ca.pem ${NORMAL}file:\n\t${BOLD}${TEMP}${NORMAL}"

#	View user certificate expiration date of cert.pem file
TEMP=$(openssl x509 -in ${USERHOME}${TLSUSER}/.docker/cert.pem -noout -enddate)
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate ${BOLD}expiration date of cert.pem ${NORMAL}file:\n\t${BOLD}${TEMP}${NORMAL}"

#	View user certificate issuer data of the ca.pem file.
TEMP=$(openssl x509 -in ${USERHOME}${TLSUSER}/.docker/ca.pem -noout -issuer)
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate ${BOLD}issuer data of the ca.pem ${NORMAL}file:\n\t${BOLD}${TEMP}${NORMAL}"

#	View user certificate issuer data of the cert.pem file.
TEMP=$(openssl x509 -in ${USERHOME}${TLSUSER}/.docker/cert.pem -noout -issuer)
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate ${BOLD}issuer data of the cert.pem ${NORMAL}file:\n\t${BOLD}${TEMP}${NORMAL}"

#	Verify that user public key in your certificate matches the public portion of your private key.
echo -e "\nVerify that user public key in your certificate matches the public portion\n\tof your private key."
(cd ${USERHOME}${TLSUSER}/.docker ; openssl x509 -noout -modulus -in cert.pem | openssl md5 ; openssl rsa -noout -modulus -in key.pem | openssl md5) | uniq
echo -e "${BOLD}WARNING:${NORMAL}  -> If ONLY ONE line of output is returned then the public key\n\tmatches the public portion of your private key.\n"

#	Verify that user certificate was issued by the CA.
echo -e "Verify that user certificate was issued by the CA:${BOLD}\n"
openssl verify -verbose -CAfile ${USERHOME}${TLSUSER}/.docker/ca.pem ${USERHOME}${TLSUSER}/.docker/cert.pem  || { get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  User certificate for ${TLSUSER} on ${LOCALHOST} was NOT issued by CA." ; exit 1; }

#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/ca.pem
echo -e "\n${NORMAL}Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker"
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/ca.pem) != 444 ]; then
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${USERHOME}${TLSUSER}/.docker/ca.pem are not 444.  Correcting $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/ca.pem) to 0444 file permissions" 1>&2
	chmod 0444 ${USERHOME}${TLSUSER}/.docker/ca.pem
fi

#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/cert.pem
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/cert.pem) != 444 ]; then
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${USERHOME}${TLSUSER}/.docker/cert.pem are not 444.  Correcting $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/cert.pem) to 0444 file permissions" 1>&2
	chmod 0444 ${USERHOME}${TLSUSER}/.docker/cert.pem
fi

#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/key.pem
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/key.pem) != 400 ]; then
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  File permissions for ${USERHOME}${TLSUSER}/.docker/key.pem are not 400.  Correcting $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/key.pem) to 0400 file permissions" 1>&2
	chmod 0400 ${USERHOME}${TLSUSER}/.docker/key.pem
fi

#	Verify and correct directory permissions for ${USERHOME}${TLSUSER}/.docker directory
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker) != 700 ]; then
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Directory permissions for ${USERHOME}${TLSUSER}/.docker\n\tare not 700.  Correcting $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker) to 700 directory permissions" 1>&2
	chmod 700 ${USERHOME}${TLSUSER}/.docker
fi

#	Help hint
echo -e "\nUse script ${BOLD}create-user-tls.sh${NORMAL} to update user TLS if user TLS certificate\n\thas expired."
 
#	May want to create a version of this script that automates this process for SRE tools,
#		but keep this script for users to run manually,
#	open ticket and remove this comment

#
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Operation finished." 1>&2
###
