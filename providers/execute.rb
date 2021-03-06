#
# Cookbook Name:: jenkins
# Based on hudson
# Provider:: execute
#
# Author:: Doug MacEachern <dougm@vmware.com>
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright:: 2010, VMware, Inc.
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

#pruned Chef::Provider::Execute + optional `block' param

include Chef::Mixin::Command

def action_run
  args = {}
  args[:timeout] = @new_resource.timeout if @new_resource.timeout
  args[:cwd] = @new_resource.cwd if @new_resource.cwd
  args[:path] = @new_resource.path if @new_resource.path
        
  cmd = Mixlib::ShellOut.new(@new_resource.command, args)
  cmd.run_command
  cmd.error!
  
  @new_resource.block.call(cmd.stdout) if @new_resource.block
  @new_resource.updated_by_last_action(true)
  Chef::Log.info("Ran #{@new_resource} successfully")
end


