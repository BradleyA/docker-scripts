# ssh

## Description

This script allows users to make sure that the ssh files and directory permissions are correct.  If they are not correct then this script will correct the permissions.  Administrators can check other users ssh keys by using: sudo /usr/local/bin/check-user-ssh.sh <SSH-USER>.  Currently not supporting id_dsa.pub.  Example of file permissions for uadmin user in ~/.ssh directory:

    drwx------  2 uadmin uadmin 4096 Mar  5 13:55 .
    drwxr-xr-x 15 uadmin uadmin 4096 Mar 10 19:22 ..
    -rw-------  1 uadmin uadmin 3563 Feb 22 12:27 authorized_keys
    -rw-------  1 uadmin uadmin  450 Aug  9 11:15 config
    -rw-------  1 uadmin uadmin 1675 Oct  7 20:37 id_rsa
    -rw-r--r--  1 uadmin uadmin  398 Oct  7 20:37 id_rsa.pub
    -rw-------  1 uadmin uadmin 3420 Jul 27 19:16 known_hosts

## Install

To install, change to the location you want to download the scripts. Use git to pull or clone these scripts into the directory. If you do not have git then enter; "sudo apt-get install git". On the github page of this script use the "HTTPS clone URL" with the 'git clone' command.

    git clone https://github.com/BradleyA/docker-security-infrastructure
    cd docker-security-infrastructure/ssh
    
    sudo mkdir -p /usr/local/bin
    sudo chown $USER:$(id -g) /usr/local/bin
    chmod 0775 /usr/local/bin
    mv c* /usr/local/bin
    cd ../..
    rm -rf docker-security-infrastructure

## Usage

Check user, uadmin, RSA ssh file permissions

    ./check-user-ssh.sh
    
## Output

    2019-04-15T12:17:11.494760-05:00 (CDT) six-rpi3b.cptx86.com ./check-user-ssh.sh[17204] 3.241.693 110 uadmin 10000:10000 [INFO]  Started...

        Verify and correct file and directory permissions for /home//uadmin/.ssh

        List of authorized hosts in /home//uadmin/.ssh/authorized_keys:

    uadmin@five-rpi3b
    uadmin@four-rpi3b
    uadmin@one-rpi3b
    uadmin@six-rpi3b
    uadmin@three-rpi3b
    uadmin@two
    uadmin@two-rpi3b
    uthree@three
    utwo@two

        To remove a host from /home//uadmin/.ssh/authorized_keys file:

        REMOVE_HOST='<user_name>@<host_name>'
        grep -v $REMOVE_HOST /home//uadmin/.ssh/authorized_keys > /home//uadmin/.ssh/authorized_keys.new
        mv /home//uadmin/.ssh/authorized_keys.new /home//uadmin/.ssh/authorized_keys

        Check if all files in /home//uadmin/.ssh directory are owned
        by uadmin.  If files are not owned by uadmin then list them below:


        Check if uadmin private key and public key are a
        matched set (identical) or not a matched set (differ):

    Files /dev/fd/63 and /dev/fd/62 are identical
    2019-04-15T12:17:11.573398-05:00 (CDT) six-rpi3b.cptx86.com ./check-user-ssh.sh[17204] 3.241.693 243 uadmin 10000:10000 [INFO]  Operation finished.

## ssh Hints

To create a new ssh key;

    ssh-keygen -t rsa

To check if a private key and public key are a matched set (identical) or not a matched set (differ):
    
    diff -qs <(ssh-keygen -yf ~/.ssh/id_rsa) <(cut -d ' ' -f 1,2 ~/.ssh/id_rsa.pub)

To debug SSH login use the -vvv for verbose mode to help resolve this incident.

    ssh -vvv <user_name>@<host>
    
To remove a host from ~/.ssh/authorized_keys file:

    REMOVE_HOST='<user_name>@<host_name>'
    grep -v $REMOVE_HOST /home/uadmin/.ssh/authorized_keys > /home/uadmin/.ssh/authorized_keys.new
    mv /home/uadmin/.ssh/authorized_keys.new /home/uadmin/.ssh/authorized_keys

#### ARCHITECTURE TREE
    <USER_HOME>/                               <-- Location of user home directory
    └── <USER-1>/.ssh/                         <-- Secure Socket Shell directory
        ├── authorized_keys                    <-- SSH keys for logging into account
        ├── config                             <-- SSH client configuration file
        ├── id_rsa                             <-- SSH private key
        ├── id_rsa.pub                         <-- SSH public key
        └── known_hosts                        <-- Systems previously connected to

#### System OS script tested

 * Ubuntu 14.04.3 LTS
 * Ubuntu 16.04.3 LTS (armv7l)

#### Design Principles

 * Have a simple setup process and a minimal learning curve
 * Be usable as non-root
 * Be easy to install and configure

## License

MIT License

Copyright (c) 2019  [Bradley Allen](https://www.linkedin.com/in/bradleyhallen)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
