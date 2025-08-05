class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :find_question, only: %i[show update destroy]

  authorize_resource

  def index
    @questions = Question.with_attached_files.all
    render json: @questions
  end

  def show
    render json: @question
  end

  def create
    @question = current_resource_owner.questions.build(question_params)

    if @question.save
      render json: { question: @question }, status: :created
    else
      render json: { errors: @question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render json: { question: @question }, status: :ok
    else
      render json: { errors: @question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    payload = ActiveModelSerializers::SerializableResource.new(@question).as_json
    @question.destroy
    render json: payload, status: :ok
  end

  private

  def find_question
    @question = Question.with_attached_files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Question not found'] }, status: :not_found
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
