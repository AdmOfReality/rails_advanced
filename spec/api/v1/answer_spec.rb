require 'rails_helper'

describe 'Answers API for Question', type: :request do
  let(:headers)         { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
  let(:user)            { create(:user) }
  let(:access_token)    { create(:access_token, resource_owner_id: user.id) }
  let!(:question)       { create(:question, author: user) }
  let!(:answers)        { create_list(:answer, 3, question: question, author: user) }

  describe 'GET /api/v1/questions/:question_id/answers' do
    let(:method)   { :get }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      before do
        get api_path,
            params: { access_token: access_token.token },
            headers: headers
      end

      it_behaves_like 'Status OK'

      it 'returns list of answers' do
        expect(json['answers'].size).to eq 3
      end

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id body author_id created_at updated_at] }
        let(:resource_response) { json['answers'].first }
        let(:resource)          { answers.first }
      end

      it 'returns attached files as URLs even if they empty' do
        expect(json['answers'].first['files']).to eq []
      end
    end
  end

  describe 'GET /api/v1/answers/:id' do
    let!(:answer)  { create(:answer, :with_file, question: question, author: user) }
    let!(:link)    { create(:link,    linkable: answer) }
    let!(:comment) { create(:comment, commentable: answer, user: user) }

    let(:method)   { :get }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      before do
        get api_path,
            params: { access_token: access_token.token },
            headers: headers
      end

      it_behaves_like 'Status OK'

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id body author_id created_at updated_at] }
        let(:resource_response) { json['answer'] }
        let(:resource)          { answer }
      end

      it 'returns attached files as URLs' do
        expected_urls = answer.files.map do |f|
          Rails.application.routes.url_helpers.rails_blob_url(f, only_path: false)
        end
        expect(json['answer']['files']).to match_array(expected_urls)
      end

      it 'returns list of links' do
        expect(json['answer']['links']).to contain_exactly(
          a_hash_including(
            'id' => link.id,
            'name' => link.name,
            'url' => link.url
          )
        )
      end

      it 'returns list of comments with nested user' do
        comment_json = json['answer']['comments'].first

        expect(comment_json['id']).to eq comment.id
        expect(comment_json['body']).to eq comment.body

        %w[created_at updated_at].each do |attr|
          parsed = Time.iso8601(comment_json[attr])
          expect(parsed).to be_within(1.second).of(comment.send(attr))
        end

        expect(comment_json['user']['id']).to eq user.id
      end
    end
  end

  describe 'POST /api/v1/questions/:question_id/answers' do
    let(:method)       { :post }
    let(:api_path)     { "/api/v1/questions/#{question.id}/answers" }
    let(:valid_params) { { answer: { body: 'New answer body' } } }
    let(:invalid_params) { { answer: { body: '' } } }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      before do
        post api_path,
             params: valid_params.merge(access_token: access_token.token),
             headers: headers,
             as: :json
      end

      it 'creates answer (201) and returns its JSON' do
        expect(response.status).to eq 201
        expect(question.answers.count).to eq 4
        expect(json['answer']['body']).to eq 'New answer body'
        expect(json['answer']['author_id']).to eq user.id
      end

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id body author_id created_at updated_at] }
        let(:resource_response) { json['answer'] }
        let(:resource)          { question.answers.last }
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

  describe 'PATCH /api/v1/answers/:id' do
    let!(:answer)       { create(:answer, question: question, author: user, body: 'Old body') }
    let(:method)        { :patch }
    let(:api_path)      { "/api/v1/answers/#{answer.id}" }
    let(:valid_params)  { { answer: { body: 'Updated body' } } }
    let(:invalid_params) { { answer: { body: '' } } }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      before do
        patch api_path,
              params: valid_params.merge(access_token: access_token.token),
              headers: headers,
              as: :json
        answer.reload
      end

      it 'updates answer (200) and returns JSON' do
        expect(response.status).to eq 200
        expect(answer.body).to eq 'Updated body'
        expect(json['answer']['body']).to eq 'Updated body'
      end

      it_behaves_like 'Return public fields' do
        let(:fields)            { %w[id body author_id created_at updated_at] }
        let(:resource_response) { json['answer'] }
        let(:resource)          { answer }
      end

      context 'with invalid params' do
        before do
          patch api_path,
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

  describe 'DELETE /api/v1/answers/:id' do
    let!(:answer)  { create(:answer, question: question, author: user) }
    let(:method)   { :delete }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable'

    context 'when authorized' do
      it 'deletes answer (200) and returns deleted JSON' do
        expect do
          delete api_path,
                 params: { access_token: access_token.token },
                 headers: headers,
                 as: :json
        end.to change(Answer, :count).by(-1)

        expect(response.status).to eq 200
        expect(json['answer']['id']).to eq answer.id
      end
    end
  end
end
