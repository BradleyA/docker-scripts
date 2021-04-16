# docker-TLS

These bash scripts will create, copy, and check TLS public keys, private keys, and self-signed certificates for the docker user, daemon, and docker swarm.  After many reinstalls of OS's and Docker, I got tried of entering the cryptic command line text required to setup Docker to use TLS.

#### If you like this repository, select in the upper-right corner, [![GitHub stars](https://img.shields.io/github/stars/BradleyA/docker-security-infrastructure.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BradleyA/docker-security-infrastructure/stargazers/), thank you.

These bash scripts also help minimize the exposure to risk when incidents happen requiring you to be agile and replace impacted certificates quickly. 

**create-site-private-public-tls.sh** - Run this script first on your host that will be creating all your TLS keys other than your registry certifications.  It creates the site private and CA keys that all other TLS keys at your site will be using.  It creates the working directories  $HOME/.docker/docker-ca and $HOME/.docker/docker-ca/.private for your site public and private keys.  If you later choose to use a different host to continue creating your user and host TLS keys; copy the files in $HOME/.docker/docker-ca and $HOME/.docker/docker-ca/.private to the new host then run create-new-openssl.cnf-tls.sh scipt on the new host.

**create-new-openssl.cnf-tls.sh** - Run this script as an administration user second except for your registry certifications.  It is required to make changes to the /etc/ssl/openssl.cnf file on your host.  These changes are required to run **create-user-tls.sh** and **create-host-tls.sh** scripts.  This script is not required to run create-site-private-public-tls.sh script.  It is only required to be run once on a host that will be creating all your TLS host and user keys.  If you choose to use a different host to continue creating your user and host TLS keys, run this script on the new host to modify openssl.cnf file.

**create-user-tls.sh** - Run this script any time a user requires a new Docker public and private TLS key.

**create-host-tls.sh** - Run this script any time a host requires a new Docker public and private TLS key.

**copy-user-2-remote-host-tls.sh** - An administration user can run this script to copy user public, private TLS keys, and CA to a remote host.

**copy-host-2-remote-host-tls.sh** - An administration user can run this script to copy host public, private TLS keys, and CA to a remote host.

**check-user-tls.sh** - A user can check their public, private keys, and CA in $HOME/.docker or an administration user can check other users certificates by using sudo.

**check-host-tls.sh** - An administration user can check a host public, private keys, and CA in /etc/docker/certs.d/daemon by using sudo.

**check-ca-tls.sh** - An administration user can check ca.pem in any directory.

**create-registry-tls.sh** - Run this script to create Docker private registry certificates on any host in the directory; ~/.docker/.  It will create a working directory, ~/.docker/registry-certs-<REGISTRY_HOST>-<REGISTRY_PORT>.  The <REGISTRY_PORT>
number is not required when creating a private registry certificates.  It is used to keep track of multiple certificates for multiple private registries on the same host.  The scripts create-site-private-public-tls.sh and create-new-openssl.cnf-tls.sh are NOT required to create or use a private registry.

**copy-registry-tls.sh** - A user with administration authority uses this script to copy Docker private registry certificates from ~/.docker/registry-certs-<REGISTRY_HOST>-<REGISTRY_PORT> directory on this system to systems in <SYSTEMS_FILE> which MUST include the <REGISTRY_HOST>.  The certificates (domain.{crt,key}) for the <REGISTRY_HOST> are coped to it, into the following directory: <DATA_DIR>/<CLUSTER>/docker-registry/<REGISTRY_HOST>-<REGISTRY_PORT>/certs/.  The daemon registry domain cert (ca.crt) is copied to all the systems found in <SYSTEMS_FILE> in the following directory, /etc/docker/certs.d/<REGISTRY_HOST>:<REGISTRY_PORT>/.

