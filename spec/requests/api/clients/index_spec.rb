require 'rails_helper'
RSpec.describe 'Client index', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:regular_client) { create(:client) }
  let(:passed_client) { create(:client) }

  before do
    create(:client_counter, client: regular_client)
    create(:client_counter, client: passed_client)
    create(:client_counter, client: regular_client)
  end

  context '?loyalty=all' do
    it '&loyalty_days=7&page=1&sort_field=updated_at&updated_at=asc&visits=desc&visits30=asc' do
      get my_uri('clients/?loyalty=all&loyalty_days=7&page=1&sort_field=updated_at&updated_at=asc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients.size).to eq 2
    end
  end

  context '?loyalty=regular' do
    it '&loyalty_days=7&page=1&sort_field=visits30&updated_at=desc&visits=desc&visits30=asc' do
      get my_uri('clients/?loyalty=regular&loyalty_days=7&page=1&sort_field=visits30&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients.size).to eq 1
    end
  end

  context '?loyalty=passed' do
    it '&loyalty_days=7&page=1&sort_field=visits&updated_at=desc&visits=desc&visits30=asc' do
      get my_uri('clients/?loyalty=passed&loyalty_days=7&page=1&sort_field=visits&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients.size).to eq 1
    end

    it 'considers loyalty days' do
      create(:client_counter, client: passed_client, created_at: 8.days.ago, updated_at: 8.days.ago)
      get my_uri('clients/?loyalty=passed&loyalty_days=7&page=1&sort_field=visits&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients.size).to eq 1
    end
  end

  context 'order' do
    it 'order by updated_at' do
      get my_uri('clients/?loyalty=all&loyalty_days=7&page=1&sort_field=visits&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients[0][:visits]).to be >= clients[1][:visits]
    end

    it 'order by visits' do
      get my_uri('clients/?loyalty=all&loyalty_days=7&page=1&sort_field=updated_at&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      clients = parsed_response[:data][:clients]
      expect(clients[0][:updated_at]).to be > clients[1][:updated_at]
    end

    it 'order by visits30' do
      create(:client_counter, created_at: 32.days.ago, updated_at: 32.days.ago)
      get my_uri('clients/?loyalty=all&loyalty_days=7&page=1&sort_field=visits30&updated_at=desc&visits=desc&visits30=asc'),
          headers: { 'Authorization' => token(admin) }
      expect(parsed_response[:data][:clients][0][:visits30]).to eq 0
    end
  end
end
