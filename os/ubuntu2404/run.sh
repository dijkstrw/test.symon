#
# run script for Ubuntu 24.04
#

# Objective: make a repeatable environment in qemu where we can test
# cross platform compilation and execution of symon.
COMMAND=$1
shift
ARGS=$@

ENV_NAME=ubuntu2404

DISK=${ROOT}/disks/${ENV_NAME}.qcow2
SSHID_FILE=${ROOT}/ssh/id

TERM=xterm
SSH_HOST=root@127.0.0.1
SSH_CMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7022 -i ${SSHID_FILE}"
SCP_CMD="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P 7022 -i ${SSHID_FILE}"

case ${COMMAND} in
    start)
        qemu-system-x86_64 -nographic -cpu host -machine q35,accel=kvm -m 2048 -hda ${DISK} -netdev user,id=n0,hostfwd=tcp:127.0.0.1:7022-:22 -device e1000,netdev=n0
        ;;
    stop)
        ${SSH_CMD} ${SSH_HOST} "poweroff"
        ;;
    connect)
        ${SSH_CMD} ${SSH_HOST}
        ;;
    test)
        ${SSH_CMD} ${SSH_HOST} "rm -rf /tmp/symon"
        ${SCP_CMD} -r ${ROOT}/symon ${SSH_HOST}:/tmp
        ${SCP_CMD} ${ROOT}/os/${ENV_NAME}/sy* ${SSH_HOST}:/tmp
        ${SSH_CMD} ${SSH_HOST} << EOF
        useradd -d /tmp/symon/rrds symux
        cd /tmp/symon
        bmake
        cat symux/symux.cat8
        ./symon/symon -du -f /tmp/symon.conf &
        mkdir -p /tmp/symon/rrds/localhost
        rrds=\$(./symux/symux -l -f /tmp/symux.conf)
        echo rrds are: \$rrds
        ./symux/c_smrrds.sh \$rrds
        chown -R symux /tmp/symon/rrds
        ./symux/symux -d -f "/tmp/symux.conf" &
        sleep 2
        cat /var/run/symux.fifo &
        sleep 10
        pkill cat
        sleep 30
        pkill symon
        pkill symux
EOF
        ;;
esac
