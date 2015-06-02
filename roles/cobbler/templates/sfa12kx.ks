# {{ ansible_managed }}

#version=DEVEL
install
text
reboot
url --url={{ ddn_iso_path_web }}
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto dhcp
network --onboot no --device eth1 --bootproto dhcp --noipv6
network --onboot no --device eth2 --bootproto dhcp --noipv6
network --onboot no --device eth3 --bootproto dhcp --noipv6
network --onboot no --device ib0 --bootproto dhcp --noipv6
network --onboot no --device ib1 --bootproto dhcp --noipv6
network --onboot no --device ib2 --bootproto dhcp --noipv6
rootpw DDNSolutions4U

# System services
services --disabled="iptables,ip6tables,kudzu,sendmail,bluetooth,nfslock,nfs,avahi-daemon,cups" --enabled="multipathd,ntpd,network"

# Reboot after installation
reboot --eject
firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/New_York
bootloader --location=mbr --driveorder=sda --append="crashkernel=256M rhgb quiet"
zerombr
clearpart --all --drives=sda --initlabel
ignoredisk --only-use=sda

part /boot --fstype=ext4 --asprimary --size=512
part pv.008002 --grow --size=1

volgroup VolGroup00 --pesize=32768 pv.008002
logvol / --fstype=ext4 --name=LogVol01 --vgname=VolGroup00 --grow --size=2048 --maxsize=16384
logvol /var --fstype=ext4 --name=LogVol03 --vgname=VolGroup00 --grow --size=1024 --maxsize=8192
logvol swap --name=LogVol04 --vgname=VolGroup00 --grow --size=2048 --maxsize=16384
logvol /scratch --fstype=ext4 --name=LogVol05 --vgname=VolGroup00 --grow --size=4096 --maxsize=131072

repo --name="EXAScaler"  --baseurl={{ ddn_iso_path_web }} --cost=100

%packages --nobase
@Core
@Core
GeoIP
MySQL-python
OpenIPMI
acl
acpid
attr
augeas-libs
authconfig
authd
autoconf
autofs
automake
bind-utils
blktrace
boost-filesystem
boost-iostreams
boost-regex
boost-system
boost-thread
bzip2
cluster-glue
cluster-glue-libs
clusterlib
collectl
corosync
corosynclib
crash
createrepo
crmsh
crontabs
ddn-api
ddn-ibsrp
ddn-mmp-check
ddn-udev
ddn_mpath_RHEL6
device-mapper-multipath
dhclient
dmidecode
dos2unix
dstat
eject
eventlog
exascaler-tools
expect
fence-agents
fping
ftp
gcc
gcc-c++
graphviz
hwloc
ibutils
infiniband-diags
iperf
ipmitool
iptraf
irqbalance
kernel
kernel-devel
kernel-headers
kernel-ib
kernel-ib-devel
kexec-tools
libaio
libatasmart
libedit
libhbaapi
libibmad
libibumad
libibverbs
libibverbs-utils
libmlx4
libnet
libqb
libselinux
libselinux-python
libsysfs
libtool
libutempter
logrotate
lsof
lsscsi
lustre
lustre-iokit
lustre-source
lustre-tests
man
man-pages
microcode_ctl
mlocate
mstflint
mtools
mtr
mysql
mysql-devel
mysql-libs
mysql-server
net-snmp-perl
netcf-libs
nfs4-acl-tools
nscd
nss-pam-ldapd
nss-tools
nss_db
ntop
ntp
ntsysv
ofed-scripts
openldap-clients
opensm
opensm-libs
openssh-clients
openssh-server
openssl-devel
pacemaker
pacemaker-cli
pacemaker-cluster-libs
pacemaker-libs
pam_krb5
pam_ldap
pam_passwdqc
parted
pciutils
pdsh
pdsh-mod-dshgroup
pdsh-mod-machines
pdsh-rcmd-exec
pdsh-rcmd-ssh
perftest
perl-Config-IniFiles
perl-DBD-MySQL
perl-DBI
perl-Expect
perl-IO-Socket-SSL
perl-IO-Tty
perl-IO-stringy
perl-List-MoreUtils
perl-TermReadKey
perl-XML-LibXML
perl-XML-Simple
php
php-gd
php-mysql
php-pdo
php-xml
pm-utils
postgresql
postgresql-libs
postgresql-server
psacct
pssh
python-cherrypy
python-dateutil
python-devel
python-dmidecode
python-lxml
python-psycopg2
python-setuptools
python-simplejson
quota
rdma
readahead
redhat-lsb
redhat-rpm-config
resource-agents
rng-tools
rpm-build
rrdtool
rsync
screen
setuptool
smartmontools
sos
spew
srptools
strace
sudo
symlinks
syslog-ng
sysstat
tcp_wrappers
tcpdump
telnet
time
tk
traceroute
unzip
usbutils
uuid
uuid-perl
vconfig
vim-enhanced
wget
which
xdd
xinetd
ypbind
yum
yum-utils
zip
zlib-devel
-ipw2200-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-selinux-policy
-selinux-policy-targeted

