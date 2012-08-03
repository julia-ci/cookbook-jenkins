#
# Cookbook Name:: jenkins
# Based on hudson
# Recipe:: node_windows
#
# Author:: Doug MacEachern <dougm@vmware.com>
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright 2010, VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

home = node['jenkins']['node']['home']
url  = node['jenkins']['server']['url']

directory home do
  action :create
end

env "JENKINS_HOME" do
  action :create
  value home
end

env "JENKINS_URL" do
  action :create
  value url
end

execute "Disable Firewall" do
  command "netsh advfirewall set allprofiles state off"
end

service "RemoteRegistry" do
  action :start
end

powershell "wbem-permissions" do
    code <<-EOH
        $definition = @"
        using System;
        using System.Runtime.InteropServices;
        namespace Win32Api
        {
        public class NtDll
        {
            [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
            public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
        }
        }
"@
        Add-Type -TypeDefinition $definition -PassThru
        $bEnabled = $false
        # Enable SeTakeOwnershipPrivilege
        $res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)
        $key = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("CLSID\\{76A64158-CB41-11D1-8B02-00600806D9B6}", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
        $acl = $key.GetAccessControl()
        $acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
        $key.SetAccessControl($acl)
            
        $key2 = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("CLSID\\{76A64158-CB41-11D1-8B02-00600806D9B6}",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
    
        $acl = $key2.GetAccessControl()
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule ("BUILTIN\\Administrators","FullControl","Allow")
        $acl.SetAccessRule($rule)
        $key2.SetAccessControl($acl)
    EOH
end

jenkins_node node['jenkins']['node']['name'] do
  description  node['jenkins']['node']['description']
  executors    node['jenkins']['node']['executors']
  remote_fs    node['jenkins']['node']['home']
  labels       node['jenkins']['node']['labels']
  mode         node['jenkins']['node']['mode']
  launcher     "service"
  mode         node['jenkins']['node']['mode']
  availability node['jenkins']['node']['availability']
  username     node['jenkins']['node']['user']
  password     node['jenkins']['node']['pass']
  host         node['ipaddr']
end
