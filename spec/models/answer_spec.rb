require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to(:author).class_name('User') }

  it { should validate_presence_of :body }

  it 'have many attached files' do
    expect(described_class.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  describe '#best_answer' do
    let(:user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let!(:answer1) { create(:answer, question: question, author: user) }
    let!(:answer2) { create(:answer, question: question, author: user) }

    context 'when marking an answer as best' do
      it 'marks the answer as best' do
        answer1.best_answer
        expect(answer1.reload.best).to be true
      end

      it 'unmarks the previous best answer' do
        answer1.best_answer
        answer2.best_answer
        expect(answer1.reload.best).to be false
        expect(answer2.reload.best).to be true
      end
    end
  end
end
