# aws-storage-gateway-kvm

This cookbook provides a custom resource to configure and manage Amazon Web Services Storage Gateway virtual machines on RHEL9/KVM.

# Requirements

None.

# Resources/Providers

The `aws_sgw` custom resource manages an AWS Storage Gateway Virtual Machine.

## Actions

- `:install`: installs kvm and caches the vm templates (required for :create)
- `:create`: creates a new AWS Storage Gateway VM
- `:delete`: removes a pre-existing AWS Storage Gateway VM

## Attribute Parameters

- `aws_partition`:  required - (String) AWS Partition - `govcloud` or `commercial`. Default: `commercial`
- `cpu_allocation`: required - (Integer) The number of virtual CPUs to be allocated by the virtual machine. Default: `2`
- `mem_allocation`: required - (Integer) The amount of memory (in kilobytes) to be allocated for the virtual machine. Default `16384`
- `primary_disk`: required - (Integer) The amount of storage (in gigabytes) to be initially allocated for the virtual machine. Default: `80`
- `cache_disk`: required - (Integer) The amount of storage (in gigabytes) to be initially allocated for the virtual machine. Default: `160`

# Usage

In `metadata.rb` you should declare a dependency on this cookbook. For example:

```ruby
depends 'aws-storage-gateway-kvm'
```

A recipe using this custom resource may look like this:

```ruby
aws_sgw 'devcomm-sgw' do
  aws_partition 'commercial'
  cpu_allocation 2
  mem_allocation 8192
  primary_disk 2
  cache_disk 1
  action %i(install create delete)
end
```

#### Kitchen Output

