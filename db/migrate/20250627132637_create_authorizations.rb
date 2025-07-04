class CreateAuthorizations < ActiveRecord::Migration[7.1]
  def change
    create_table :authorizations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :provider
      t.string :uid

      t.timestamps
    end

    add_index :authorizations, [:provider, :uid]
  end
end
