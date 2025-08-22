class Question < ApplicationRecord
  include Votable

  belongs_to :author, class_name: 'User'
  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_many :comments, as: :commentable, dependent: :destroy
  has_one :reward, dependent: :destroy

  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  has_many_attached :files

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, :body, presence: true

  after_commit :enqueue_reputation_job, on: :create

  def subscribed_of?(user)
    return false unless user

    user.subscriptions.exists?(question_id: id)
  end

  def subscribe!(user)
    user.subscriptions.find_or_create_by!(question: self)
  end

  def unsubscribe!(user)
    user.subscriptions.where(question: self).destroy_all
  end

  private

  def enqueue_reputation_job
    ReputationJob.perform_later(self)
  end
end
