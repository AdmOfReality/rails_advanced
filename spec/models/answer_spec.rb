require 'rails_helper'
require 'shared_examples/votable_spec'

RSpec.describe Answer, type: :model do
  it_behaves_like 'votable'

  it { should belong_to :question }
  it { should belong_to(:author).class_name('User') }
  it { should have_many(:links).dependent(:destroy) }

  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }

  it 'have many attached files' do
    expect(described_class.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  describe '#mark_best_answer!' do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let!(:answer1) { create(:answer, question: question, author: user) }
    let!(:answer2) { create(:answer, question: question, author: user) }

    context 'when marking an answer as best' do
      it 'marks the answer as best' do
        answer1.mark_best_answer!
        expect(answer1.reload.best).to be true
      end

      it 'unmarks the previous best answer' do
        answer1.mark_best_answer!
        answer2.mark_best_answer!
        expect(answer1.reload.best).to be false
        expect(answer2.reload.best).to be true
      end
    end
  end
end
