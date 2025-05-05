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
    rating = @votable.cancel_vote!(current_user)
    render json: { rating: rating }
  rescue Votable::VoteNotFoundError => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
  render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  private

  def process_vote(value)
    rating = @votable.vote!(current_user, value)
    render json: { rating: rating }
  rescue Votable::AlreadyVotedError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  def find_votable
    klass = params[:votable_type].classify.safe_constantize
    @votable = klass&.find_by(id: params[:votable_id])
    render json: { error: 'Votable not found' }, status: :not_found unless @votable
  end

  def ensure_not_author
    return unless current_user.author_of?(@votable)

    render json: { error: 'You cannot vote for your own content' }, status: :forbidden
  end
end
