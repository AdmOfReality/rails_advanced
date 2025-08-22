require 'rails_helper'

RSpec.describe AnswerNotificationService do
  subject(:service) { described_class.new }

  let(:author)   { create(:user) }
  let(:answerer) { create(:user) }
  let(:other)    { create(:user) }

  let(:question) { create(:question, author: author) }
  let(:answer)   { create(:answer, question: question, author: answerer) }

  let(:message_delivery) do
    instance_double(ActionMailer::MessageDelivery, deliver_later: true)
  end

  before do
    create(:subscription, user: author,   question: question)
    create(:subscription, user: other,    question: question)
    create(:subscription, user: answerer, question: question)

    allow(AnswerNotificationMailer).to receive(:notify).and_return(message_delivery)
  end

  it 'notifies all subscribers except the answer author' do
    service.send_notify(answer)

    expect(AnswerNotificationMailer)
      .to have_received(:notify).with(author, answer).once
    expect(AnswerNotificationMailer)
      .to have_received(:notify).with(other, answer).once
    expect(AnswerNotificationMailer)
      .not_to have_received(:notify).with(answerer, answer)
  end

  it 'delivers mails asynchronously via deliver_later for each delivered notification' do
    service.send_notify(answer)

    expect(message_delivery).to have_received(:deliver_later).twice
  end
end
