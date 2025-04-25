module Votable
  extend ActiveSupport::Concern

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

    return { error: 'Already voted this way' } if existing_vote&.value == value

    transaction do
      existing_vote&.destroy
      votes.create!(user: user, value: value)
    end

    { rating: rating }
  rescue => e
    { error: e.message }
  end

  def cancel_vote!(user)
    vote = vote_by(user)

    if vote&.destroy
      { rating: rating }
    else
      { error: "Vote not found or couldn't be deleted" }
    end
  end
end
