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
  after_create_commit :subscribe_user!

  private

  def enqueue_reputation_job
    ReputationJob.perform_later(self)
  end

  def subscribe_user!
    author.subscribe!(self)
  end
end
