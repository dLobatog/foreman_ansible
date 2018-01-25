User.as_anonymous_admin do
  if Rails.env.test?
    # If this file tries to import a template with a REX feature in a SeedsTest,
    # it will fail - the REX feature isn't registered on SeedsTest because
    # DatabaseCleaner truncates the db before every test.
    ForemanAnsible::Engine.register_rex_feature
  end
  JobTemplate.without_auditing do
    Dir[File.join("#{ForemanAnsible::Engine.root}/app/views/foreman_ansible/"\
                  'job_templates/**/*.erb')].each do |template|
      sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
      JobTemplate.import_raw!(File.read(template),
                              :default => true,
                              :locked => true,
                              :update => sync)
    end
  end
end
