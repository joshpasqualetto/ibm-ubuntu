#
# Cookbook Name:: ibm-ubuntu
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "acpid"
package "openssh-server"
package "dialog"
package "rcconf"

gem_package "ruby-shadow"

directory "/etc/sysconfig/network-scripts/" do
  mode "0755"
  recursive true
end

cookbook_file "/etc/init/ttyS0.conf" do
  mode "0644"
end

cookbook_file "/etc/init/ttyS1.conf" do
  mode "0644"
end

cookbook_file "/etc/init.d/smartcloud" do
  mode "0755"
end

cookbook_file "/etc/sysconfig/network-scripts/ifcfg-eth0" do
  mode "0644"
end

cookbook_file "/etc/init.d/ubuntu_interfaces_0" do
  mode "0755"
  action :create_if_missing
end

execute "smartcloud_on" do
  command "rcconf --on smartcloud"
  not_if "rcconf --list|grep 'smartcloud on'"
end

execute "update_grub" do
  command "update-grub"
  action :nothing
end

cookbook_file "/etc/default/grub" do
  mode "0644"
  notifies :run, resources(:execute => "update_grub"), :immediately
end

user "idcuser" do
  comment "IBM SmartCloud User"
  password "*"
  action :create
end

directory "/home/idcuser/.ssh/" do
  owner "idcuser"
  group "idcuser"
end

execute "idcuser_into_sudoers" do
  command "echo 'idcuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
  not_if "grep idcuser /etc/sudoers"
end

execute "modify_init" do
  command "sed -e 's/DEFAULT_RUNLEVEL=2/DEFAULT_RUNLEVEL=3/g' -i'' /etc/init/rc-sysinit.conf"
  not_if 'grep DEFAULT_RUNLEVEL=3 /etc/init/rc-sysinit.conf'
end