**check-registry-tls.sh** - This script has to be run as root to check daemon registry cert (ca.crt), registry cert (domain.crt), and registry private key (domain.key) in /etc/docker/certs.d/<REGISTRY_HOST>:<REGISTRY_PORT>/ and <DATA_DIR>/<CLUSTER>/docker-registry/<REGISTRY_HOST>-<REGISTRY_PORT>/certs/ directories.  The certification files and directory permissions are also checked.  This script works for the local host only.  To use check-registry-tls.sh on a remote hosts (one-rpi3b.cptx86.com) with ssh port of 12323 as uadmin user; **ssh -tp 12323 uadmin@one-rpi3b.cptx86.com 'sudo check-registry-tls.sh two.cptx86.com 17313'**.  To loop through a list of hosts in the cluster use, https://github.com/BradleyA/Linux-admin/tree/master/cluster-command, **cluster-command.sh special 'sudo check-registry-tls.sh two.cptx86.com 17313'**

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Install
To Install, change into a directory that you want to download the scripts. Use git to pull or clone these scripts into the directory. If you do not have Git installed then enter; "sudo apt-get install git" if using Debian/Ubuntu. Other Linux distribution install methods can be found here: https://git-scm.com/download/linux. On the GitHub page of this script use the "HTTPS clone URL" with the 'git clone' command.
    
    git clone https://github.com/BradleyA/docker-security-infrastructure
    cd docker-security-infrastructure/docker-TLS
    
    sudo mkdir -p /usr/local/bin
    sudo chown $USER:$(id -g) /usr/local/bin
    chmod 0775 /usr/local/bin
    mv c* /usr/local/bin
    cd ../..
    rm -rf docker-security-infrastructure

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
Run this script first on your host to create your site private and public TLS keys.  To change the default number of days (730 days = 2 years) enter a number of days as the parameter (example: create-site-private-public-tls 365 ).

    create-site-private-public-tls.sh <#days>

## Output
    $ create-site-private-public-tls.sh 366
    2019-12-29T14:54:21.336685-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-site-private-public-tls.sh[27357] 3.560.1137 167 uadmin 10000:10000 [INFO]    Started...
	Creating private key and prompting for a new passphrase in /home/uadmin/.docker/docker-ca/.private
    Generating RSA private key, 4096 bit long modulus
    ..................................................................++
    ................................................................................................................................    .........................................................++
    e is 65537 (0x10001)
    Enter pass phrase for ca-priv-key.pem--2019-12-29T14:54:21-CST:
    Verifying - Enter pass phrase for ca-priv-key.pem--2019-12-29T14:54:21-CST:

	The following is a list of prompts and example answers are in parentheses.
	Country Name (US), State or Province Name (Texas), Locality Name (Cedar
	Park), Organization Name (Company Name), Organizational Unit Name (IT -
	SRE Team Central US), Common Name (five-rpi3b.cptx86.com), and Email Address

	Creating public key good for  366  days in /home/uadmin/.docker/docker-ca directory.

    Enter pass phrase for ca-priv-key.pem:
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [AU]:US
    State or Province Name (full name) [Some-State]:Texas
    Locality Name (eg, city) []:Cedar Park
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:Small Company
    Organizational Unit Name (eg, section) []:IT SRE team #3
    Common Name (e.g. server FQDN or YOUR name) []:five-rpi3b.cptx86.com
    Email Address []:

	These certificates are valid for  366  days or until 2020-12-29T14:56:22-CST

    lrwxrwxrwx 1 uadmin uadmin 48 Dec 29 14:54 ca-priv-key.pem -> ../site/ca-priv-key.pem--2019-12-29T14:54:21-CST
    lrwxrwxrwx 1 uadmin uadmin 87 Dec 29 14:56 ca.pem -> site/ca.pem--2019-12-29T14:54:21-CST---2019-12-29T14:56:22-CST--2020-12-29T14:56:22-CST

	Now that the certificate has been generated, it would be prudent to move
	the private key to a Universal Serial Bus (USB) memory stick after creating your
	other host and user keys.  Remove the private key from the system and store the USB
	memory stick in a locked fireproof location.  Also document the date when to renew
	these certificates and set an operations or project management calendar or ticket
	entry about 15 days before renewal as a reminder.
    2019-12-29T14:56:22.250857-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-site-private-public-tls.sh[27357] 3.560.1137 272 uadmin 10000:10000 [INFO]    Operation finished...

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
Run this script second on your host that will be used to create all your certificates.  This script makes a change to the openssl.cnf file.

    sudo create-new-openssl.cnf-tls.sh

