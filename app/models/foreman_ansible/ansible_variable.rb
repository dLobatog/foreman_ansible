module ForemanAnsible
  # Represents the variables used in Ansible to parameterize playbooks
  class AnsibleVariable < LookupKey
    def ansible?
      true
    end

    def self.humanize_class_name
      "Ansible variable"
    end
  end
end
