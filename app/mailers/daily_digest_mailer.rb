class DailyDigestMailer < ApplicationMailer
  def digest(user)
    @questions = Question.where(created_at: Time.zone.yesterday.all_day)
    mail to: user.email
  end
end
