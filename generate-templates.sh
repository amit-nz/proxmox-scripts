# Before running, you will have to 
# 1. Load your keys into github (https://github.com/settings/keys) & adjust the comments for SSH keys below (" Your-SSH-Key-Name")
# 2. Download the latest version of the cloud init disk images for each distro
# 3. Adjust VM IDs (9000 -> 9002 in this case) in case they conflict w/ your environments
# 4. Optional: Change vmbr name; change storage name; change (or remove) username
# 5. Set up the snippet (see tz_config_and_install_qemu_ga.yml in this repo)

# Download ssh key from github and get it ready to go
wget -qO /tmp/ssh-key https://github.com/your-github-username.keys
truncate -s -1 /tmp/ssh-key && echo -n " Your-SSH-Key-Name" >> /tmp/ssh-key

# Debian 
# Download the latest disk img from here: https://cdimage.debian.org/images/cloud/
qm create 9000 --memory 4096 --core 4 --name debian-13-cloudinit --net0 virtio,bridge=vmbr0
qm importdisk 9000 /path/to/debian-disk.qcow2 local-lvm
qm set 9000 -scsihw virtio-scsi-pci --virtio0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk virtio0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent 1
qm set 9000 --cicustom "vendor=local:snippets/tz_config_and_install_qemu_ga.yml"
qm set 9000 --ipconfig0 ip=dhcp,ip6=auto
qm set 9000 --sshkeys /tmp/ssh-key
qm set 9000 --ciuser yourusername # Set username; without this, it will just be "debian"

# Ubuntu 
# Download the latest disk img from here: https://cloud-images.ubuntu.com/ 
qm create 9001 --memory 4096 --core 4 --name ubuntu-cloudinit --net0 virtio,bridge=vmbr0
qm importdisk 9001 /path/to/ubuntu-disk.img local-lvm
qm set 9001 -scsihw virtio-scsi-pci --virtio0 local-lvm:vm-9001-disk-0
qm set 9001 --ide2 local-lvm:cloudinit
qm set 9001 --boot c --bootdisk virtio0
qm set 9001 --serial0 socket --vga serial0
qm set 9001 --agent 1
qm set 9001 --cicustom "vendor=local:snippets/tz_config_and_install_qemu_ga.yml"
qm set 9000 --ipconfig0 ip=dhcp,ip6=auto
qm set 9000 --sshkeys /tmp/ssh-key
qm set 9001 --ciuser yourusername # Set username; without this, it will just be "ubuntu"

# Rocky
# Download the latest disk img from here: https://dl.rockylinux.org/pub/rocky/
qm create 9002 --memory 4096 --core 4 --name rocky-9-cloudinit --net0 virtio,bridge=vmbr0
qm importdisk 9002 /path/to/Rocky-disk.qcow2 local-lvm
qm set 9002 -scsihw virtio-scsi-pci --virtio0 local-lvm:vm-9002-disk-0
qm set 9002 --ide2 local-lvm:cloudinit
qm set 9002 --boot c --bootdisk virtio0
# Rocky will not boot with cpu type = kvm (which is default in Proxmox 9; Needs at least are "x86-64-v2-AES" or "host")
# "x86-64-v2-AES" is safer as it is better compatible with migrating between hosts with dissimilar CPUs present in your envornment.
qm set 9002 --cpu x86-64-v2-AES
qm set 9002 --serial0 socket --vga serial0
qm set 9002 --agent 1
qm set 9002 --cicustom "vendor=local:snippets/tz_config_and_install_qemu_ga.yml"
qm set 9000 --ipconfig0 ip=dhcp,ip6=auto
qm set 9000 --sshkeys /tmp/ssh-key
qm set 9002 --ciuser yourusername # Set username; without this, it will just be "cloud-user"

# Convert all the above to templates:
# Double check everything before doing this as it is irreversible (but you can always qm destroy <vmid> and restart) 
qm template 9000
qm template 9001
qm template 9002
# Remove the ssh key
rm /tmp/ssh-key
