class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, except: %i[index new create]
  before_action :find_subscription, only: %i[show update]

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
    @question.destroy
    redirect_to questions_path, notice: 'Your question was successfully deleted.'
  end

  def destroy_link
    @link = @question.links.find(params[:link_id])
    @link.destroy
  end

  def purge_attachment
    @attachment = ActiveStorage::Attachment.find(params[:attachment_id])
    @attachment.purge
  end

  def subscribe
    if @question.subscribed_of?(current_user)
      flash[:notice] = 'Already subscribed'
      render :subscribe, status: :ok
    else
      @question.subscribe!(current_user)
      flash[:notice] = 'Subscribed successfully'
      render :subscribe, status: :created
    end
  end

  def unsubscribe
    if @question.subscribed_of?(current_user)
      @question.unsubscribe!(current_user)
      flash[:notice] = 'Unsubscribed successfully'
    else
      flash[:notice] = 'User is not subscribed'
    end
    render :unsubscribe, status: :ok
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

  def find_subscription
    return unless current_user

    @subscription = current_user.subscriptions
                                .find_by(question_id: @question)
  end
end
