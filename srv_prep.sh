#vars
Config=
Soft=$(cat $Config |grep "^[^#;]" | grep Soft | grep -oP '=\K.+')
Demons=$(cat $Config |grep "^[^#;]" | grep Demons | grep -oP '=\K.+')
#install soft  
yum install $Soft -y
#start and enable demons
systemctl start $Demons && systemctl enable $Demons
#set up ntpd
if [ "$Demons |grep ntpd" ]; then
Ntp_conf=/etc/ntp.conf
Ntp_iburst_prefer=$(cat $Config |grep "^[^#;]" | grep -w Ntp_iburst_prefer | grep -oP '=\K.+')
Ntp_iburst=$(cat $Config |grep "^[^#;]" | grep -w Ntp_iburst | grep -oP '=\K.+')
#sed -i 's/search_string/replace_string/' filename
#replace string
sed -i "s/server 0.centos.pool.ntp.org iburst/server $Ntp_iburst_prefer iburst prefer/" $Ntp_conf
sed -i "s/server 1.centos.pool.ntp.org iburst/server $Ntp_iburst iburst/" $Ntp_conf
#sed -i '/pattern/d' file
#delete string
sed -i '/centos.pool.ntp.org/d' $Ntp_conf
fi
#disable conflict demon, may not exists
systemctl disable chronyd.service &> /dev/null
#create firewall rule
firewall-cmd --permanent --add-service=ntp
#restart demon
systemctl restart ntpd && systemctl status ntpd
#set timezone
timedatectl set-timezone Europe/Moscow
#disable ipv6 in network-scripts and sysctl
sed -i '/^IPV6/s/^/#/' /etc/sysconfig/network-scripts/ifcfg*
if ! grep "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then 
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf; fi
if ! grep "net.ipv6.conf.default.disable_ipv6" /etc/sysctl.conf; then
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf; fi 
if ! grep "net.ipv6.conf.lo.disable_ipv6" /etc/sysctl.conf; then 
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf; fi
#mailx configuration
SMTP=$(cat $Config |grep "^[^#;]" | grep SMTP | grep -oP '=\K.+')
Domain=$(cat $Config |grep "^[^#;]" | grep Domain | grep -oP '=\K.+')
ln -s /bin/mailx /bin/email
if ! grep "set smtp=$SMTP" /etc/mail.rc; then
echo "set smtp=$SMTP" > /etc/mail.rc; fi
if ! grep "set from=$HOSTNAME@$Domain" /etc/mail.rc; then
echo "set from=$HOSTNAME@$Domain" >> /etc/mail.rc; fi
if ! grep "set ssl-verify=ignore" /etc/mail.rc; then
echo "set ssl-verify=ignore" >> /etc/mail.rc; fi
#set up firewall
firewall-cmd --permanent --add-rich-rule='rule service name=ssh limit value=10/m accept'
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client
firewall-cmd --reload && firewall-cmd --list-all 
#disable selinux. yep, i know, it's bad.
sed -i "s/SELINUX=enforcing/selinux=disabled/" /etc/selinux/config
