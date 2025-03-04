# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
unified_mode true
provides :aws_sgw

property :aws_partition, String, default: 'commercial'
property :cpu_allocation, Integer, default: 2
property :mem_allocation, Integer, default: 16384
property :primary_disk, Integer, default: 80
property :cache_disk, Integer, default: 160

govcloud_dl_location = 'https://s3-us-gov-west-1.amazonaws.com/storage-gateway-file-s3-images-us-gov-west-1'
commercial_dl_location = 'https://dd958of58tzpr.cloudfront.net'
aws_dl_filename = 'aws-storage-gateway-file-s3.kvm.zip'
target_directory = '/opt/aws-sgw'

action :install do
  selinux_state 'name' do
    persistent true
    action :permissive
  end  

  %w(
    qemu-kvm-core
    qemu-kvm-tools
    libvirt
    virt-manager
    virt-install
    virt-viewer
    virt-top
    libguestfs-tools
    libvirt-daemon-config-network
    unzip
  ).each do |pkg|
    package pkg do
      options '-y'
      action :install
    end
  end

  service 'libvirtd' do
    action [:enable, :start]
  end

  directory target_directory do
    owner 'qemu'
    group 'qemu'
    mode '0770'
    action :create
  end

  directory "#{target_directory}/golden-images" do
    owner 'root'
    group 'root'
    mode '0660'
    action :create
  end

  directory "#{target_directory}/sgw-disks" do
    owner 'qemu'
    group 'qemu'
    mode '0770'
    action :create
  end

  remote_file "#{target_directory}/commercial-#{aws_dl_filename}" do
    source "#{commercial_dl_location}/#{aws_dl_filename}"
    owner 'root'
    group 'root'
    mode '0770'
    show_progress true
    action :create
    use_conditional_get true
    use_last_modified true
  end
  
  execute 'Extract AWS Commercial Template' do
    command "unzip -o commercial-#{aws_dl_filename} -d golden-images/"
    cwd "#{target_directory}"
    action :run
    creates "#{target_directory}/golden-images/prod-us-east-1/prod-us-east-1.qcow2"
  end
end

action :create do
  case new_resource.aws_partition
  when "govcloud"
    exit(1)
    file_path = "golden-images/aws-region-goes-here/aws-region-goes-here.qcow2"
  when "commercial"
    file_path = "golden-images/prod-us-east-1/prod-us-east-1.qcow2"
  else
    exit(1)
  end

  file "#{target_directory}/sgw-disks/#{new_resource.name}-primary-disk.qcow2" do
    owner 'qemu'
    group 'qemu'
    mode '0770'
    content ::File.open("#{target_directory}/#{file_path}").read
    action :create
    not_if { ::File.exist?("#{target_directory}/sgw-disks/#{new_resource.name}-primary-disk.qcow2") }
  end

  execute 'Gather VM Data' do
    command "virsh list --all | awk '{ print $2 }' | tail -n +3 > /tmp/virsh-list-output.txt"
    cwd "#{target_directory}"
    action :run
  end

  execute "Creating Storage Gateway - #{new_resource.name}" do 
    user 'root'
    cwd  '/root'
    command <<-"EOH"
      virt-install \
      --name "#{new_resource.name}" \
      --description "#{new_resource.name} Storage Gateway VM" \
      --os-variant=rhel9-unknown \
      --ram=#{new_resource.mem_allocation} \
      --vcpus=#{new_resource.cpu_allocation} \
      --disk path=#{target_directory}/sgw-disks/#{new_resource.name}-primary-disk.qcow2,bus=virtio,size=#{new_resource.primary_disk} \
      --disk path=#{target_directory}/sgw-disks/#{new_resource.name}-cache-disk.qcow2,bus=virtio,size=#{new_resource.cache_disk} \
      --network default,model=virtio \
      --serial pty,target_type=isa-serial \
      --console pty,target_type=serial \
      --graphics vnc,listen="127.0.0.1",keymap=local \
      --autoconsole none \
      --import
    EOH
    only_if { ::File.readlines('/tmp/virsh-list-output.txt').grep(/#{new_resource.name}/).empty? }
  end
end

action :delete do
  execute 'Gather VM Data' do
    command "virsh list --all | awk '{ print $2 }' | tail -n +3 > /tmp/virsh-list-output.txt"
    cwd "#{target_directory}"
    action :run
  end

  execute "Power Down VM - #{new_resource.name}" do
    command "virsh destroy #{new_resource.name}"
    cwd "#{target_directory}"
    action :run
    not_if { ::File.readlines('/tmp/virsh-list-output.txt').grep(/#{new_resource.name}/).empty? }
  end

  execute "Destroy VM - #{new_resource.name}" do
    command "virsh undefine #{new_resource.name} --remove-all-storage"
    cwd "#{target_directory}"
    action :run
    not_if { ::File.readlines('/tmp/virsh-list-output.txt').grep(/#{new_resource.name}/).empty? }
  end
end
