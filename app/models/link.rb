class Link < ApplicationRecord
  VALID_URL_REGEXP = /\A(http|https):\/\/[^\s]+\z/i

  belongs_to :linkable, polymorphic: true

  validates :name, presence: true
  validates :url, presence: true, format: {
    with: VALID_URL_REGEXP,
    message: 'must be valid (start with http:// or https://)'
  }

  def gist?
    url.include?('gist.github.com')
  end

  def gist_id
    url.split('/').last if gist?
  end
end
