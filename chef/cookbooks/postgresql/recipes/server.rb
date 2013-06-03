::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'postgresql::default'

# randomly generate postgres password, unless using solo
if Chef::Config[:solo]
  if node['postgresql']['password']['postgres'].nil?
    Chef::Application.fatal! "You must set node['postgresql']['password']['postgres'] in chef-solo mode."
  end
else
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  node.save
end

package 'postgresql'

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, 'service[postgresql]', :immediately
end

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

service 'postgresql' do
  service_name 'postgresql'
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
  EOH
  action :run
end