## Output
    $ sudo ./create-new-openssl.cnf-tls.sh
    2019-12-29T15:08:13.455810-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-new-openssl.cnf-tls.sh[30842] 3.558.1133 134 root 0:0 [INFO]    Started...
	This script will make changes to /etc/ssl/openssl.cnf file.
	These changes are required before creating user and host TLS keys for Docker.
	Run this script before running the user and host TLS scripts.  It is not
	required to be run on hosts not creating TLS keys.

	Creating backup file of /etc/ssl/openssl.cnf and naming it /etc/ssl/openssl.cnf-2019-12-29T15:08:13.419065-06:00
    2019-12-29T15:08:13.475798-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-new-openssl.cnf-tls.sh[30842] 3.558.1133 174 root 0:0 [INFO]    Adding the extended KeyUsage at the beginning of [ v3_ca ] section.
    2019-12-29T15:08:13.488252-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-new-openssl.cnf-tls.sh[30842] 3.558.1133 181 root 0:0 [INFO]    Operation finished...

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
Run this script for each user that requires a new Docker public and private TLS key.

    create-user-tls.sh <user> <#days> 

## Output
<img id="create-user-tls.sh" src="../images/create-user-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
Run this script for each host that requires a new Docker public and private TLS key.

    create-host-tls.sh <FQDN> <#days>

## Output
<img id="create-host-tls.sh" src="../images/create-host-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
An administration user can run this script to copy user public, private TLS keys, and CA to a remote host.

    copy-user-2-remote-host-tls.sh <user> <remotehost> 
    
## Output
<img id="copy-user-2-remote-host-tls.sh" src="../images/copy-user-2-remote-host-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
A user with administration authority (uadmin) uses this script to copy host TLS CA, public, and private keys from /home/uadmin/.docker/docker-ca directory on this system to /etc/docker/certs.d directory on a remote system.  The administration user may receive password and/or passphrase prompts from a remote systen; running the following may stop the prompts in your cluster.
   ssh-copy-id <admin-user>@x.x.x.x

    copy-host-2-remote-host-tls.sh <remotehost>

## Output
<img id="copy-host-2-remote-host-tls.sh" src="../images/copy-host-2-remote-host-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
A user can check their public, private keys, and CA in $HOME/.docker or a user can check other users certificates by using sudo.
    
    check-user-tls.sh <user>

## Output
<img id="check-user-tls.sh" src="../images/check-user-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
Print start and end dates of a Docker CA, ca.pem, in /home/uthree/.docker.  Other Docker CA file names in other directories can be checked using options.

    check-ca-tls.sh
    
## Output
<img id="check-ca-tls.sh" src="../images/check-ca-tls.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage

    check-host-tls.sh

## Output
<img id="check-host-tls2.sh" src="../images/check-host-tls2.gif" >

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

 ## Usage
Run this script to create Docker private registry certificates on any host in the directory; ~/.docker/.
    
    create-registry-tls.sh <REGISTRY_PORT> <NUMBER_DAYS>

## Output
    $ create-registry-tls.sh 17313 180
    2019-12-29T21:17:35.806802-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-registry-tls.sh[27753] 3.564.1195 172 uadmin 10000:10000 [INFO]    Started...

	Create Self-Signed Certificate Keys

    Generating a 4096 bit RSA private key
    ...............................................................++
    ................................................................................................................................    .....................................................................................................++
    writing new private key to 'domain.key'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [AU]:US
    State or Province Name (full name) [Some-State]:Texas
    Locality Name (eg, city) []:Cedar Park
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:Small Company
    Organizational Unit Name (eg, section) []:IT SRE Team#3
    Common Name (e.g. server FQDN or YOUR name) []:five-rpi3b.cptx86.com
    Email Address []:

	Move 180 day Self-Signed Certificate Keys into  /home/uadmin/.docker/registry-certs-five-rpi3b.cptx86.com-17313 

    domain.crt---2019-12-29T21:19:06-CST--2020-06-26T22:19:05-CDT
    domain.key---2019-12-29T21:19:06-CST--2020-06-26T22:19:05-CDT

    2019-12-29T21:19:06.206093-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/create-registry-tls.sh[27753] 3.564.1195 261 uadmin 10000:10000 [INFO]    Operation finished...

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
A user with administration authority uses this script to copy Docker private registry certificates from ~/.docker/registry-certs-<REGISTRY_HOST>-<REGISTRY_PORT> directory on this system to systems in <SYSTEMS_FILE>.
    
    copy-registry-tls.sh <REGISTRY_HOST> <REGISTRY_PORT>

