module ForemanAnsible
  module Concerns
    # Helpers to select proxy and call ProxyAPI
    module ImportControllerHelper
      extend ActiveSupport::Concern

      included do
        before_action :find_resource, :only => [:destroy]
        before_action :find_proxy, :only => [:import]
        before_action :create_importer, :only => [:import, :confirm_import]
        before_action :default_order, :only => [:index]
      end

       def find_proxy
          return nil unless params[:proxy]
          @proxy = SmartProxy.authorized(:view_smart_proxies).find(params[:proxy])
        end

        def create_importer
          @importer = ForemanAnsible::UiRolesImporter.new(@proxy)
        end

        def no_changed_roles_message
          return _('No changes in roles detected.') if @proxy.blank?
          _('No changes in roles detected on %s.') % @proxy.name
        end
    end
  end
end
