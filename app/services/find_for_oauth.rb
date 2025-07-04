class FindForOauth
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def call
    authorization = find_authorization
    return authorization.user if authorization

    email = fetch_email
    # return nil unless email
    return :no_email unless email

    user = find_or_create_user(email)
    user.create_authorization(auth)
    user
  end

  private

  def find_authorization
    Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
  end

  def fetch_email
    auth.info[:email]
  end

  def find_or_create_user(email)
    user = User.find_by(email: email)
    return user if user

    password = Devise.friendly_token[0, 20]
    user = User.new(
      email: email,
      password: password,
      password_confirmation: password
    )
    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.save!
    user
  end
end