%end

%pre --erroronfail
#! /bin/bash

# The network configuration is always automatically generated, in the HPC
# case it is fairly simple however we still write it to a file in %pre and
# include in via %include in ks.cfg to allow the two kickstart files to be built
# and parsed in the same way the same way.
echo "network --device eth0 --bootproto dhcp --onboot=yes" > /tmp/auto-include
#! /bin/bash
# Note - this script is appended to prescript.template.$flavour and is
# not run directly in bash, the line above is as a hint to editors so
# that syntax highlighting works correctly.

# http://hintshop.ludvig.co.nz/show/interactive-pre-post-install-scripts-redhat-kickstart/
# http://lists.centos.org/pipermail/centos/2007-March/034847.html
# http://www.centos.org/docs/4/html/rhel-sag-en-4/s1-kickstart2-preinstallconfig.html

INSTALL_DEV=sda

if [ -e /dev/sdb ]
then
    PROBLEM=1
fi

# DE10881  Support installation onto systems using "fake-raid".
#
# http://en.wikipedia.org/wiki/Intel_Matrix_RAID
#
# In this case the kernel sees two devices at boot, sda and sdb.  Both devices
# contain BIOS-provided raid hints that MDADM parses into initial setting to
# use for software raid.  Detect this case, setup a mdadm.conf file (to use used
# during install only) and enable the new raid device telling Anaconda to
# install to it.
#
# "imsm" raid as Linux calls it contains two parts, a "container" which contains
# only metadata and is understood by the BIOS and the raid device itself which
# is used to boot.  The BIOS knows enough be able to read from the data device
# to boot, then control is handed to the OS.  This means that Linux sees two
# storage devices, one which is the container and has the raw block devices as
# parents and which containts the actual data and has the container as a parent.
#
# As a added complexity before this %pre script has run Anaconda detects that
# the devices have raid-configuration embedded in them so tries to assign them
# to a md device, as none exist Anaconda internally "fakes" a md0 in it's
# internal data structures.  If the new raid device is created with a device
# name other than md0 here then Anaconda will abort due to device conflicts.
# Whilst mdadm can automatically configure a config file to enable the raid
# devices (and can enable them without a config file) we need to create a config
# file and automatially edit it to ensure the correct device names are used.
#
# The end result is that /dev/md0 is the "container" device and /dev/md127 is
# the data device.
if [ -e /dev/sda -a -e /dev/sdb -a ! -e /dev/sdc ]
then
    PROBLEM=0
    INSTALL_DEV=md127
    mdadm --examine --brief /dev/sda > /tmp/mdadm.sda
    if [ $? -ne 0 ] ; then PROBLEM=1 ; fi
    mdadm --examine --brief /dev/sdb > /tmp/mdadm.sdb
    if [ $? -ne 0 ] ; then PROBLEM=1 ; fi
    LINE_COUNT=`cat /tmp/mdadm.sda | wc -l`
    if [ ${LINE_COUNT} -ne 2 ] ; then PROBLEM=1 ; fi
    LINE_COUNT=`cat /tmp/mdadm.sdb | wc -l`
    if [ ${LINE_COUNT} -ne 2 ] ; then PROBLEM=1 ; fi

    if [ ${PROBLEM} -eq 0 ]
    then
        cat /tmp/mdadm.sda | sed "s.ARRAY metadata.ARRAY /dev/md0 metadata." > /etc/mdadm.conf
        mdadm --assemble --scan

        if [ ! -e /dev/md0 -o ! -e /dev/md127 ]
        then
            PROBLEM=2
        fi
    fi
