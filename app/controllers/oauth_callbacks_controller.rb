class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    oauth_callback('Github')
  end

  def facebook
    oauth_callback('Facebook')
  end

  def oauth_callback(service)
    @user = User.find_for_oauth(request.env['omniauth.auth'])

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: service.to_s) if is_navigational_format?
    else
      redirect_to root_path, alert: 'User not found'
    end
  end
end
