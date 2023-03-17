if [[ $(id -u) -ne 0 ]]; then
    sudo bash "$0" "$@"
    exit $?
fi
route add 172.16.2.0/24 via 10.50.8.6 dev eth0
route add 172.16.1.0/24 via 10.50.8.6 dev eth0
mkdir -p /mnt/partage
mount -t cifs -o username=olivier,password=olivier //172.16.2.40/partage /mnt/partage
