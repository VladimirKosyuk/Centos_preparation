# Centos_preparation

Pre steps:

1. TCP/IP parameters have been set

2. Access to the inetrnet

3. Your server in Moscow (or you can change 29th string)

4. Your OS is Centos 6/7

5. Mailx is installed

What it does:

1. Installs soft from config file via yum (path need to be set, 2nd string)

2. Starts and enables demons form config file

3. If ntpd has been set, configurates it with settings from config file

4. Disables Ipv6

5. Configurates mailx 

6. Configurates firewalld

7. Disables selinux
