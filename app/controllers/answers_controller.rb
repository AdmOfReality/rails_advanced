class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_question, only: %i[create]
  before_action :find_answer, only: %i[destroy update best purge_attachment]

  def create
    @answer = @question.answers.build(answer_params)
    @answer.author = current_user
    @answer.save
  end

  def update
    if current_user&.author_of?(@answer)
      @answer.update(answer_params)
    else
      head :forbidden
    end
  end

  def destroy
    if current_user&.author_of?(@answer)
      @answer.destroy
    else
      head :forbidden
    end
  end

  def best
    if current_user&.author_of?(@answer.question)
      @answer.best_answer
    else
      head :forbidden
    end
  end

  def purge_attachment
    @attachment = ActiveStorage::Attachment.find(params[:attachment_id])

    if current_user&.author_of?(@answer)
      @attachment.purge
    else
      head :forbidden
    end
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
    @question = @answer.question
  end

  def answer_params
    params.require(:answer).permit(:body, files: [])
  end
end
