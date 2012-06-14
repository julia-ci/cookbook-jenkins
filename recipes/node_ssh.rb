#
# Cookbook Name:: jenkins
# Based on hudson
# Recipe:: node_ssh
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

include_recipe user

user_account node['jenkins']['node']['user']
    comment "Jenkins CI node (ssh)"
    create_group true
    ssh_keygen true
    ssh_keys [IO.read(node['jenkins']['node']['pub_key_path'])]
end
