# dockerd-configuration-options

Goal is to use one dockerd configuration file with dockerd flags for both Ubuntu 16.04 (systemd) and Ubuntu 14.04 (Upstart) other than /etc/docker/daemon.json.  

#### Note:  I chose not to use [/etc/docker/daemon.json](https://docs.docker.com/engine/reference/commandline/dockerd/) for docker daemon configuration because json does not support [comments](https://plus.google.com/+DouglasCrockfordEsq/posts/RK8qyGVaGSr).

Running sudo ./setup-dockerd.sh will move files into /etc/docker and create or update the /etc/systemd/system/docker.service.d/10-override.conf file (Ubuntu 16.04, systemd) and the /etc/default/docker (Ubuntu 14.04, Upstart).  To change the docker daemon flags, sudo edit /etc/docker/dockerd-configuration-file and run sudo /etc/docker/setup-dockerd.sh.  Docker daemon flag changes can be distributed to any Ubuntu cluster that use systemd or upstart by copying /etc/docker/dockerd-configuration-file to each system that is setup like this and running sudo /etc/docker/setup-dockerd.sh on each system.

This has not been tested for other Linux OS's but should work.  Let me know if you use it on other Linus OS's.

## Install
To Install, change into a directory that you want to download the scripts. Use git to pull or clone these scripts into the directory. If you do not have Git installed then enter; "sudo apt-get install git" if using Debian/Ubuntu. Other Linux distribution install methods can be found here: https://git-scm.com/download/linux. On the GitHub page of this script use the "HTTPS clone URL" with the 'git clone' command.

    mkdir temp
    cd temp
    git clone https://github.com/BradleyA/docker-security-infrastructure
    cd docker-security-infrastructure/dockerd-configuration-options
    sudo ./setup-dockerd.sh
    cd ../../..
    rm -rf ./temp
    
#### Note: The default in this dockerd configuration (/etc/docker/dockerd-configuration-file) requires docker TLS.  Here are the scripts to help you setup [docker-TLS](https://github.com/BradleyA/docker-security-infrastructure/tree/master/docker-TLS).

Edit dockerd-configuration-file, change the [dockerd flags](https://docs.docker.com/engine/reference/commandline/dockerd/) to the flags your dockerd environment requires.  This file, dockerd-configuration-file, is an example.  It is what I am currently using.  You will want to remove --data-root=/usr/local/docker flag if you are using the default location (/var/lib/docker) or change it to your Docker root directory.  You will want to change the address of the local DNS server (--dns 192.168.1.202) to your DNS server address.  If you do not have [TLS CA certificates](https://docs.docker.com/engine/security/https/) setup or in a different location or using different names then you will want to remove or change those --tls flags.  If you have not used --userns-remap=default before you WILL want to remove this flag until you read more about this security feature.

    edit dockerd-configuration-file

After editing the /etc/docker/dockerd-configuration-file with your dockerd flags, run sudo /etc/docker/setup-dockerd.sh.  It will move all the required files including setup-dockerd.sh into the /etc/docker and /etc/systemd/system/ directories.  The each time you want to make a change to your dockerd flags use sudo edit /etc/docker/dockerd-configuration-file and then sudo /etc/docker/setup-dockerd.sh.  

If you are using systemd, run the following to enable two docker services on each boot and restart dockerd.
    
    sudo systemctl enable dockerd-configuration-file.service
    sudo systemctl enable docker
    sudo systemctl restart docker

To verfy that systemd started dockerd with no incidents, enter the following:

    systemctl status docker.service
    
    journalctl -xe

If you are using upstart, run the following for dockerd to read /etc/default/docker.
    
    sudo service docker restart

To verfy that upstart started dockerd with no incidents, enter the following:

    sudo cat /var/log/upstart/docker.log

#### Download files:
    
**644	10-override.begin** - beginning default lines for /etc/systemd/system/docker.service.d/10-override.conf file used by systemd docker.service.  Additional lines for /etc/systemd/system/docker.service.d/10-override.conf file will be created by running /etc/docker/start-dockerd-with-systemd.sh.

**644	dockerd-configuration-file** - dockerd option file for setting DOCKER_OPTS= environment variable to be added to Ubuntu 14.04 (upstart) in /etc/default/docker file and Ubuntu 16.04 (systemd) in /etc/systemd/system/docker.service.d/10-override.conf

**644	dockerd-configuration-file.service** - service that run /etc/docker/start-dockerd-with-systemd.sh during boot

**744	setup-dockerd.sh** - script moves files into /etc/docker, updates /etc/default/docker file (Ubuntu 14.04, Upstart) with /etc/docker/dockerd-configuration-file, creates start-dockerd-with-systemd.sh script with /etc/docker/dockerd-configuration-file, moves dockerd-configuration-file.service to /etc/systemd/system/ directory, runs systemctl daemon-reload so docker.service will use dockerd-configuration-file and dockerd-configuration-file.service will link to docker.service

**644	start-dockerd-with-systemd.begin** - begining of /etc/docker/start-dockerd-with-systemd.sh script

**644	start-dockerd-with-systemd.end** - end of /etc/docker/start-dockerd-with-systemd.sh script which creates 10-override.conf file and moves it into /etc/systemd/system/docker.service.d directory and runs /bin/systemctl daemon-reload so docker.service will use latest copy of dockerd-configuration-file.service file.

**700 uninstall-dockerd-scripts.sh** - script removes from your system the above files from /etc/docker directory and /etc/systemd/system/dockerd-configuration-file.service file; removes files and directories from /etc/systemd/system/docker.service.d and /etc/systemd/system/docker.service.wants; and displays what commands to run to remove this script and information from memory by dockerd.  Thus resetting your system back to its previous state.

#### ARCHITECTURE TREE

    /etc/
    ├── docker/
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
    └── default/
        └── docker                             <-- Docker daemon Upstart and
                                                   SysVinit configuration file


#### To watch future updates in this repository select in the upper-right corner, the "Watch" list, and select Watching.

#### Author
[<img id="twitter" src="../images/twitter.png" width="50" a="twitter.com/bradleyaustintx/">
](https://twitter.com/bradleyaustintx/)   [<img id="github" src="../images/github.png" width="50" a="https://github.com/BradleyA/">
](https://github.com/BradleyA/)    [<img src="../images/linkedin.png" style="max-width:100%;" >](https://www.linkedin.com/in/bradleyhallen)

#### System OS script tested
 * Ubuntu 14.04.4 LTS
 * Ubuntu 16.04.3 LTS (armv7l)

#### Design Principles
 * Have a simple setup process and a minimal learning curve
 * Be usable as non-root - [failed- must use sudo ]
 * Be easy to install and configure

## License
MIT License

Copyright (c) 2019  [Bradley Allen](https://www.linkedin.com/in/bradleyhallen)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
