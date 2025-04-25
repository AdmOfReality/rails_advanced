class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_votable
  before_action :ensure_not_author

  def upvote
    process_vote(+1)
  end

  def downvote
    process_vote(-1)
  end

  def cancel
    result = @votable.cancel_vote!(current_user)
    render_result(result)
  end

  private

  def process_vote(value)
    result = @votable.vote!(current_user, value)
    render_result(result)
  end

  def render_result(result)
    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: { rating: result[:rating] }
    end
  end

  def find_votable
    klass = params[:votable_type].classify.safe_constantize
    @votable = klass&.find_by(id: params[:votable_id])
    render json: { error: 'Votable not found' }, status: :not_found unless @votable
  end

  def ensure_not_author
    if current_user.author_of?(@votable)
      render json: { error: 'You cannot vote for your own content' }, status: :forbidden
    end
  end
end
