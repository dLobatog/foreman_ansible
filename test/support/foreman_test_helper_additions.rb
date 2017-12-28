# loads the permissions for foreman_ansible and makes them available in tests
module AnsiblePermissionTestCase
  extend ActiveSupport::Concern

  included do
    extend ActiveRecord::TestFixtures

    self.use_instantiated_fixtures = false
    self.pre_loaded_fixtures = true
    new_fixture_path = Rails.root.join('tmp', 'ansible_fixtures')
    FileUtils.rm_rf(new_fixture_path) if File.directory?(new_fixture_path)
    Dir.mkdir new_fixture_path
    self.fixture_path = new_fixture_path
    ForemanAnsible::PluginFixtures.add_fixtures(new_fixture_path)
    fixtures(:all)
    load_fixtures(ActiveRecord::Base)
    require 'foreman_ansible/register'
  end
end

module ActiveSupport
  #:nodoc
  class TestCase
    prepend AnsiblePermissionTestCase
  end
end

module ActionDispatch
  #:nodoc
  class IntegrationTest
    prepend AnsiblePermissionTestCase
  end
end

module ActionController
  #:nodoc
  class TestCase
    prepend AnsiblePermissionTestCase
  end
end
