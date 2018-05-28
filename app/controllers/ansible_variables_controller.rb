# UI controller for ansible variables
class AnsibleVariablesController < ::ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include ForemanAnsible::Concerns::ImportControllerHelper

  before_action :find_required_proxy, :only => [:import]
  before_action :find_resource, :only => [:edit, :update, :destroy],
    :if => Proc.new { params[:id] }

  def index
    @ansible_variables = resource_base.search_for(params[:search],
                                              :order => params[:order]).
                     paginate(:page => params[:page],
                              :per_page => params[:per_page])
  end

  def edit
    render 'ansible_variables/edit',
      :locals => { :lookup_key => @ansible_variable }
  end

  def update
    binding.pry
    update_params = resource_params.merge(
      :lookup_values_attributes => sanitize_attrs
    )
    if @ansible_variable.update(update_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @ansible_variable.destroy
      process_success
    else
      process_error
    end
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
    notice _(
      'Import of variables successfully finished.'\
      "Added: #{results[:new]}"\
      "Removed: #{results[:removed]}"
    )
    redirect_to ansible_variables_path
  end

  def resource_class
    ForemanAnsible::AnsibleVariable
  end

  private

  def default_order
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

  def model_of_controller
    ForemanAnsible::AnsibleVariable
  end
end
