require 'rails_helper'

RSpec.describe AnswerNotificationMailer, type: :mailer do
  describe 'notify' do
    let(:author)     { create(:user) }
    let(:subscriber) { create(:user) }
    let(:answerer)   { create(:user) }
    let(:question)   { create(:question, author: author) }
    let(:answer)     { create(:answer, question: question, author: answerer) }

    let(:mail) { described_class.notify(subscriber, answer) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Notify: Your have new answer from #{question.title}")
      expect(mail.to).to eq([subscriber.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(answer.body)
    end
  end
end
