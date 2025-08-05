module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    expect(page).to have_current_path(root_path, ignore_query: true)

    expect(page).to have_content 'Signed in successfully'
  end

  def oauth_response(options = {})
    return if options[:provider].blank?

    OmniAuth.config.mock_auth[options[:provider].to_sym] = OmniAuth::AuthHash.new(
      'provider' => options[:provider].to_s,
      'uid' => '123',
      'info' => { 'email' => 'user@example.com' }
    )
  end
end
