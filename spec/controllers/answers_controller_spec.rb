require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }

  before { login(user) }

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'assigns an author to the answer' do
        expect do
          post :create, params: { answer: attributes_for(:answer), question_id: question }
        end.to change(user.answers, :count).by(1)
      end

      it 'assigns the answer to the correct question' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        created_answer = Answer.last
        expect(created_answer.question).to eq question
      end

      it 'associates the created answer with the correct question' do
        expect do
          post :create, params: { question_id: question, answer: attributes_for(:answer) }
        end.to change(question.answers, :count).by(1)
      end

      it 'redirects to question show view' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        expect(response).to redirect_to question_path(question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        expect do
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
        end.not_to change(Answer, :count)
      end

      it 're-renders show questions view with a form to create an answer' do
        post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
        expect(response).to render_template 'questions/show'
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
          delete :destroy, params: { question_id: question, id: answer }
        end.to change(Answer, :count).by(-1)
      end

      it 'redirects to question' do
        delete :destroy, params: { id: answer, question_id: question }
        expect(response).to redirect_to question_path(question)
      end
    end

    context 'when not author' do
      before { login(users.last) }

      it 'does not delete answer' do
        expect do
          delete :destroy, params: { question_id: question, id: answer }
        end.not_to change(Answer, :count)
      end

      it 'displays alert message' do
        delete :destroy, params: { question_id: question, id: answer }
        expect(flash[:alert]).to eq("You can't change someone else's answer.")
      end
    end
  end
end
