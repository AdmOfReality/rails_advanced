module Votable
  extend ActiveSupport::Concern

  class VoteError < StandardError; end
  class AlreadyVotedError < VoteError; end
  class VoteNotFoundError < VoteError; end

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def vote_by(user)
    votes.find_by(user: user)
  end

  def rating
    votes.sum(:value)
  end

  def vote!(user, value)
    existing_vote = vote_by(user)

    raise AlreadyVotedError, "User already voted with value #{value}" if existing_vote&.value == value

    transaction do
      existing_vote&.destroy
      votes.create!(user: user, value: value)
    end

    rating
  end

  def cancel_vote!(user)
    vote = vote_by(user)

    raise VoteNotFoundError, 'No vote found to cancel' unless vote

    vote.destroy!

    rating
  end
end
