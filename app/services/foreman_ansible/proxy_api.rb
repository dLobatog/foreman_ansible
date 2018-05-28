module ForemanAnsible
  module ProxyAPI
    extend ActiveSupport::Concern

    included do
      attr_reader :ansible_proxy

      def find_proxy_api
        raise ::Foreman::Exception.new(N_('Proxy not found')) unless ansible_proxy
        @proxy_api = ::ProxyAPI::Ansible.new(:url => ansible_proxy.url)
      end

      def proxy_api
        return @proxy_api if @proxy_api
        find_proxy_api
      end
    end
  end
end
