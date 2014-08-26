require "httparty"
require "json"
require "zendesk"
require "zendesk/api_error"
require "zendesk/users"
require "zendesk/search"

module Zendesk
  class ApiClient
    include HTTParty
    format :json

    attr_reader :username
    attr_accessor :users, :next_page, :previous_page, :count
    attr_accessor :last_result

    def initialize(options = {})
      @username   = options[:username] || Zendesk.config[:username] || fail("Missing required options: :username")
      @token      = options[:token]    || Zendesk.config[:token]
      password    = options[:password] || Zendesk.config[:password]
      auth_token  = password || @token
      @username  += "/token" if auth_token == @token

      self.class.base_uri(zendesk_url(options) + '/api/v2')
      # This makes it so that every request uses basic auth
      self.class.basic_auth(@username, auth_token)
      # Sets the headers for every response
      self.class.headers({'Content-Type' => 'application/json', 'Accept' => 'application/json'})

      fail("Missing required options: :username")           unless @username
      fail("Missing required options: :password or :token") unless password || @token
    end

    def next_page
      get_page('next_page')
    end

    def previous_page
      get_page('previous_page')
    end

    def search(query)
      @last_result = get_search(query)
      @last_result = convert_search_results_to_klass(@last_result)
    end

    def users
      @last_result = get_users
    end

    def get_identities(user)
      fail("Expected a Zendesk::User, but received a #{user.class}.") unless Zendesk::User === user
      uri = "/users/#{user.id}/identities.json"

      res = self.class.get(uri)
      parsed_response = raise_or_return(res)

      user.identities = parsed_response['identities']
      user
    end

    alias :get_user_identities :get_identities

    def add_identity(user, identity)
      uri = "/users/#{user.id}/identities.json"

      identity_hash = identity.to_h
      body = {"identity" => identity_hash}
      body = JSON.dump(body) # Convert our request to json
      options = {body: body} # fill in our options, specific to httparty

      res = self.class.post(uri, options)
      parsed_response = raise_or_return(res)

      get_identities(user)
      Zendesk::Identity.new(parsed_response['identity'])
    end

    def delete_identity(identity)
      fail("Expected a Zendesk::Identity, but received a #{identity.class}.") unless Zendesk::Identity === identity
      fail("The Zendesk::Identity did not have an id")      unless identity.id
      fail("The Zendesk::Identity did not have an user_id") unless identity.user_id

      uri = "/users/#{identity.user_id}/identities/#{identity.id}.json"

      res = self.class.delete(uri)
      parsed_response = raise_or_return(res)
    end

    private
    def get_page(x)
      klass = @last_result.class
      next_page_uri, options = zendesk_page_parser(@last_result[x])
      return nil if next_page_uri.nil?

      res = self.class.get(next_page_uri, options)
      parsed_response = raise_or_return(res)

      @last_result = klass.new(parsed_response)
      @last_result = convert_search_results_to_klass(@last_result)
    end

    def convert_search_results_to_klass(last_result)
      return last_result unless Zendesk::Search === last_result

      last_result_hash = last_result.to_h

      last_result_hash[:results].map! do |x|
        case x['result_type']
          when 'user'
            x = Zendesk::User.new(x)
          else
            x
        end
      end

      last_result.results = last_result_hash[:results]
      last_result
    end

    def zendesk_page_parser(next_page)
      return [nil, nil] if next_page.nil?
      uri = URI(next_page)
      params = URI.decode_www_form(uri.query).to_h
      options = { query: params }


      base_path = URI(self.class.base_uri).path
      base_path_regexp = Regexp.escape(base_path)
      request_path = uri.path.sub(base_path_regexp, '')

      [request_path, options]
    end

    def get_search(query)
      uri = '/search.json'
      query = {'query' => query}
      @last_request_query = query
      options = {query: query}

      res = self.class.get(uri, options)
      parsed_response = raise_or_return(res)

      Zendesk::Search.new(parsed_response)
    end

    def get_users
      uri = '/users.json'
      query = nil
      @last_request_query = query

      res = self.class.get(uri)
      parsed_response = raise_or_return(res)

      Zendesk::Users.new(parsed_response)
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
