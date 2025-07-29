class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at, :updated_at, :short_title, :files

  has_many :answers
  has_many :links
  has_many :comments

  belongs_to :author

  def short_title
    object.title.truncate(7)
  end

  def files
    object.files.map do |file|
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
    end
  end
end
