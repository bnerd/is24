require 'is24/logger'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/response/mashify'
require 'cgi'

module Is24
  class Api
    include Is24::Logger

    API_ENDPOINT = "http://rest.immobilienscout24.de/restapi/api/search/v1.0/"
    API_AUTHORIZATION_ENDPOINT = "http://rest.immobilienscout24.de/restapi/security/"

    def initialize( options = {} )
      logger "Initialized b'nerd IS24 with options #{options}"
      
      @token = options[:token] || nil
      @secret = options[:secret] || nil
      @consumer_secret = options[:consumer_secret] || nil
      @consumer_key = options[:consumer_key] || nil
      
      raise "Missing Credentials!" if @consumer_secret.nil? || @consumer_key.nil?
    end
    
    def request_token( callback_uri )
      # TODO error handling
      response = connection(:authorization, callback_uri).get("oauth/request_token")
      
      body = response.body.split('&')
      response = {
        :oauth_token => CGI::unescape(body[0].split("=")[1]),
        :oauth_token_secret => CGI::unescape(body[1].split("=")[1]),
        :redirect_uri => "http://rest.immobilienscout24.de/restapi/security/oauth/confirm_access?#{body[0]}"
      }
    end

    def request_access_token( params = {} )
      # TODO error handling
      @oauth_verifier = params[:oauth_verifier]
      @token = params[:oauth_token]
      @secret = params[:oauth_token_secret]

      response = connection(:authorization).get("oauth/access_token")
      puts response.inspect
      body = response.body.split('&')
      
      response = {
        :oauth_token => body[0].split('=')[1],
        :oauth_token_secret => CGI::unescape(body[1].split('=')[1]),
      }
      
      # set credentials in client
      @token = response[:oauth_token]
      @token_secret = response[:oauth_token_secret]
      
      # return access token and secret
      response
    end
    
    def search(options)
      defaults = {
        :channel => "hp",
        :realestatetype => "housebuy",
        :geocodes => 1276,
        :username => "me"    
      }
      options = defaults.merge(options)
      
      response = connection.get("search/region", options )
      response.body["resultlist.resultlist"]
    end
    
    def expose(id)
      response = connection.get("expose/#{id}")
      response.body["expose.expose"]
    end
    
    protected
    
    def connection(connection_type = :default, callback_uri = nil)
    
      # set request defaults
      defaults = {
        :url => API_ENDPOINT,
        :accept =>  'application/json',
        :headers => {
          :accept =>  'application/json',
          :user_agent => 'b\'nerd .media IS24 Ruby Client'}      
      }
      
      defaults.merge!( {
        :url => API_AUTHORIZATION_ENDPOINT
      } ) if connection_type =~ /authorization/i
      
      # define oauth credentials
      oauth = {
        :consumer_key => @consumer_key, 
        :consumer_secret => @consumer_secret, 
        :token => @token, 
        :token_secret => @secret
      }
      
      # merge callback_uri if present
      oauth.merge!( {
        :callback => callback_uri
      } ) if connection_type =~ /authorization/i && callback_uri
      
      # merge verifier if present
      oauth.merge!( {
        :verifier => @oauth_verifier
      } ) if connection_type =~ /authorization/i && @oauth_verifier
      
      Faraday::Connection.new( defaults ) do |builder|
            builder.request :oauth, oauth
            builder.response :mashify
            builder.response :json unless connection_type =~ /authorization/i
            builder.adapter Faraday.default_adapter
          end
    end
    
  end
end  
