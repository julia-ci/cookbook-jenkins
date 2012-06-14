

action :merge do
   if ::File.exists? new_resource.config_file
       base = XmlSimple.xml_in(new_resource.config_file,{ 'KeepRoot' => true })
   else
       base = {}
   end
   new = XmlSimple.xml_in(new_resource.local_file,{ 'KeepRoot' => true })
   base.merge!(new)
   file new_resource.config_file do
       backup false
       content  XmlSimple.xml_out(base,{ 'KeepRoot' => true, 'XmlDeclaration' => "<?xml version='1.0' encoding='UTF-8'?>" })
       notifies :restart, "service[jenkins]"
   end
end
