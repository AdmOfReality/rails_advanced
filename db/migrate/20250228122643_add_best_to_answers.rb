class AddBestToAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :answers, :best, :boolean, null: false, default: false
  end
end
