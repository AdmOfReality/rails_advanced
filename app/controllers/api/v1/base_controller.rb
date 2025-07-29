class Api::V1::BaseController < ApplicationController
  before_action :doorkeeper_authorize!

  include CanCan::ControllerAdditions

  def current_user
    current_resource_owner
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :forbidden
  end

  private

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
