class OauthEmailsController < ApplicationController
  def new; end

  def create
    email = params[:email]
    oauth_data = session['devise.oauth_data']

    unless email.present? && oauth_data
      redirect_to new_oauth_email_path, alert: 'Введите email'
      return
    end

    user = User.find_by(email: email)
    if user
      user.send_confirmation_instructions unless user.confirmed?
      redirect_to new_user_session_path, alert: 'Пользователь с таким email уже существует. Проверьте почту.'
      return
    end

    password = Devise.friendly_token[0, 20]
    User.create!(
      email: email,
      password: password,
      password_confirmation: password
    )

    session['devise.oauth_data'] = oauth_data
    session['devise.user_email'] = email

    redirect_to new_user_session_path, notice: 'Письмо с подтверждением отправлено.'
  end
end
