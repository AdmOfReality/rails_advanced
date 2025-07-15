class ApplicationController < ActionController::Base

  skip_authorization_check if: :skip_cancan_authorization?
  check_authorization unless: :skip_cancan_authorization?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url, alert: exception.message }
      format.js   { head :forbidden }
      format.json { head :forbidden }
    end
  end

  private

  def skip_cancan_authorization?
    devise_controller? || api_request?
  end

  def api_request?
    request.path.start_with?('/api/')
  end
end
