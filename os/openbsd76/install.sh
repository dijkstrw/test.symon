#
# Install script for OpenBSD 7.6
#

# Objective: make a repeatable environment in qemu where we can test
# cross platform compilation and execution of symon.
ENV_NAME=openbsd76
ISO_SOURCE=https://cdn.openbsd.org/pub/OpenBSD/7.6/amd64/install76.iso

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

SSHID_PUB=`cat ${SSHID_FILE}.pub`

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
qexpect send -enter
qexpect expect "System hostname?"
qexpect send -enter "${ENV_NAME}"
qexpect expect "Network interface to configure?"
qexpect send "


done
"
qexpect expect "Password for root account?"
qexpect send "root
root
"
qexpect expect "Start sshd"
qexpect send -enter "yes"
qexpect expect "Do you expect to run the X Window System?"
qexpect send -enter "no"
qexpect expect "Change the default console to com0?"
qexpect send -enter "yes"
qexpect expect "Which speed should com0 use?"
qexpect send -enter "115200"
qexpect expect "Setup a user?"
qexpect send -enter "no"
qexpect expect "Allow root ssh login?"
qexpect send -enter "yes"
qexpect expect "What timezone are you in?"
qexpect send -enter "Europe/Amsterdam"
qexpect expect "Which disk is the root disk?"
qexpect send -enter "sd0"
qexpect expect "Encrypt the root disk with a (p)assphrase or (k)eydisk?"
qexpect send -enter "no"
qexpect expect "Use (W)hole disk MBR, whole disk (G)PT or (E)dit?"
qexpect send -enter "whole"
qexpect expect "Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout?"
qexpect send -enter "a"
qexpect expect "Location of sets?"
qexpect send -enter "cd0"
qexpect expect "Pathname to the sets?"
qexpect send -enter ""
qexpect expect "Set name(s)?"
qexpect send -enter "all"
qexpect expect "Set name(s)?"
qexpect send -enter "done"
qexpect expect "Directory does not contain SHA256.sig. Continue without verification?"
qexpect send -enter "yes"
qexpect expect "Location of sets?"
qexpect send -enter "done"
qexpect expect "Exit to (S)hell, (H)alt or (R)eboot?"
qexpect send -enter "reboot"
qexpect expect "boot>"
qexpect send -enter "set tty com0"
qexpect expect "boot>"
qexpect send -enter "boot"
qexpect expect "login:"
qexpect send -enter "root"
qexpect expect "Password:"
qexpect send -enter "root"
qexpect expect "openbsd76#"
qexpect send -enter "mkdir .ssh; chmod go-rwx .ssh; echo -e '${SSHID_PUB}\n' >> .ssh/authorized_keys"
qexpect expect "openbsd76#"
qexpect send -enter "pkg_add rrdtool"
qexpect expect "openbsd76#"
qexpect send -enter "shutdown -hp now"

sleep 20

qexpect kill
qexpect wait
