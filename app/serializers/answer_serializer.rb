class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :updated_at, :files, :author_id

  has_many :links
  has_many :comments

  belongs_to :author
  belongs_to :question

  def files
    object.files.map do |file|
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
    end
  end
end
