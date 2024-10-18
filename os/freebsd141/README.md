FreeBSD serial
--------------

Default install images of FreeBSD are wired for installation via vnc. To enable serial download the image, start it like this:

    qemu-system-x86_64 -cpu host -machine pc-q35-2.8,accel=kvm -m 2048 -hda /tmp/FreeBSD-14.1-RELEASE-amd64-mini-memstick.img

Then boot to single user mode, remount root directory:

    mount -o rw /

and edit `/boot/loader.conf` to have it contain:

    boot_multicons="YES"
    boot_serial="YES"
    comconsole_speed="115200"
    console="comconsole,vidconsole"

after that poweroff `poweroff` the machine and the image will start via serial (and vnc as a backup).

