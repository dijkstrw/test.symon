#
# Install script for NetBSD 10.0
#
ENV_NAME=netbsd100
ISO_SOURCE=https://cdn.netbsd.org/pub/NetBSD/NetBSD-10.0/images/NetBSD-10.0-amd64.iso

DISK=${ROOT}/disks/${ENV_NAME}.qcow2
ISO_FILE=${ROOT}/iso/${ENV_NAME}.iso
SSHID_FILE=${ROOT}/ssh/id

if [ ! -d ${ROOT} ]; then
    echo "Please set ROOT to root directory"
    exit -1
fi

if [ ! -f ${ISO_FILE} ]; then
    curl "${ISO_SOURCE}" -o ${ISO_FILE}
fi

if [ ! -f ${DISK} ]; then
    qemu-img  create -f qcow2 ${DISK} 4G
fi

if [ ! -f ${SSHID_FILE} ]; then
    ssh-keygen -f ${SSHID_FILE} -P ""
fi

SEXPECT_SOCKFILE=/tmp/sexpect-$$.sock
SEXPECT_LOGFILE=/tmp/sexpect-$$.log

qexpect() { sexpect -s ${SEXPECT_SOCKFILE} "$@"; }

qexpect spawn -logfile ${SEXPECT_LOGFILE} qemu-system-x86_64 -nographic -cpu host -machine pc-q35-2.8,accel=kvm -m 2048 -hda ${DISK} -cdrom ${ISO_FILE}

qexpect expect "Choose an option"
qexpect send "3"
qexpect expect ">"
qexpect send -enter "consdev com0"
qexpect expect ">"
qexpect send -enter "boot"
qexpect expect "Terminal type"
qexpect send -enter
qexpect expect "a: Installation messages in English"
qexpect send -enter "a"
qexpect expect "a: Install NetBSD to hard disk"
qexpect send -enter "a"
qexpect expect "b: Yes"
qexpect send -enter "b"
qexpect expect "a: wd0 (4.0G, QEMU HARDDISK)"
qexpect send -enter "a"
qexpect expect "a: Guid Partition Table (GPT)"
qexpect send -enter "a"
qexpect expect "a: This is the correct geometry"
qexpect send -enter "a"
qexpect expect "b: Use default partition sizes"
qexpect send -enter "b"
qexpect expect "x: Partition sizes ok"
qexpect send -enter "x"
qexpect expect "b: Yes"
qexpect send -enter "b"
qexpect expect "b: Use serial port com0"
qexpect send -enter "b"
qexpect expect "x: Continue"
qexpect send -enter "x"
qexpect expect "a: Full installation"
qexpect send -enter "a"
qexpect expect "a: CD-ROM / DVD / install image media"
qexpect send -enter "a"
qexpect expect "Hit enter to continue"
qexpect send -enter ""
qexpect expect "New password:"
qexpect send -enter "root"
qexpect expect "New password:"
qexpect send -enter "root"
qexpect expect "Retype new password:"
qexpect send -enter "root"
qexpect expect "a: Configure network"
qexpect send -enter "a"
qexpect expect "a: wm0"
qexpect send -enter "a"
qexpect expect "Network media type"
qexpect send -enter ""
qexpect expect "a: Yes"
qexpect send -enter "a"
qexpect expect "Your host name:"
qexpect send -enter ${ENV_NAME}
qexpect expect "Your DNS domain:"
qexpect send -enter ""
qexpect expect "a: Yes"
qexpect send -enter "a"
qexpect expect "a: Yes"
qexpect send -enter "a"
qexpect expect "g: Enable sshd"
qexpect send -enter "g"
qexpect expect "x: Finished configuring"
qexpect send -enter "x"
qexpect expect "Hit enter to continue"
qexpect send -enter ""
qexpect expect "d: Reboot the computer"
qexpect send -enter "d"
qexpect expect "login:"
qexpect send -enter "root"
qexpect expect "Password:"
qexpect send -enter "root"
SSHPUB=`cat ${SSHID_FILE}.pub`
qexpect send "
echo -e "${SSHPUB}\n" >> .ssh/authorized_keys
export PKG_PATH=http://cdn.NetBSD.org/pub/pkgsrc/packages/NetBSD/x86_64/10.0
pkg_add rrdtool
shutdown -hp now
"
qexpect kill
qexpect wait
