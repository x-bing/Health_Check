#/bin/bash
# Usage
# setup_healcheck_user.sh username userid groupid
#

username=$1
userid=$2
groupid=$3
userhome="/home"

groupadd -g $groupid $username
useradd -p `openssl passwd -stdin < <(echo)` -g $groupid -u $userid $username -d $userhome/$username

if [ -d /etc/sudoers.d ]; then
	sudofile="/etc/sudoers.d/healcheck_user"
else
	sudofile="/etc/sudoers"
fi

cmd_alias=$(echo MONITOR$username | tr '[a-z]' '[A-Z]')

sed -i "s/Cmnd_Alias $cmd_alias.*//g" $sudofile
sed -i "s/^$username.*//g" $sudofile

cat  << EOF >> $sudofile
Cmnd_Alias $cmd_alias = /bin/dmesg, /usr/sbin/dmidecode,/bin/hostname,/usr/bin/uptime,/sbin/ifconfig, /bin/grep, /bin/cat
$username		ALL=(ALL)	NOPASSWD: $cmd_alias
EOF

mkdir -p $userhome/$username/.ssh/
cat ./id_rsa.pub.hc >> $userhome/$username/.ssh/authorized_keys
chmod 700 $userhome/$username/.ssh
chmod 600 $userhome/$username/.ssh/authorized_keys
chown -R $1:$1 $userhome/$username/.ssh
