class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_question, only: %i[create destroy]
  before_action :find_answer, only: :destroy

  def create
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user

    if @answer.save
      redirect_to @question, notice: 'Your answer successfully created.'
    else
      render 'questions/show', status: :unprocessable_entity
    end
  end

  def destroy
    if current_user&.author_of?(@answer)
      @answer.destroy
      redirect_to question_path(@answer.question), notice: 'Your answer was successfully deleted.'
    else
      redirect_to @question, alert: "You can't change someone else's answer."
    end
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = @question.answers.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
