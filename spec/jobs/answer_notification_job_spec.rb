require 'rails_helper'

RSpec.describe AnswerNotificationJob, type: :job do
  let(:users)    { create_list(:user, 2) }
  let(:question) { create(:question, author: users.first) }
  let(:answer)   { create(:answer, question: question, author: users.last) }

  let(:service) { instance_double(AnswerNotificationService) }

  before do
    allow(AnswerNotificationService).to receive(:new).and_return(service)
  end

  it 'delegates to AnswerNotificationService#send_notify' do
    expect(service).to receive(:send_notify).with(answer)
    described_class.perform_now(answer)
  end

  it 'enqueues on the default queue with the answer' do
    expect {
      described_class.perform_later(answer)
    }.to have_enqueued_job(described_class).with(answer).on_queue('default')
  end
end
