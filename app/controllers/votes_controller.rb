class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_votable
  before_action :ensure_not_author

  def upvote
    vote(+1)
  end

  def downvote
    vote(-1)
  end

  def cancel
    vote = @votable.vote_by(current_user)

    if vote&.destroy
      render_rating
    else
      render json: { error: "Vote not found or couldn't be deleted" }, status: :unprocessable_entity
    end
  end

  private

  def vote(value)
    existing_vote = @votable.vote_by(current_user)

    if existing_vote&.value == value
      render json: { error: "You have already voted this way" }, status: :unprocessable_entity
    else
      existing_vote&.destroy
      new_vote = @votable.votes.build(user: current_user, value: value)

      if new_vote.save
        render_rating
      else
        render json: { error: new_vote.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end
  end

  def render_rating
    render json: { rating: @votable.rating }
  end

  def find_votable
    klass = params[:votable_type].classify.safe_constantize
    if klass.present?
      @votable = klass.find_by(id: params[:votable_id])
    end

    unless @votable
      render json: { error: "Votable not found" }, status: :not_found
    end
  end

  def ensure_not_author
    if current_user.author_of?(@votable)
      render json: { error: "You cannot vote for your own content" }, status: :forbidden
    end
  end
end
