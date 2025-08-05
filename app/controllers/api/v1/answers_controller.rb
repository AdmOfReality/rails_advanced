class Api::V1::AnswersController < Api::V1::BaseController
  before_action :find_question, only: %i[index create]
  before_action :find_answer, only: %i[show update destroy]

  authorize_resource

  def index
    @answers = @question.answers
    render json: @answers
  end

  def show
    render json: @answer
  end

  def create
    @answer = @question.answers.build(answer_params.merge(author_id: current_resource_owner.id))

    if @answer.save
      render json: { answer: @answer }, status: :created
    else
      render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/answers/:id
  def update
    if @answer.update(answer_params)
      render json: { answer: @answer }, status: :ok
    else
      render json: { errors: @answer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/answers/:id
  def destroy
    payload = ActiveModelSerializers::SerializableResource.new(@answer).as_json
    @answer.destroy
    render json: payload, status: :ok
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Question not found'] }, status: :not_found
  end

  def find_answer
    @answer = Answer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Answer not found'] }, status: :not_found
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
