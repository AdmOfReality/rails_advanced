class AnswerNotificationService
  def send_notify(answer)
    users = User.joins(:subscriptions).where(subscriptions: { question_id: answer.question })

    users.find_each do |user|
      AnswerNotificationMailer.notify(user, answer).deliver_later
    end
  end
end
