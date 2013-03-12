require 'is24/logger'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/response/mashify'

module Is24
  class Api
    include Is24::Logger

    API_ENDPOINT = "http://rest.immobilienscout24.de/restapi/api/search/v1.0/"

    def initialize( options = {} )
      logger "Initialized Bnerd IS24 with options #{options}"
      
      @token = options[:token] || nil
      @secret = options[:secret] || nil
      @consumer_secret = options[:consumer_secret] || nil
      @consumer_key = options[:consumer_key] || nil
      
      raise "Invalid Credentials" if @secret.nil? || @token.nil?
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
    
    def connection
      Faraday::Connection.new(
        :url => API_ENDPOINT,
        :accept =>  'application/json',
        :headers => {
          :accept =>  'application/json',
          :user_agent => 'b\'nerd .media IS24 Ruby Client'} ) do |builder|
            builder.request :oauth, {
              :consumer_key => @consumer_key, 
              :consumer_secret => @consumer_secret, 
              :token => @token, 
              :token_secret => @secret
            }
            builder.response :mashify
            builder.response :json
            builder.adapter Faraday.default_adapter
          end
    end
  end
end  
