class AnswerNotificationJob < ApplicationJob
  queue_as :default

  def perform(answer)
    AnswerNotificationService.new.send_notify(answer)
  end
end
