class AnswersController < ApplicationController
  before_action :find_question, only: :create

  def create
    @answer = @question.answers.new(answer_params)
    if @answer.save
      redirect_to question_answers_path(@question, @answer)
    else
      render :new
    end
  end

  def new; end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