## Output
    $ copy-registry-tls.sh five-rpi3b.cptx86.com 17313
    2019-12-29T21:30:18.811830-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/copy-registry-tls.sh[30966] 3.556.1129 208 uadmin 10000:10000 [INFO]    Started...

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to one-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to two-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to three-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to four-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to five-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to six-rpi3b.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy ~/.docker/registry-certs-five-rpi3b.cptx86.com-17313/ca.crt
	to two.cptx86.com /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt
    [sudo] password for uadmin: 

	ca.crt already exists, renaming existing keys so new keys can be copied.

	Copy domain.{crt,key} to five-rpi3b.cptx86.com in /usr/local/data//us-tx-cluster-1//docker-registry/five-rpi3b.cptx86.com-17313/certs

	domain.crt already exists, renaming existing keys so new keys can be copied.

	domain.key already exists, renaming existing keys so new keys can be copied.
    2019-12-29T21:31:05.591271-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/copy-registry-tls.sh[30966] 3.556.1129 390 uadmin 10000:10000 [INFO]    Operation finished...

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## Usage
This script has to be run as root to check daemon registry cert (ca.crt), registry cert (domain.crt), and registry private key (domain.key) in /etc/docker/certs.d/<REGISTRY_HOST>:<REGISTRY_PORT>/ and <DATA_DIR>/<CLUSTER>/docker-registry/<REGISTRY_HOST>-<REGISTRY_PORT>/certs/ directories.
    
    sudo check-registry-tls.sh <REGISTRY_HOST> <REGISTRY_PORT>

## Output
    $ sudo check-registry-tls.sh five-rpi3b.cptx86.com 17313
    [sudo] password for uadmin: 
    2019-12-29T22:00:55.773201-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/check-registry-tls.sh[8164] 3.553.1123 189 root 0:0 [INFO]    Started...

	Certificate on five-rpi3b.cptx86.com,
        /etc/docker/certs.d/five-rpi3b.cptx86.com:17313/ca.crt:
	PASS until Jun 27 03:19:05 2020 GMT

	Verify and correct file permissions.

	Certificate on five-rpi3b.cptx86.com,
	/usr/local/data//us-tx-cluster-1//docker-registry/five-rpi3b.cptx86.com-17313/certs/domain.crt:
	PASS until Jun 27 03:19:05 2020 GMT

	Verify and correct file permissions.
    2019-12-29T22:00:55.899717-06:00 (CST) five-rpi3b.cptx86.com docker-TLS/check-registry-tls.sh[8164] 3.553.1123 373 root 0:0 [INFO]    Operation finished...

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

