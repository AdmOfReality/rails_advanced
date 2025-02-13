class AddAuthorReferencesToQuestionsAndAnswers < ActiveRecord::Migration[7.1]
  def change
    add_reference :questions, :author, foreign_key: { to_table: :users }
    add_reference :answers, :author, foreign_key: { to_table: :users }
  end
end
