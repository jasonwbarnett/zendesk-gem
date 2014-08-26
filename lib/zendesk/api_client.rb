require "httparty"
require "zendesk"
require "zendesk/api_error"
require "zendesk/users"

module Zendesk
  class ApiClient
    include HTTParty
    format :json

    attr_reader :username
    attr_accessor :users, :next_page, :previous_page, :count

    def initialize(options = {})
      @username   = options[:username] || Zendesk.config[:username]
      @token      = options[:token]    || Zendesk.config[:token]
      password    = options[:password] || Zendesk.config[:password]
      auth_token  = password || @token
      @username  += "/token" if auth_token == @token

      self.class.base_uri(zendesk_url(options) + '/api/v2')
      # This makes it so that every request uses basic auth
      self.class.basic_auth(@username, auth_token)
      # Sets the headers for every response
      self.class.headers({'Content-Type' => 'application/json', 'Accept' => 'application/json'})

      fail "Missing required options: :username"           unless @username
      fail "Missing required options: :password or :token" unless password || @token
    end

    def users
      @users ||= get_users
    end

    private
    def get_users
      uri = '/users.json'
      res = self.class.get(uri)
      parsed_response = raise_or_return(res)
      users = parsed_response['users']
      #set_common_params(parsed_response)
      users = Zendesk::Users.new(parsed_response)
      #all = users.inject([]) do |memo, x|
      #  user =  Zendesk::User.new(x)
      #  user.set_id(x['id'])
      #  memo << user
      #  memo
      #end
    end

    def raise_or_return(result)
      response_code = result.response.code.to_i
      case response_code
        when 200...300
          result.parsed_response
        else
          raise Zendesk::ApiError.new(result.parsed_response)
      end
    end

    def zendesk_url(options)
      options[:url] || Zendesk.config[:url] || form_zendesk_url(options)
    end

    def form_zendesk_url(options)
      host      = options[:host]
      subdomain = options[:subdomain] || Zendesk.config[:subdomain]

      host ||= "#{subdomain}.zendesk.com"
      scheme = options[:scheme] || "https"
      port   = options[:port] || (scheme == "https" ? 443 : 80)

      "#{scheme}://#{host}:#{port}"
    end
  end
end
