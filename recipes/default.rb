#
# Cookbook:: chef-aws-storage-gateway-kvm-rhel9
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.

aws_sgw 'devcomm-sgw' do
  aws_partition 'commercial'
  cpu_allocation 2
  mem_allocation 4000
  primary_disk 2
  cache_disk 1
  action %i(install create delete)
end
