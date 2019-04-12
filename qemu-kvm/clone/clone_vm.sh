#!/bin/bash

# suspend template OS while cloning

virsh suspend <domain>
cp <old disk> <new disk>
virsh resume <domain>

kpartx -a <new disk>

# some logic to read relevant partitions

mount <desired partition> <mount point>

# some logic to parse contents of host-unique files

sed -i -e 's/old hostname line/new hostname line/' /etc/HOSTNAME
sed -i -e 's/old hostname line/new hostname line/' /etc/hosts
sed -i -e 's/old IP config/new IP config/' /etc/sysconfig/network/ifcfg-eth0

umount <mount point>

cp /etc/kvm/vm/old.xml /etc/kvm/vm/new.xml

# some logic to create new uuid, name, mac, etc
# some logic to parse XML files correctly

sed -i -e 's/old uuid/new uuid/' /etc/kvm/vm/new.xml
sed -i -e 's/old name/new name/' /etc/kvm/vm/new.xml
sed -i -e 's/old mac/new mac/' /etc/kvm/vm/new.xml
sed -i -e 's/old disk/new disk/' /etc/kvm/vm/new.xml

virsh create /etc/kvm/vm/new.xml

exit 0
