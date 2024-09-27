#
# Install script for OpenBSD 7.5
#

# Objective: make a repeatable environment in qemu where we can test
# cross platform compilation and execution of symon.
ENV_NAME=openbsd75
ISO_SOURCE=https://cdn.openbsd.org/pub/OpenBSD/7.5/amd64/install75.iso

DISK=${ROOT}/disks/${ENV_NAME}.qcow2
ISO_FILE=${ROOT}iso/${ENV_NAME}.iso
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

qexpect expect "boot>"
qexpect send -enter "set tty com0"
qexpect expect "boot>"
qexpect send -enter "boot -s"
qexpect expect "(I)nstall,"
qexpect send -enter "I"

qexpect expect "Terminal type?"
qexpect send "
${ENV_NAME}




root
root

no

115200

yes



whole
a
http
none


done
done
reboot
"
qexpect expect "login:"
qexpect send -enter "root"
qexpect expect "Password:"
qexpect send -enter "root"
SSHPUB=`cat ${SSHID_FILE}.pub`
qexpect send "
echo -e "${SSHPUB}\n" >> .ssh/authorized_keys
pkg_add rrdtool
shutdown -hp now
"

qexpect kill
qexpect wait