fi

# If there is a problem check for the over-ride on the command line.
# This code is slightly odd because it needs to fall through to the
# end of the script where /tmp/auto-include is written rather than
# simply calling exit 0 on success.
if [ ${PROBLEM} -eq 1 ]
then
    grep skip-sda-check /proc/cmdline
    if [ $? -eq 0 ]
    then
        PROBLEM=0
    fi
fi

if [ ${PROBLEM} -eq 1 ]
then

    # No more cases are white-listed, lets abort the install.  We could potentially
    # offer the user a choice to continue here but we'd have to chvt back to ? and
    # do extensive testing the FDs were reset properly, as we're dealing with a error
    # case anyway and have the command line workaround aborting is the preferred
    # option here.

    exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
    chvt 6

    echo
    echo Warning, more than one storage device detected, in order to reduce the risk
    echo of data loss install will not continue.
    echo
    echo Be sure to remove all FC cables and USB/ipmi devices from node before install.
    echo
    echo Use "skip-sda-check" on grub command line to override this check
    echo
    echo Hit enter to reboot

    read

    exit 1
fi

if [ ${PROBLEM} -eq 2 ]
then

    exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
    chvt 6

    echo
    echo Warning, imsm raid system detected however unable to active devices.
    echo
    echo Install cannot proceed, contact DDN support for assistance.
    echo
    echo Hit enter to reboot

    read

    exit 1
fi

echo ignoredisk --only-use=${INSTALL_DEV} >> /tmp/auto-include
echo clearpart --all --initlabel --drives=${INSTALL_DEV} >> /tmp/auto-include
echo part /boot --fstype ext4 --asprimary --ondisk=${INSTALL_DEV} --size=512 >> /tmp/auto-include
echo part pv.2 --size=1 --ondisk=${INSTALL_DEV} --grow >> /tmp/auto-include
echo volgroup VolGroup00 --pesize=32768 pv.2 >> /tmp/auto-include
echo logvol / --fstype ext4 --name=LogVol01 --vgname=VolGroup00 --size=2048 --grow --maxsize=16384 >> /tmp/auto-include
echo logvol /var --fstype ext4 --name=LogVol03 --vgname=VolGroup00 --size=1024 --grow --maxsize=8192 >> /tmp/auto-include
echo logvol /scratch --fstype ext4 --name=LogVol05 --vgname=VolGroup00 --size=4096 --grow --maxsize=131072 >> /tmp/auto-include
echo logvol swap --fstype swap --name=LogVol04 --vgname=VolGroup00 --size=2048 --grow --maxsize=16384 >> /tmp/auto-include

exit 0
%end

%post --nochroot
# Copy source RPMs
mkdir /mnt/sysimage/root/EXAScaler-2.1.1
cp -R /mnt/source/files/* /mnt/sysimage/root/EXAScaler-2.1.1
if [ -f /mnt/sysimage/root/EXAScaler-2.1.1/TRANS.TBL ]
then
    rm -f /mnt/sysimage/root/EXAScaler-2.1.1/TRANS.TBL
fi

%end

%post
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.disabled

echo EXAScaler CentOS 2.1.1-7 > /etc/es_install_version

# Call the configuration script to apply OS settings from EXAScaler.
/opt/ddn/config/config-os

# Configure serial port for SFA by default
flavour=`/opt/ddn/bin/es_config_get --flavour`
if [ $flavour = 'SFA' ] ; then
    /opt/ddn/config/config-serial.py --use-sfa-defaults
fi
%end
