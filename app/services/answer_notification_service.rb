class AnswerNotificationService
  def send_notify(answer)
    return unless answer

    question = answer.question
    q_author = question&.author

    # return if answer.author_id == q_author.id

    AnswerNotificationMailer.notify(q_author, answer).deliver_later
  end
end
