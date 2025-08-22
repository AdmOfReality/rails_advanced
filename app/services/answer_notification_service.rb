class AnswerNotificationService
  def send_notify(answer)
    question = answer.question
    return unless question

    recipients = question
                 .subscribers
                 .where.not(id: answer.author_id)
                 .distinct

    recipients.find_each(batch_size: 500) do |user|
      AnswerNotificationMailer.notify(user, answer).deliver_later
    end
  end
end
