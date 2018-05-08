# UI controller for ansible variables
class AnsibleVariablesController < ::ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include ForemanAnsible::Concerns::ImportControllerHelper

  before_action :find_resource, :only => [:destroy]

  def index
    @ansible_variables = resource_base.search_for(params[:search],
                                              :order => params[:order]).
                     paginate(:page => params[:page],
                              :per_page => params[:per_page])
  end

  def import

  end

  private

  def default_order
    params[:order] ||= 'name ASC'
  end

  def model_of_controller
    ForemanAnsible::AnsibleVariable
  end
end
