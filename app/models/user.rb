class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :answers, foreign_key: 'author_id', dependent: :destroy, inverse_of: :author
  has_many :questions, foreign_key: 'author_id', dependent: :destroy, inverse_of: :author

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :rewards, dependent: :destroy

  def author_of?(object)
    object&.author_id == id
  end
end
