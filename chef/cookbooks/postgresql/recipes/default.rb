include_recipe "postgresql::repository"
include_recipe 'postgresql::client'
include_recipe 'postgresql::server' unless node[:postgresql][:client_only]
