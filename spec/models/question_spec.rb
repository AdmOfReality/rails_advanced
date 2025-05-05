require 'rails_helper'
require 'shared_examples/votable_spec'

RSpec.describe Question, type: :model do
  it_behaves_like 'votable'

  it { should have_many(:answers).dependent(:destroy) }
  it { should belong_to(:author).class_name('User') }
  it { should have_many(:links).dependent(:destroy) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }

  it 'have many attached files' do
    expect(described_class.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end
end
