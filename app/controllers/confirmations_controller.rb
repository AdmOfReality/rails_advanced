class ConfirmationsController < Devise::ConfirmationsController
  def after_confirmation_path_for(_resource_name, user)
    oauth_data = session.delete('devise.oauth_data')
    email = session.delete('devise.user_email')

    if oauth_data && email && user.email == email
      user.authorizations.create(
        provider: oauth_data['provider'],
        uid: oauth_data['uid']
      )
    elsif session[:provider].present? && session[:uid].present?
      user.authorizations.create(
        provider: session.delete(:provider),
        uid: session.delete(:uid)
      )
    end

    sign_in user, event: :authentication
    root_path
  end
end
