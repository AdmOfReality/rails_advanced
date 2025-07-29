shared_examples_for 'API Authorizable' do
  context 'unauthorized' do
    it 'returns status: 401 if there is no access_token' do
      do_request(method, api_path, headers: headers)
      expect(response.status).to eq 401
    end

    it 'returns status: 401 if access_token is invalid' do
      do_request(method, api_path, params: { access_token: '1234' }, headers: headers)
      expect(response.status).to eq 401
    end
  end
end

shared_examples_for 'Status OK' do
  it 'returns 200 status' do
    expect(response).to be_successful
  end
end

shared_examples_for 'Return public fields' do
  it 'returns all public fields' do
    fields.each do |attr|
      if %w[created_at updated_at].include?(attr)
        timestamp = Time.iso8601(resource_response[attr])
        expect(timestamp).to be_within(1.second).of(resource.send(attr))
      else
        expect(resource_response[attr]).to eq resource.send(attr).as_json
      end
    end
  end
end
