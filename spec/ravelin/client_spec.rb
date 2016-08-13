require 'spec_helper'

describe Ravelin::Client do
  describe '#initialize' do
    it 'initializes a Faraday connection' do
      expect(Faraday).to receive(:new).
        with('https://api.ravelin.com', kind_of(Hash))

      described_class.new(api_key: 'abc')
    end
  end

  shared_context 'event setup and stubbing' do
    let(:client) { described_class.new(api_key: 'abc') }
    let(:event_name) { 'foobar' }
    let(:event_payload) { { id: 'ch-123' } }
    let(:event) do
      double('event', name: event_name, serializable_hash: event_payload)
    end

    before { allow(client).to receive(:post) }
  end

  describe '#send_entity' do
    let(:client) { described_class.new(api_key: 'abc') }
    let(:entity) { Ravelin::Customer.new(customer_id: "id") }

    it 'posts with the correct url and data' do
      expect(client).to receive(:post).with("/v2/customer", { "customerId" => "id" })

      client.send_entity entity: entity
    end

    it 'calls #post with Event payload and score: true' do
      expect(client).to receive(:post).with("/v2/customer?score=true", { 'customerId' => 'id' })

      client.send_entity(entity: entity, score: true)
    end

    it 'requests backfill' do
      expect(client).to receive(:post).with("/v2/backfill/customer", { "customerId" => "id" })

      client.send_entity(entity: entity, backfill: true)
    end

    it 'raises when backfill and score are requested' do
      expect {
        client.send_entity(entity: entity, backfill: true, score: true)
      }.to raise_error(ArgumentError)
    end
  end

  describe '#post' do
    let(:client) { described_class.new(api_key: 'abc') }
    let(:event) do
      double('event', name: 'ping', serializable_hash: { name: 'value' })
    end

    before do
      # allow(Ravelin::Event).to receive(:new).and_return(event)
    end

    it 'calls Ravelin with correct headers and body' do
      stub = stub_request(:post, 'https://api.ravelin.com/v2/ping').
        with(
          headers: { 'Authorization' => 'token abc' },
          body: { name: 'value' }.to_json,
        ).and_return(
          headers: { 'Content-Type' => 'application/json' },
          body: '{}'
        )

      client.send_event

      expect(stub).to have_been_requested
    end

    context 'response' do
      before do
        stub_request(:post, 'https://api.ravelin.com/v2/ping').
          to_return(
            status: response_status,
            body: body
          )
      end

      context 'successful' do
        shared_examples 'successful request' do
          it 'returns the response' do
            expect(client.send_event).to be_a(Ravelin::Response)
          end

          it "not treated as an error" do
            expect(client).to_not receive(:handle_error_response)

            client.send_event
          end
        end

        context 'when the response code is 200' do
          let(:response_status) { 200 }
          let(:body) { '{}' }
          it_behaves_like 'successful request'
        end

        context 'when the response code is 200' do
          let(:response_status) { 204 }
          let(:body) { '' }
          it_behaves_like 'successful request'
        end
      end

      context 'error' do
        let(:response_status) { 400 }
        let(:body) { '{}' }
        
        it 'handles error response' do
          expect(client).to receive(:handle_error_response).
            with(kind_of(Faraday::Response))

          client.send_event
        end
      end
    end
  end

  describe '#handle_error_response' do
    shared_examples 'raises error with' do |error_class|
      it "raises #{error_class} error" do
        expect { client.send_event }.to raise_exception(error_class)
      end
    end

    let(:event) { double('event', name: :ping, serializable_hash: {}) }
    let(:client) { described_class.new(api_key: 'abc') }

    before do
      # allow(Ravelin::Event).to receive(:new).and_return(event)
      stub_request(:post, 'https://api.ravelin.com/v2/ping').
        and_return(status: status_code, body: "{}")
    end

    context 'HTTP status 400' do
      let(:status_code) { 400 }
      include_examples 'raises error with', Ravelin::InvalidRequestError
    end

    context 'HTTP status 403' do
      let(:status_code) { 403 }
      include_examples 'raises error with', Ravelin::InvalidRequestError
    end

    context 'HTTP status 404' do
      let(:status_code) { 404 }
      include_examples 'raises error with', Ravelin::InvalidRequestError
    end

    context 'HTTP status 405' do
      let(:status_code) { 405 }
      include_examples 'raises error with', Ravelin::InvalidRequestError
    end

    context 'HTTP status 406' do
      let(:status_code) { 406 }
      include_examples 'raises error with', Ravelin::InvalidRequestError
    end

    context 'HTTP status 401' do
      let(:status_code) { 401 }
      include_examples 'raises error with', Ravelin::AuthenticationError
    end

    context 'HTTP status 429' do
      let(:status_code) { 429 }
      include_examples 'raises error with', Ravelin::RateLimitError
    end

    context 'HTTP status 500' do
      let(:status_code) { 500 }
      include_examples 'raises error with', Ravelin::ApiError
    end
  end
end