#### ARCHITECTURE TREE

    /usr/local/data/                           <-- <DATA_DIR>
    ├── <CLUSTER>/                             <-- <CLUSTER>
    │   ├── docker/                            <-- Root directory of persistent
    │   │   │                                      Docker state files; (images)
    │   │   └── ######.######/                 <-- Root directory of persistent
    │   │                                          Docker state files; (images)
    │   │                                          when using user namespace
    │   ├── SYSTEMS                            <-- List of hosts in cluster
    │   ├── log/                               <-- Host log directory
    │   ├── logrotate/                         <-- Host logrotate directory
    │   ├── docker-accounts/                   <-- Docker TLS certs
    │   │   ├── <HOST-1>/                      <-- Host in cluster
    │   │   │   ├── <USER-1>/                  <-- User TLS certs directory
    │   │   │   │   ├── docker         FUTURE  <-- User tlscacert
    │   │   │   │       ├── ca.pem     FUTURE  <-- User tlscacert
    │   │   │   │       ├── cert.pem   FUTURE  <-- User tlscert
    │   │   │   │       ├── key.pem    FUTURE  <-- User tlskey
    │   │   │   │       └── trust/             <-- Backup of Docker Content Trust
    │   │   │   │                                  (DCT) keys
    │   │   │   └── <USER-2>/                  <-- User TLS certs directory
    │   │   └── <HOST-2>/                      <-- Host in cluster
    │   └── docker-registry/                   <-- Docker registry directory
    │       ├── <REGISTRY_HOST>-<REGISTRY_PORT>/ < Registry container mount
    │       │   ├── certs/                     <-- Registry cert directory
    │       │   │   ├── domain.crt             <-- Registry cert
    │       │   │   └── domain.key             <-- Registry private key
    │       │   └── docker/                    <-- Registry storage directory
    │       ├── <REGISTRY_HOST>-<REGISTRY_PORT>/ < Registry container mount
    │       └── <REGISTRY_HOST>-<REGISTRY_PORT>/ < Registry container mount
    └── <STANDALONE>/                          <-- <STANDALONE> Architecture tree
                                                   is the same as <CLUSTER> TREE but
                                                   the systems are not in a cluster

    <USER_HOME>/                               <-- Location of user home directory
    ├── <USER-1>/.docker/                      <-- User docker cert directory
    │   ├── ca.pem                             <-- User tlscacert or symbolic link
    │   ├── cert.pem                           <-- Symbolic link to user tlscert
    │   ├── key.pem                            <-- Symbolic link to user tlskey
    │   ├── docker-ca/                         <-- Working directory to create certs
    │   │   ├── .private/                      
    │   │   │   └── ca-priv-key.pem            <-- Current site CA Private Key
    │   │   ├── ca.pem                         <-- Current site CA cert
    │   │   ├── hosts/                         <-- Directory for hostnames
    │   │   │   └── <HOST>/                    <-- Directory to store host certs
    │   │   │      ├── ca.pem                  <-- CA Cert
    │   │   │      ├── <HOST>-cert.pem         <-- public key (default: cert.pem)
    │   │   │      └── <HOST>-priv-key.pem     <-- private key (default: key.pem)
    │   │   ├── site/                          <-- Directory to store site certs
    │   │   │   ├── ca.pem                     <-- CA Cert
    │   │   │   └── ca-priv-key.pem            <-- CA Private Key
    │   │   ├── users/                         <-- Directory for users
    │   │   │   └── <USER>/                    <-- Directory to store user certs
    │   │   │      ├── ca.pem                  <-- CA Cert
    │   │   │      ├── user-cert.pem           <-- public key
    │   │   │      └── user-priv-key.pem       <-- private key
    │   ├── trust/                             <-- Docker Content Trust (DCT)
    │   │   ├── private/                       <-- Notary Canonical Root Key ID
    │   │   │                                      (DCT Root Key)
    │   │   ├── trusted_certificates/          <-- Docker Content Trust (DCT) keys
    │   │   └── tuf/                           <-- Update Framework (TUF)
    │   ├── registry-certs-<REGISTRY_HOST>-<REGISTRY_PORT>/ <-- Working directory
    │   │   │                                      to create registory certs
    │   │   ├── ca.crt                         <-- Daemon registry domain cert
    │   │   ├── domain.crt                     <-- Registry cert
    │   │   └── domain.key                     <-- Registry private key
    │   └── registry-certs-<REGISTRY_HOST>-<REGISTRY_PORT>/ <-- Working directory
    │                                              to create registory certs
    └── <USER-1>/.ssh/                         <-- Secure Socket Shell directory
        ├── authorized_keys                    <-- SSH keys for logging into account
        ├── config                             <-- SSH user configuration file
        ├── id_rsa                             <-- SSH private key
        ├── id_rsa.pub                         <-- SSH public key
        └── known_hosts                        <-- Systems previously connected to

    /etc/ 
    ├── docker/ 
    │   ├── certs.d/                           <-- Host docker cert directory
    │   │   ├── daemon/                        <-- Daemon cert directory
    │   │   │   ├── ca.pem                     <-- CA Cert
    │   │   │   ├── <HOST>-cert.pem            <-- public key (default: cert.pem)
    │   │   │   └── <HOST>-priv-key.pem        <-- private key (default: key.pem)
    │   │   ├── <REGISTRY_HOST>:<REGISTRY_PORT>/ < Registry cert directory
    │   │   │   └── ca.crt                     <-- Daemon registry domain cert
    │   │   ├── <REGISTRY_HOST>:<REGISTRY_PORT>/ < Registry cert directory
    │   │   └── <REGISTRY_HOST>:<REGISTRY_PORT>/ < Registry cert directory
    │   ├── daemon.json                        <-- Daemon configuration file
    │   ├── key.json                           <-- Automatically generated dockerd
    │   │                                          key for TLS connections to other
    │   │                                          TLS servers
    │   ├── 10-override.begin                  <-- docker.service.d default lines
    │   ├── dockerd-configuration-file         <-- Daemon configuration
    │   ├── dockerd-configuration-file.service <- runs start-dockerd-with-systemd.sh
    │   │                                          during boot
    │   ├── docker.org                         <-- Copy of /etc/default/docker
    │   ├── README.md
    │   ├── setup-dockerd.sh                   <-- moves and creates files
    │   ├── start-dockerd-with-systemd.begin   <-- Beginning default lines
    │   ├── start-dockerd-with-systemd.end     <-- Ending default lines
    │   ├── start-dockerd-with-systemd.sh
    │   └── uninstall-dockerd-scripts.sh       <-- Removes files and scripts
    ├── systemd/system/                        <-- Local systemd configurations
    │   ├── dockerd-configuration-file.service <-- Runs start-dockerd-with-systemd.sh
    │   ├── docker.service.d/
    │   │   └── 10-override.conf               <-- Override configutation file
    │   └── docker.service.wants/              <-- Dependencies
    ├── default/
    │   └── docker                             <-- Docker daemon Upstart and
    │                                              SysVinit configuration file
    └── ssl/
        └── openssl.cnf                        <-- OpenSSL configuration file

    /var/
    ├── lib/docker/                            <-- Root directory of persistent
    │                                              Docker state files; (images)
    │                                              changed to symbolic link pointing
    │                                              to <DATA_DIR>/<CLUSTER>/docker
    └── run/
        ├── docker/                            <-- Root directory for Docker
        │                                          execution state files
        ├── docker.pid                         <-- Docker daemon PID file
        └── docker.######.######/              <-- Root directory for Docker
                                                   execution state files using
                                                   user namespace

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

