#
# Install script for Ubuntu 24.04
#
ENV_NAME=ubuntu2404
IMG_SOURCE=https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img

TEMP_DIR=`mktemp -d`

DISK=${ROOT}/disks/${ENV_NAME}.qcow2
IMG_FILE=${ROOT}/iso/${ENV_NAME}.img
SEED_IMG_FILE=${ROOT}/iso/${ENV_NAME}_seed.img
SSHID_FILE=${ROOT}/ssh/id

if [ ! -d ${ROOT} ]; then
    echo "Please set ROOT to root directory"
    exit -1
fi

if [ ! -f ${IMG_FILE} ]; then
    curl "${IMG_SOURCE}" -o ${IMG_FILE}
fi

if [ ! -f ${DISK} ]; then
    qemu-img  create -f qcow2 -b ${IMG_FILE} -F qcow2 ${DISK} 4G
fi

if [ ! -f ${SSHID_FILE} ]; then
    ssh-keygen -f ${SSHID_FILE} -P ""
fi

SSHID_PUB=`cat ${SSHID_FILE}.pub`

if [ ! -f ${SEED_IMG_FILE} ]; then
    cat <<EOF >${TEMP_DIR}/user-data
#cloud-config
hostname: ubuntu2404

users:
  - name: root
    plain_text_password: root
    ssh_authorized_keys:
      - ${SSHID_PUB}

network:
  version: 1
  config:
  - type: physical
    name: eth0
    subnets:
      - type: dhcp

package_update: true
package_upgrade: true
packages:
  - rrdtool
  - librrd-dev
  - bmake
  - gcc

power_state:
  delay: now
  mode: poweroff
  message: "Installation done"
EOF

    cat <<EOF >${TEMP_DIR}/meta-data
instance-id: someid/ubuntu2404

EOF

    touch ${TEMP_DIR}/vendor-data

    truncate --size 2M ${SEED_IMG_FILE}
    mkfs.vfat -n cidata ${SEED_IMG_FILE}
    mcopy -oi ${SEED_IMG_FILE} ${TEMP_DIR}/user-data ${TEMP_DIR}/meta-data ${TEMP_DIR}/vendor-data ::
fi

qemu-system-x86_64 -cpu host -machine pc-q35-2.8,accel=kvm -m 2048 -hda ${DISK} -hdb ${SEED_IMG_FILE} -netdev user,id=n0,hostfwd=tcp:127.0.0.1:7022-:22 -device e1000,netdev=n0

exit
