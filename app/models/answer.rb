class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :author, class_name: 'User'
  has_many :links, dependent: :destroy, as: :linkable

  has_many_attached :files

  validates :body, presence: true

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank

  def mark_best_answer!
    Answer.where(question_id: question_id).update_all(best: false)
    update(best: true)
  end
end
