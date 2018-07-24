module ForemanAnsible
  class VariablesImporter
    include ::ForemanAnsible::ProxyAPI

    def initialize(proxy = nil)
      @ansible_proxy = proxy
    end

    def import_variable_names
      return import_variables(remote_variables) if @ansible_proxy
      import_variables(local_variables)
    end

    def import_variables(role_variables)                     j
      imported = role_variables.map do |role, variables|
        role = AnsibleRole.find_by_name(role)
        next unless role.present?
        variables.map do |variable|
          variable = AnsibleVariable.find_or_initialize_by(
            :key => variable,
            # :key_type, :default_value, :required
          )
          variable.ansible_role = role
          variable.valid? ? variable : nil
        end
      end.select { |vars| vars.present? }.flatten.compact
      detect_changes(imported)
    end

    def detect_changes(imported)
      changes = {}.with_indifferent_access
      old, changes[:new] = imported.partition { |role| role.id.present? }
      changes[:obsolete] = AnsibleVariable.where.not(:id => old.map(&:id))
      changes
    end

    def finish_import(new, obsolete)
      results = { :added => [], :obsolete => [] }
      results[:added] = create_new_variables(new) if new.present?
      results[:obsolete] = delete_old_variables(obsolete) if obsolete.present?
      results
    end

    def create_new_variables(new)
      added = []
      new.each do |name, variable_properties|
        variable = AnsibleVariable.new(
          JSON.parse(variable_properties)['ansible_variable']
        )
        variable.save
        added << variable.key
      end
      added
    end

    def delete_old_variables(old)
      removed = []
      old.each do |name, variable_properties|
        variable = AnsibleVariable.find(
          JSON.parse(variable_properties)['ansible_variable']['id'])
        removed << variable.key
        variable.destroy
      end
      removed
    end

    private

    def local_variables
      ::AnsibleVariable.all
    end

    def remote_variables
      proxy_api.all_variables
    end
  end
end
