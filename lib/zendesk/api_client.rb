require "httparty"
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
    end

    def users
      @last_result = get_users
    end

    private
    def get_page(x)
      klass = @last_result.class
      next_page_uri, options = zendesk_page_parser(@last_result[x])
      return nil if next_page_uri.nil?

      res = self.class.get(next_page_uri, options)
      parsed_response = raise_or_return(res)

      @last_result = klass.new(parsed_response)
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
