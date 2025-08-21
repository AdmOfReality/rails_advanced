require 'rails_helper'

RSpec.describe AnswerNotificationMailer, type: :mailer do
  describe 'notify' do
    let(:author) { create(:user) }
    let(:user) { create(:user) }
    let(:question) { create(:question, author: author) }
    let(:answer) { create(:answer, question: question, author: user) }
    let(:mail) { AnswerNotificationMailer.notify(user, answer) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Notify: Your have new answer from #{answer.question.title}")
      expect(mail.to).to eq([question.author.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(answer.body)
    end
  end
end