```bash
Converging 1 resources
Recipe: aws-storage-gateway-kvm::default
    * aws_sgw[devcomm-sgw] action install
    * selinux_state[name] action permissive
        * template[permissive selinux config] action create
</SNIP>
- restore selinux security context
    * dnf_package[qemu-kvm-core] action install
        - install version 17:9.0.0-10.el9_5.2.x86_64 of package qemu-kvm-core
    * dnf_package[qemu-kvm-tools] action install
        - install version 17:9.0.0-10.el9_5.2.x86_64 of package qemu-kvm-tools
    * dnf_package[libvirt] action install
        - install version 0:10.5.0-7.4.el9_5.x86_64 of package libvirt
    * dnf_package[virt-manager] action install
        - install version 0:4.1.0-5.el9.noarch of package virt-manager
    * dnf_package[virt-install] action install
        - install version 0:4.1.0-5.el9.noarch of package virt-install
    * dnf_package[virt-viewer] action install
        - install version 0:11.0-1.el9.x86_64 of package virt-viewer
    * dnf_package[virt-top] action install
        - install version 0:1.1.1-9.el9.x86_64 of package virt-top
    * dnf_package[libguestfs-tools] action install
        - install version 0:1.51.6-5.el9.noarch of package libguestfs-tools
    * dnf_package[libvirt-daemon-config-network] action install (up to date)
    * dnf_package[unzip] action install
        - install version 0:6.0-57.el9.x86_64 of package unzip
    * service[libvirtd] action enable
        - enable service service[libvirtd]
    * service[libvirtd] action start
        - start service service[libvirtd]
    * directory[/opt/aws-sgw] action create
        - create new directory /opt/aws-sgw
        - change mode from '' to '0770'
        - change owner from '' to 'qemu'
        - change group from '' to 'qemu'
        - restore selinux security context
    * directory[/opt/aws-sgw/golden-images] action create
        - create new directory /opt/aws-sgw/golden-images
        - change mode from '' to '0660'
        - change owner from '' to 'root'
        - change group from '' to 'root'
        - restore selinux security context
    * directory[/opt/aws-sgw/sgw-disks] action create
        - create new directory /opt/aws-sgw/sgw-disks
        - change mode from '' to '0770'
        - change owner from '' to 'qemu'
        - change group from '' to 'qemu'
        - restore selinux security context
    * remote_file[/opt/aws-sgw/govcloud-aws-storage-gateway-file-s3.kvm.zip] action create
- Progress: 0%
- Progress: 10%
- Progress: 20%
- Progress: 30%
- Progress: 40%
- Progress: 50%
- Progress: 60%
- Progress: 70%
- Progress: 80%
- Progress: 90%
- Progress: 100%
        - create new file /opt/aws-sgw/govcloud-aws-storage-gateway-file-s3.kvm.zip
        - update content in file /opt/aws-sgw/govcloud-aws-storage-gateway-file-s3.kvm.zip from none to 61a41b
        (file sizes exceed 10000000 bytes, diff output suppressed)
        - change mode from '' to '0770'
        - change owner from '' to 'root'
        - change group from '' to 'root'
        - restore selinux security context
    * remote_file[/opt/aws-sgw/commercial-aws-storage-gateway-file-s3.kvm.zip] action create
- Progress: 0%
- Progress: 10%
- Progress: 20%
- Progress: 30%
- Progress: 40%
- Progress: 50%
- Progress: 60%
- Progress: 70%
- Progress: 80%
- Progress: 90%
- Progress: 100%
        - create new file /opt/aws-sgw/commercial-aws-storage-gateway-file-s3.kvm.zip
        - update content in file /opt/aws-sgw/commercial-aws-storage-gateway-file-s3.kvm.zip from none to fa1258
        (file sizes exceed 10000000 bytes, diff output suppressed)
        - change mode from '' to '0770'
        - change owner from '' to 'root'
        - change group from '' to 'root'
        - restore selinux security context
    * execute[Extract AWS GovCloud VM Template] action run
        - execute unzip -o govcloud-aws-storage-gateway-file-s3.kvm.zip -d golden-images/
    * execute[Extract AWS Commercial Template] action run
        - execute unzip -o commercial-aws-storage-gateway-file-s3.kvm.zip -d golden-images/
    
    * aws_sgw[devcomm-sgw] action create
    * file[/opt/aws-sgw/sgw-disks/devcomm-sgw-primary-disk.qcow2] action create
        - create new file /opt/aws-sgw/sgw-disks/devcomm-sgw-primary-disk.qcow2
        - update content in file /opt/aws-sgw/sgw-disks/devcomm-sgw-primary-disk.qcow2 from none to e8b9ad
        (file sizes exceed 10000000 bytes, diff output suppressed)
        - change mode from '' to '0770'
        - change owner from '' to 'qemu'
        - change group from '' to 'qemu'
        - restore selinux security context
    * execute[Gather VM Data] action run
        - execute virsh list --all | awk '{ print $2 }' | tail -n +3 > /tmp/virsh-list-output.txt
    * execute[Creating Storage Gateway - devcomm-sgw] action run
        - execute       virt-install       --name "devcomm-sgw"       --description "devcomm-sgw Storage Gateway VM"       --os-variant=rhel9-unknown       --ram=8192       --vcpus=2       --disk path=/opt/aws-sgw/sgw-disks/devcomm-sgw-primary-disk.qcow2,bus=virtio,size=2       --disk path=/opt/aws-sgw/sgw-disks/devcomm-sgw}-cache-disk.qcow2,bus=virtio,size=1       --network default,model=virtio       --serial pty,target_type=isa-serial       --console pty,target_type=serial       --graphics vnc,listen="127.0.0.1",keymap=local       --autoconsole none       --import
    * aws_sgw[devcomm-sgw] action delete
    * execute[Gather VM Data] action run
        - execute virsh list --all | awk '{ print $2 }' | tail -n +3 > /tmp/virsh-list-output.txt
    * execute[Power Down VM - devcomm-sgw] action run
        - execute virsh destroy devcomm-sgw
    * execute[Destroy VM - devcomm-sgw] action run
        - execute virsh undefine devcomm-sgw --remove-all-storage
    

Running handlers:
Running handlers complete
Infra Phase complete, 29/30 resources updated in 05 minutes 40 seconds
Downloading files from <default-bento-rockylinux-9>
Finished converging <default-bento-rockylinux-9> (5m57.48s).
```

## Contributing

1. Fork the project on github
2. Commit your changes to your fork
3. Send a pull request

# License & Author

- Author:: Erin L. Kolp (<erinlkolpfoss@gmail.com>)

Copyright (c) 2025 Erin L. Kolp 

Licensed under the MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
