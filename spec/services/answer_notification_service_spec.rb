require 'rails_helper'

RSpec.describe AnswerNotificationService do
  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:question) { create(:question, author: author) }
  let(:answer) { create(:answer, question: question, author: user) }

  it 'sends notify to author of question' do
    expect(AnswerNotificationMailer).to receive(:notify).with(author, answer).and_call_original
    subject.send_notify(answer)
  end
end
