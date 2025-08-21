class AnswerNotificationMailer < ApplicationMailer
  def notify(user, answer)
    @user     = user
    @answer   = answer
    @question = answer.question

    mail(
      to: @question.author.email,
      subject: "Notify: Your have new answer from #{@question.title}"
    )
  end
end
