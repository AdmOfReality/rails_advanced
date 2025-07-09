class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show update destroy edit purge_attachment destroy_link]

  authorize_resource

  def index
    @questions = Question.all
  end

  def show
    @answer = Answer.new
    @answer.links.new
  end

  def new
    @question = Question.new
    @question.links.new
    @question.build_reward
  end

  def edit; end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      publish_question
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def update
    @question.update(question_params)
  end

  def destroy
    if current_user&.author_of?(@question)
      @question.destroy
      redirect_to questions_path, notice: 'Your question was successfully deleted.'
    else
      redirect_to @question, alert: "You can't change someone else's question."
    end
  end

  def destroy_link
    @link = @question.links.find(params[:link_id])

    if current_user&.author_of?(@question)
      @link.destroy
    else
      head :forbidden
    end
  end

  def purge_attachment
    @attachment = ActiveStorage::Attachment.find(params[:attachment_id])

    if current_user&.author_of?(@question)
      @attachment.purge
    else
      head :forbidden
    end
  end

  private

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(
      :title,
      :body,
      files: [],
      links_attributes: [:name, :url, :_destroy, :id],
      reward_attributes: [:title, :image]
    )
  end

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast 'questions',
                                 ApplicationController.render(
                                   partial: 'questions/question_public',
                                   locals: { question: @question }
                                 )
  end
end
