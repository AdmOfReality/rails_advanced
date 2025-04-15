require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 3, author: user) }

    before { get :index }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns new answer for question' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'assigns new answer for question' do
      expect(assigns(:answer).links.first).to be_a_new(Link)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before do
      login(user)
      get :new
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before do
      login(user)
      get :edit, params: { id: question }
    end

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'renders edit view' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new questions in the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:question, :invalid) } }.not_to change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    before { login(user) }

    context 'with valid attributes' do
      it 'assigns the requested questions to @question' do
        patch :update, params: { id: question, question: attributes_for(:question) }, format: :js
        expect(assigns(:question)).to eq question
      end

      it 'changes question attributes' do
        patch :update, params: { id: question, question: { title: 'new title', body: 'new body' } }, format: :js
        question.reload

        expect(question.title).to eq 'new title'
        expect(question.body).to eq 'new body'
      end

      it 'renders update template' do
        patch :update, params: { id: question, question: attributes_for(:question) }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      before { patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js }

      it 'does not change question' do
        question.reload

        expect(question.title).to eq 'MyString'
        expect(question.body).to eq 'MyText'
      end

      it 're-renders update template' do
        expect(response).to render_template :update
      end
    end
  end

  describe 'DELETE #destroy' do
    before { login(user) }

    let!(:question) { create(:question, author: user) }

    it 'delete the question' do
      expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: question }
      expect(response).to redirect_to questions_path
    end
  end

  describe 'DELETE #purge_attachment' do
    let!(:question) { create(:question, :with_files, author: user) }
    let(:attachment) { question.files.first }

    context 'when user is the author of the question' do
      before { login(user) }

      it 'deletes the attachment' do
        expect do
          delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        end.to change(question.files, :count).by(-1)
      end

      it 'returns a successful response' do
        delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        expect(response).to be_successful
      end
    end

    context 'when user is not the author of the question' do
      let(:other_user) { create(:user) }

      before { login(other_user) }

      it 'does not delete the attachment' do
        expect do
          delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        end.not_to change(question.files, :count)
      end

      it 'returns a forbidden status' do
        delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is not authenticated' do
      it 'does not delete the attachment' do
        expect do
          delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        end.not_to change(question.files, :count)
      end

      it 'returns an unauthorized status' do
        delete :purge_attachment, params: { id: question, attachment_id: attachment.id }, format: :js
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
