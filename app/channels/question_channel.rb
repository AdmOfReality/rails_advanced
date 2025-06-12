class QuestionChannel < ApplicationCable::Channel
  def subscribed
    question = Question.find(params[:id])
    stream_for question
  end
end
