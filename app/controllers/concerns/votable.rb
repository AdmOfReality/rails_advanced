module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def rating
    votes.sum(:value)
  end

  def vote_by(user)
    votes.find_by(user: user)
  end

  def voted_by?(user)
    votes.exists?(user: user)
  end
end