#### Install Scripts
To install the scripts, change to the directory you have write permission (examples: ~/bin, /usr/local/bin) 

    curl -L https://api.github.com/repos/BradleyA/docker-security-infrastructure/tarball | tar -xzf - --wildcards */c* && mv BradleyA-docker-security-infrastructure*/docker-TLS/c* . && rm -rf BradleyA-docker-security-infrastructure*/

#### To watch future updates in this repository select in the upper-right corner, the "Watch" list, and select Watching.

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

----

#### Contribute
Please do contribute!  Issues, comments, and pull requests are welcome.  Thank you for your help improving software.

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

#### Author
[<img id="github" src="../images/github.png" width="50" a="https://github.com/BradleyA/">](https://github.com/BradleyA/)    [<img src="../images/linkedin.png" style="max-width:100%;" >](https://www.linkedin.com/in/bradleyhallen) [<img id="twitter" src="../images/twitter.png" width="50" a="twitter.com/bradleyaustintx/">](https://twitter.com/bradleyaustintx/)       <a href="https://twitter.com/intent/follow?screen_name=bradleyaustintx"> <img src="https://img.shields.io/twitter/follow/bradleyaustintx.svg?label=Follow%20@bradleyaustintx" alt="Follow @bradleyaustintx" />    </a>          [![GitHub followers](https://img.shields.io/github/followers/BradleyA.svg?style=social&label=Follow&maxAge=2592000)](https://github.com/BradleyA?tab=followers)

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

#### Tested OS
 * Ubuntu 14.04.6 LTS (amd64,armv7l)
 * Ubuntu 16.04.7 LTS (amd64,armv7l)
 * Ubuntu 18.04.5 LTS (amd64,armv7l)
 * Raspbian GNU/Linux 10 (buster)

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

#### Design Principles
 * Have a simple setup process and a minimal learning curve
 * Be usable as non-root when able
 * Be easy to install and configure

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)

## License
MIT License

Copyright (c) 2019  [Bradley Allen](https://www.linkedin.com/in/bradleyhallen)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Return to top](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS#docker-tls)
