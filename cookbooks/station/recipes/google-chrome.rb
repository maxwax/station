#
# Cookbook:: station
# Recipe:: google-chrome
#
# Copyright:: 2019, Maxwell Spangler, All Rights Reserved.

my = node['station']['user']
root = node['station']['root']

# WARNING: Order matters: Import the key IF NO REPO, THEN make the repo.

remote_file 'google-signing-key' do
  path "/home/#{my['username']}/Downloads/linux_signing_key.pub"
  source 'https://dl.google.com/linux/linux_signing_key.pub'
  action :create

  not_if 'fgrep "enabled=1" /etc/yum.repos.d/google-chrome.repo'
end

execute 'install-google-key-rpm' do
  command "rpm --import /home/#{my['username']}/Downloads/linux_signing_key.pub"

  not_if 'fgrep "enabled=1" /etc/yum.repos.d/google-chrome.repo'
end

execute 'install-google-key-rpmkeys' do
  command "rpmkeys --import /home/#{my['username']}/Downloads/linux_signing_key.pub"

  not_if 'fgrep "enabled=1" /etc/yum.repos.d/google-chrome.repo'
end

cookbook_file '/etc/yum.repos.d/google-chrome.repo' do
  source 'etc/yum.repos.d/google-chrome.repo'
  owner 'root'
  group 'root'
  mode root['mode_config_file']
  action :create

  not_if 'fgrep "enabled=1" /etc/yum.repos.d/google-chrome.repo'
end

package 'google-chrome-stable' do
  action :install

  flush_cache [ :before ]

  not_if { node['packages'].key?('google-chrome-stable') }
end
