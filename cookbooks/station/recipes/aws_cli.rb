#
# Cookbook:: station
# Recipe:: aws_cli
#
# Copyright:: 2019, Maxwell Spangler, All Rights Reserved.

aws_cli_cfg = node['station']['aws_cli_cfg']

# Delete any previous download dir that may exist
# This is normally in /tmp and won't persist reboots or OS-reinstalls,
# but do this for safety reasons to avoid unzip
# asking about overwriting existing files
directory aws_cli_cfg['download_dir'] do

  recursive true

  action :delete

  not_if { ::File.exist?('/usr/local/bin/aws') }

  # Safety check, only recursively delete a directory in a variable
  # if the variable is only a subdirectory within /tmp
  only_if do
    Dir.exist?(aws_cli_cfg['download_dir']) &&
      aws_cli_cfg['download_dir'][0..4] == '/tmp/'
  end
end

directory aws_cli_cfg['download_dir'] do
  action :create

  not_if { ::File.exist?('/usr/local/bin/aws') }
end

# Download the remote file to a unique directory in /tmp
remote_file 'aws_cli_zip' do
  path "#{aws_cli_cfg['download_dir']}/#{aws_cli_cfg['package_name']}"

  source "#{aws_cli_cfg['rpm_source']}/#{aws_cli_cfg['package_name']}"

  action :create

  not_if { ::File.exist?('/usr/local/bin/aws') }
end

# Unpack its files
execute 'unzip_aws_cli' do
  command "unzip #{aws_cli_cfg['package_name']}"

  cwd aws_cli_cfg['download_dir']

  not_if { ::File.exist?('/usr/local/bin/aws') }
end

execute 'install_aws_cli' do
  command "#{aws_cli_cfg['download_dir']}/aws/install"

  not_if { ::File.exist?('/usr/local/bin/aws') }
end

directory aws_cli_cfg['download_dir'] do

  recursive true

  action :delete

  only_if do
    Dir.exist?(aws_cli_cfg['download_dir']) &&
      aws_cli_cfg['download_dir'][0..4] == '/tmp/'
  end
end
