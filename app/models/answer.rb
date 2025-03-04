class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :author, class_name: 'User'

  validates :body, presence: true

  def best_answer
    Answer.where(question_id: self.question_id).update_all(best: false)
    update(best: true)
  end
end
