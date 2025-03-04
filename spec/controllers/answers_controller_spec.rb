require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }

  before { login(user) }

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'assigns an author to the answer' do
        expect do
          post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js
        end.to change(user.answers, :count).by(1)
      end

      it 'assigns the answer to the correct question' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
        created_answer = Answer.last
        expect(created_answer.question).to eq question
      end

      it 'associates the created answer with the correct question' do
        expect do
          post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
        end.to change(question.answers, :count).by(1)
      end

      it 'renders create temlate' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        expect do
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
        end.not_to change(Answer, :count)
      end

      it 're-renders create temlate' do
        post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
        expect(response).to render_template :create
      end
    end
  end

  describe 'DESTROY #delete' do
    let!(:users) { create_list(:user, 2) }
    let!(:answer) { create(:answer, question: question, author: users.first) }

    context 'when author' do
      before { login(users.first) }

      it 'delete the answer' do
        expect do
          delete :destroy, params: { question_id: question, id: answer }, format: :js
        end.to change(Answer, :count).by(-1)
      end

      it 'renders destroy view' do
        delete :destroy, params: { id: answer, question_id: question }, format: :js
        expect(response).to render_template :destroy
      end
    end

    context 'when not author' do
      before { login(users.last) }

      it 'does not delete answer' do
        expect do
          delete :destroy, params: { question_id: question, id: answer }, format: :js
        end.not_to change(Answer, :count)
      end

      it 'returns forbidden status' do
        delete :destroy, params: { question_id: question, id: answer }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:answer) { create(:answer, question: question, author: user) }

    context 'with valid attributes' do
      it 'changes answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        expect(answer.reload.body).to eq 'new body'
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      it 'does not change answer attributes' do
        expect do
          patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        end.not_to change(answer, :body)
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'when not author' do
      let(:other_user) { create(:user) }

      before { login(other_user) }

      it 'does not update the answer' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        expect(answer.reload.body).not_to eq 'new body'
      end

      it 'returns forbidden status' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH #best' do
    let!(:answer) { create(:answer, question: question, author: user) }

    context 'when user is the author of the question' do
      it 'marks the answer as best' do
        patch :best, params: { id: answer }, format: :js
        expect(answer.reload.best).to be true
      end

      it 'renders best template' do
        patch :best, params: { id: answer }, format: :js
        expect(response).to render_template :best
      end
    end

    context 'when user is not the author of the question' do
      let(:other_user) { create(:user) }

      before { login(other_user) }

      it 'does not mark the answer as best' do
        patch :best, params: { id: answer }, format: :js
        expect(answer.reload.best).to be false
      end

      it 'returns forbidden status' do
        patch :best, params: { id: answer }, format: :js
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
