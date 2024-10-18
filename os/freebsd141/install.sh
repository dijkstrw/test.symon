#
# Install script for FreeBSD14.1
#
ENV_NAME=freebsd141
ISO_SOURCE=https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-amd64-mini-memstick.img

DISK=${ROOT}/disks/${ENV_NAME}.qcow2
ISO_FILE=${ROOT}/iso/${ENV_NAME}.img
SSHID_FILE=${ROOT}/ssh/id

if [ ! -d ${ROOT} ]; then
    echo "Please set ROOT to root directory"
    exit -1
fi

if [ ! -f ${ISO_FILE} ]; then
    echo "Download the image and adjust according to README.md"
    echo ${ISO_SOURCE}
    exit 1
fi

if [ ! -f ${DISK} ]; then
    qemu-img  create -f qcow2 ${DISK} 4G
fi

if [ ! -f ${SSHID_FILE} ]; then
    ssh-keygen -f ${SSHID_FILE} -P ""
fi

SSHID_PUB=`cat ${SSHID_FILE}.pub`

SEXPECT_SOCKFILE=/tmp/sexpect-$$.sock
SEXPECT_LOGFILE=/tmp/sexpect-$$.log

qexpect() { sexpect -s ${SEXPECT_SOCKFILE} "$@"; }

qexpect spawn -logfile ${SEXPECT_LOGFILE} qemu-system-x86_64 --nographic -cpu host -machine pc-q35-2.8,accel=kvm -m 2048 -hdb ${DISK} -hda ${ISO_FILE}
qexpect expect "Autoboot in"
qexpect send -enter
qexpect expect "Console type"
qexpect send -enter
qexpect expect "Install"
qexpect send -enter
qexpect expect "Keymap Selection"
qexpect send -enter
qexpect expect "Set Hostname"
qexpect send -enter ${ENV_NAME}
qexpect expect "Distribution Select"
qexpect send -enter
qexpect expect "Network Installation"
qexpect send -enter
qexpect expect "Network Configuration"
qexpect send -enter
qexpect expect "IPv4"
qexpect send -enter
qexpect expect "DHCP"
qexpect send -enter
qexpect expect "IPv6"
qexpect send "n"
qexpect expect "Network Configuration"
qexpect send -enter
qexpect expect "Partitioning"
qexpect send -enter
qexpect expect "ZFS Configuration"
qexpect send -enter
qexpect expect "ZFS Configuration"
qexpect send -enter
qexpect expect "ZFS Configuration"
qexpect send -enter " "
qexpect expect "ZFS Configuration"
qexpect send "y"
qexpect expect "Mirror Selection"
qexpect send -enter
qexpect expect "New Password:"
qexpect send -enter "root"
qexpect expect "Retype New Password:"
qexpect send -enter "root"
qexpect expect "Time Zone Selector"
qexpect send -enter
qexpect expect "Confirmation"
qexpect send -enter
qexpect expect "Time & Date"
qexpect send -enter
qexpect expect "Time & Date"
qexpect send -enter
qexpect expect "System Configuration"
qexpect send -enter
qexpect expect "System Hardening"
qexpect send -enter
qexpect expect "Add User Accounts"
qexpect send "n"
qexpect expect "Final Configuration"
qexpect send -enter
qexpect expect "Manual Configuration"
qexpect send "y"
qexpect expect "#"
qexpect send -enter "cd /root; mkdir .ssh; chmod go-rwx .ssh; echo -e '${SSHID_PUB}\n' >> .ssh/authorized_keys"
qexpect expect "#"
qexpect send -enter "pkg add rrdtool"
qexpect expect "The package management tool is not yet installed on your system."
qexpect send -enter "y"
qexpect expect "#"
qexpect send -enter "pkg update"
qexpect expect "#"
qexpect send -enter "pkg install rrdtool-1.9.0"
qexpect expect "y/N"
qexpect send -enter "y"
qexpect expect "#"
qexpect send -enter 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'
qexpect expect "#"
qexpect send -enter "poweroff"
qexpect kill
qexpect wait
