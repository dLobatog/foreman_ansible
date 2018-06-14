module ForemanAnsible
  # Relations to make Host::Managed 'have' ansible roles
  module HostManagedExtensions
    extend ActiveSupport::Concern
    include ::ForemanAnsible::Concerns::JobInvocationHelper

    included do
      has_many :host_ansible_roles, :foreign_key => :host_id
      has_many :ansible_roles, :through => :host_ansible_roles,
                               :dependent => :destroy
      scoped_search :relation => :ansible_roles, :on => :name,
                    :complete_value => true, :rename => :role,
                    :only_explicit => true

      before_provision :play_ansible_roles
      include ForemanAnsible::HasManyAnsibleRoles
      audit_associations :ansible_roles

      def inherited_ansible_roles
        return [] unless hostgroup
        hostgroup.all_ansible_roles
      end

      def play_ansible_roles
        return unless ansible_roles.present? || inherited_ansible_roles.present?
        composer = job_composer(:ansible_run_host, self)
        composer.trigger!
        logger.info("Task for Ansible roles on #{self} before_provision: "\
                    "#{job_invocation_path(composer.job_invocation)}")
      rescue Foreman::Exception => e
        logger.info("Error running Ansible roles on #{self} before_provision: "\
                    "#{e.message}")
      end
    end
  end
end

module Host
  class Managed
    # Methods to be allowed in any template with safemode enabled
    class Jail < Safemode::Jail
      allow :all_ansible_roles, :ansible_roles, :inherited_ansible_roles
    end
  end
end
