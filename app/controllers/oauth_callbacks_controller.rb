class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    oauth_callback('Github')
  end

  def facebook
    oauth_callback('Facebook')
  end

  private

  def oauth_callback(service)
    auth = request.env['omniauth.auth']
    result = FindForOauth.new(auth).call

    if result == :no_email
      session['devise.oauth_data'] = auth.except('extra')
      redirect_to new_oauth_email_path
      return
    end

    @user = result

    if @user&.confirmed?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: service.to_s) if is_navigational_format?
    else
      session['devise.provider'] = auth.provider
      session['devise.uid'] = auth.uid
      redirect_to new_user_confirmation_path
    end
  end
end
