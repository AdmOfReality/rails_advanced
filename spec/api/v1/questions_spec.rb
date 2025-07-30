require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'when authorized!' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token) }
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_response) { json['questions'].first }
      let!(:answers) { create_list(:answer, 3, question: question, author: user) }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Status OK'

      it 'returns list of questions' do
        expect(json['questions'].size).to eq 2
      end

      it_behaves_like 'Return public fields' do
        let(:fields) { %w[id title body created_at updated_at] }
        let(:resource_response) { question_response }
        let(:resource) { question }
      end

      it 'contains author object' do
        expect(question_response['author']['id']).to eq question.author.id
      end

      it 'contains short title' do
        expect(question_response['short_title']).to eq question.title.truncate(7)
      end

      describe 'answers' do
        let(:answer) { answers.first }
        let(:answer_response) { question_response['answers'].first }

        it 'returns list of answers' do
          expect(question_response['answers'].size).to eq 3
        end

        it_behaves_like 'Return public fields' do
          let(:fields) { %w[id author_id body created_at updated_at] }
          let(:resource_response) { answer_response }
          let(:resource) { answer }
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:user)          { create(:user) }
    let!(:access_token)  { create(:access_token, resource_owner_id: user.id) }
    let!(:question)      { create(:question, :with_files, author: user) }
    let!(:link)          { create(:link, linkable: question) }
    let!(:comment)       { create(:comment, commentable: question, user: user) }

    let(:api_path)       { "/api/v1/questions/#{question.id}" }
    let(:question_json)  { json['question'] }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'when authorized' do
      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it_behaves_like 'Status OK'

      it_behaves_like 'Return public fields' do
        let(:fields) { %w[id title body created_at updated_at] }
        let(:resource_response) { question_json }
        let(:resource) { question }
      end

      it 'returns files as URLs' do
        expected_urls = question.files.map do |f|
          Rails.application.routes.url_helpers.rails_blob_url(f, only_path: false)
        end
        expect(question_json['files']).to match_array expected_urls
      end

      it 'returns list of links' do
        expect(question_json['links'].size).to eq 1

        link_json = question_json['links'].first
        expect(link_json['id']).to eq link.id
        expect(link_json['name']).to eq link.name
        expect(link_json['url']).to  eq link.url
      end

      it 'returns list of comments with nested user' do
        expect(question_json['comments'].size).to eq 1

        comment_json = question_json['comments'].first
        expect(comment_json['id']).to         eq comment.id
        expect(comment_json['body']).to       eq comment.body
        expect(comment_json['created_at']).to eq comment.created_at.as_json
        expect(comment_json['updated_at']).to eq comment.updated_at.as_json

        user_json = comment_json['user']
        expect(user_json['id']).to eq user.id
      end
    end
  end

  describe 'POST /api/v1/questions' do
    let(:method)       { :post }
    let(:api_path)     { '/api/v1/questions' }
    let(:valid_params) { { question: { title: 'API title', body: 'API body' } } }
    let(:invalid_params) { { question: { title: '', body: '' } } }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      let(:access_token) { create(:access_token) }

      before do
        post api_path,
             params: valid_params.merge(access_token: access_token.token),
             headers: headers,
             as: :json
      end

      it 'creates question (201) and returns its JSON' do
        expect(response.status).to eq 201
        expect(Question.count).to eq 1
        expect(json['question']['title']).to eq 'API title'
        expect(json['question']['body']).to  eq 'API body'
      end

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id title body created_at updated_at] }
        let(:resource_response) { json['question'] }
        let(:resource)          { Question.last }
      end

      context 'with invalid params' do
        before do
          post api_path,
               params: invalid_params.merge(access_token: access_token.token),
               headers: headers,
               as: :json
        end

        it 'returns 422 and error messages' do
          expect(response.status).to eq 422
          expect(json['errors']).to be_present
        end
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:method)        { :patch }
    let!(:user)         { create(:user) }
    let!(:question)     { create(:question, author: user, title: 'Old', body: 'Old') }
    let(:api_path)      { "/api/v1/questions/#{question.id}" }
    let(:update_params) { { question: { title: 'New', body: 'NewBody' } } }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      before do
        patch api_path,
              params: update_params.merge(access_token: access_token.token),
              headers: headers,
              as: :json
        question.reload
      end

      it 'updates question (200) and returns JSON' do
        expect(response.status).to eq 200
        expect(question.title).to eq 'New'
        expect(question.body).to  eq 'NewBody'
        expect(json['question']['title']).to eq 'New'
        expect(json['question']['body']).to  eq 'NewBody'
      end

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id title body created_at updated_at] }
        let(:resource_response) { json['question'] }
        let(:resource)          { question }
      end

      context 'with invalid params' do
        before do
          patch api_path,
                params: { question: { title: nil } }
                  .merge(access_token: access_token.token),
                headers: headers,
                as: :json
        end

        it 'returns 422 and error messages' do
          expect(response.status).to eq 422
          expect(json['errors']).to be_present
        end
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:method)   { :delete }
    let!(:user)    { create(:user) }
    let!(:question) { create(:question, author: user, title: 'X', body: 'Y') }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      it 'deletes question (200) and returns deleted JSON' do
        expect do
          delete api_path,
                 params: { access_token: access_token.token },
                 headers: headers,
                 as: :json
        end.to change(Question, :count).by(-1)

        expect(response.status).to eq 200
        expect(json['question']['id']).to eq question.id
      end
    end
  end
end
