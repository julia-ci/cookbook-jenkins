action :create do
      remote_file "#{node['jenkins']['server']['home']}/plugins/#{new_resource.name}.hpi" do
        source  "#{node['jenkins']['mirror']}/plugins/#{new_resource.name}/latest/#{new_resource.name}.hpi"
        backup  false
        owner   node['jenkins']['server']['user'] 
        group   node['jenkins']['server']['group'] 
        notifies :restart, "service[jenkins]"
      end
end
