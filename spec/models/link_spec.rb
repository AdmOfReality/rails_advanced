require 'rails_helper'

RSpec.describe Link, type: :model do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:gist_link) { build(:link, url: 'https://gist.github.com/user/12345', linkable: question) }
  let(:regular_link) { build(:link, url: 'https://google.com', linkable: question) }

  it { should belong_to :linkable }
  it { should validate_presence_of :name }
  it { should validate_presence_of :url }

  describe 'URL format validation' do
    it 'allows valid URLs' do
      valid_urls = [
        'http://example.com',
        'https://example.com',
        'https://sub.domain.com/path?query=1'
      ]

      valid_urls.each do |url|
        link = build(:link, name: "Valid Link", url: url, linkable: question)
        expect(link).to be_valid, "#{url} should be valid"
      end
    end

    it 'rejects invalid URLs' do
      invalid_urls = [
        'ftp://example.com',
        'example.com',
        'http:/example.com',
        'https//example.com',
        'just-text'
      ]

      invalid_urls.each do |url|
        link = build(:link, name: "Invalid Link", url: url, linkable: question)
        expect(link).to be_invalid, "#{url} should be invalid"
        expect(link.errors[:url]).to include('must be valid (start with http:// or https://)')
      end
    end
  end

  describe '#gist?' do
    it 'returns true for gist links' do
      expect(gist_link.gist?).to be true
    end

    it 'returns false for regular links' do
      expect(regular_link.gist?).to be false
    end
  end

  describe '#gist_id' do
    it 'returns gist id' do
      expect(gist_link.gist_id).to eq '12345'
    end

    it 'returns nil for non-gist links' do
      expect(regular_link.gist_id).to be_nil
    end
  end
end
