#!/bin/bash
#	check-user-tls.sh	1.1	2018-01-28_15:25:06_CST uadmin four-rpi3b.cptx86.com
#	add section to check file permissions and correct if not correct ${USERHOME}${TLSUSER}/.docker
#	check-user-tls.sh	1.0	2018-01-25_21:46:22_CST uadmin rpi3b-four.cptx86.com
#	change logic to allow user to check own certs without being root
#
#	set -x
#	set -v
#
#	Check public, private keys, and CA for a user
#	This script uses two arguements;
#		TLSUSER - user, default is user running script
#		USERHOME - location of user home directory, default is /home/
#			Many sites have different home directories locations (/u/north-office/<user>)
#
###
TLSUSER=$1
USERHOME=${2:-/home/}
#	Check if user is entered as parameter
if ! [ -z ${TLSUSER} ] ; then
#       Root is required to check other users or user can check own certs
	if ! [ $(id -u) = 0 -o ${USER} = ${TLSUSER} ] ; then
        	echo "${0} ${LINENO} [ERROR]:   Use sudo ${0} <TLSUSER>"  1>&2
        	echo -e "\n>>   SCRIPT MUST BE RUN AS ROOT TO CHECK <another-user>/.docker DIRECTORY. <<\n"     1>&2
        	exit 1
	fi
else
	TLSUSER=${USER}
fi
#	Check if user has home directory on system
if [ ! -d ${USERHOME}${TLSUSER} ] ; then 
        echo -e "${0} ${LINENO} [ERROR]:	${TLSUSER} does not have a home directory\n\ton this system or ${TLSUSER} home directory is not ${USERHOME}${TLSUSER}"	1>&2
	exit 1
fi
#	Check if user has .docker directory
if [ ! -d ${USERHOME}${TLSUSER}/.docker ] ; then 
        echo -e "${0} ${LINENO} [ERROR]:	${TLSUSER} does not have a .docker directory"	1>&2
	exit 1
fi
#	View user certificate expiration date of ca.pem file
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate expiration date of ca.pem file."
openssl x509 -in  ${USERHOME}${TLSUSER}/.docker/ca.pem -noout -enddate
#	View user certificate expiration date of cert.pem file
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate expiration date of cert.pem file"
openssl x509 -in ${USERHOME}${TLSUSER}/.docker/cert.pem -noout -enddate
#	View user certificate issuer data of the ca.pem file.
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate issuer data of the ca.pem file."
openssl x509 -in ${USERHOME}${TLSUSER}/.docker/ca.pem -noout -issuer
#	View user certificate issuer data of the cert.pem file.
echo -e "\nView ${USERHOME}${TLSUSER}/.docker certificate issuer data of the cert.pem file."
openssl x509 -in ${USERHOME}${TLSUSER}/.docker/cert.pem -noout -issuer
#	Verify that user public key in your certificate matches the public portion of your private key.
echo -e "\nVerify that user public key in your certificate matches the public portion of your private key."
(cd ${USERHOME}${TLSUSER}/.docker ; openssl x509 -noout -modulus -in cert.pem | openssl md5 ; openssl rsa -noout -modulus -in key.pem | openssl md5) | uniq
echo -e "If only one line of output is returned then the public key matches the public portion of your private key.\n"
#	Verify that user certificate was issued by the CA.
echo    "Verify that user certificate was issued by the CA."
openssl verify -verbose -CAfile ${USERHOME}${TLSUSER}/.docker/ca.pem ${USERHOME}${TLSUSER}/.docker/cert.pem
#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/ca.pem
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/ca.pem) != 444 ]; then
	echo -e "${0} ${LINENO} [ERROR]:	File permissions for ${USERHOME}${TLSUSER}/.docker/ca.pem\n\tare not 444.  Correcting file permissions"	1>&2
	chmod 0444 ${USERHOME}${TLSUSER}/.docker/ca.pem
fi
#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/cert.pem
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/cert.pem) != 444 ]; then
	echo -e "${0} ${LINENO} [ERROR]:	File permissions for ${USERHOME}${TLSUSER}/.docker/cert.pem\n\tare not 444.  Correcting file permissions"	1>&2
	chmod 0444 ${USERHOME}${TLSUSER}/.docker/cert.pem
fi
#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker/key.pem
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker/key.pem) != 400 ]; then
	echo -e "${0} ${LINENO} [ERROR]:	File permissions for ${USERHOME}${TLSUSER}/.docker/key.pem\n\tare not 400.  Correcting file permissions"	1>&2
	chmod 0400 ${USERHOME}${TLSUSER}/.docker/key.pem
fi
#	Verify and correct file permissions for ${USERHOME}${TLSUSER}/.docker directory
if [ $(stat -Lc %a ${USERHOME}${TLSUSER}/.docker) != 700 ]; then
	echo -e "${0} ${LINENO} [ERROR]:	File permissions for ${USERHOME}${TLSUSER}/.docker\n\tare not 700.  Correcting file permissions"	1>&2
	chmod 700 ${USERHOME}${TLSUSER}/.docker/key.pem
fi
#
#	May want to create a version of this script that automates this process for SRE tools,
#		but keep this script for users to run manually,
#		but remove the root requirement from the manual version
#		because users can view their own ~/.docker directory
