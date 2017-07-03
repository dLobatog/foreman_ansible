# Displays Ansible roles tab on Host form
Deface::Override.new(
  :virtual_path => 'hosts/_form',
  :name => 'ansible_roles_tab',
  :insert_after => 'li.active',
  :partial => 'foreman_ansible/ansible_roles/select_tab_title'
)

Deface::Override.new(
  :virtual_path => 'hosts/_form',
  :name => 'ansible_roles_tab_content',
  :insert_after => 'div.tab-pane.active',
  :partial => 'foreman_ansible/ansible_roles/select_tab_content'
)

# Show Ansible roles parameters on the params tab
Deface::Override.new(
  :virtual_path => 'hosts/_form',
  :name => 'ansible_roles_tab_content',
  :insert_before => '#params > fieldset:nth-child(1)',
  :partial => 'foreman_ansible/hosts/ansible_parameters'
)
