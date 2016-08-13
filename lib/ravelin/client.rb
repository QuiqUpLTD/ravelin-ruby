module Ravelin
  class Client
    API_BASE = 'https://api.ravelin.com'
    API_VERSION = 'v2'
    API_BACKFILL = 'backfill'

    def initialize(api_key:)
      @api_key = api_key

      @connection = Faraday.new(API_BASE, faraday_options) do |conn|
        conn.response :json, context_type: /\bjson$/
        conn.adapter Ravelin.faraday_adapter
      end
    end

    ##
    # send_event and send_backfill_event combined into one method.
    # +entity+ - Ravelin::RavelinObject derived class, eg Customer
    # +backfill+ - if the request is a backfill event
    # +score+ - if a score should be requested
    def send_entity(entity:, backfill: false, score: false)
      raise ArgumentError, 'Cannot Backfill and Score in same request' if backfill && score

      url = ['',
        API_VERSION,
        backfill ? API_BACKFILL : nil,
        entity.event_name,
      ].compact.join('/') + score_param(score)

      post(url, entity.serializable_hash)
    end

    private

    attr_reader :connection

    def post(url, payload)
      response = connection.post(url, payload.to_json)

      if response.success?
        return Response.new(response)
      else
        handle_error_response(response)
      end
    end

    def handle_error_response(response)
      case response.status
      when 400, 403, 404, 405, 406
        raise InvalidRequestError.new(response)
      when 401
        raise AuthenticationError.new(response)
      when 429
        raise RateLimitError.new(response)
      else
        raise ApiError.new(response)
      end
    end

    def faraday_options
      {
        request: { timeout: Ravelin.faraday_timeout },
        headers: {
          'Authorization' => "token #{@api_key}",
          'Content-Type'  => 'application/json; charset=utf-8'.freeze,
          'User-Agent'    => "Ravelin RubyGem/#{Ravelin::VERSION}".freeze
        }
      }
    end

    def score_param(score)
      score ? "?score=true" : ''
    end
  end
end
