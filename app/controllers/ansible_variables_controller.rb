# UI controller for ansible variables
class AnsibleVariablesController < ::LookupKeysController
  include Foreman::Controller::AutoCompleteSearch
  include ForemanAnsible::Concerns::ImportControllerHelper
  include Foreman::Controller::Parameters::AnsibleVariable

  before_action :find_required_proxy, :only => [:import]
  before_action :find_resource, :only => [:edit, :update, :destroy], :if => Proc.new { params[:id] }

  def index
    @ansible_variables = resource_base.search_for(params[:search],
                                              :order => params[:order]).
                     paginate(:page => params[:page],
                              :per_page => params[:per_page])
  end

  def import
    render 'ansible_variables/import',
      :locals => { :changed => @importer.import_variable_names }
  end

  def confirm_import
    results = @importer.finish_import(
      params[:changed][:new].as_json,
      params[:changed][:obsolete].as_json
    )
    info _(
      "Import of variables successfully finished.\n"\
      "Added: #{results[:added].join(', ')} \n "\
      "Removed: #{results[:obsolete].join(', ')}"
    )
    redirect_to ansible_variables_path
  end

  private

  def default_order
  end

  def resource
    @ansible_variable
  end

  def resource_params
    ansible_variable_params
  end

  def create_importer
    @importer = ForemanAnsible::VariablesImporter.new(@proxy)
  end

  def find_required_proxy
    id = params['proxy']
    @smart_proxy = SmartProxy.authorized(:view_smart_proxies).find(id)
    unless @smart_proxy && @smart_proxy.has_feature?('Ansible')
      not_found _('No proxy found to import variables from, ensure that the '\
                  'smart proxy has the Ansible feature enabled.')
    end
    @smart_proxy
  end
end
