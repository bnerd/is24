# encoding: UTF-8

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

    # TODO move in separate module
    MARKETING_TYPES = {
      "PURCHASE" => "Kauf",
      "PURCHASE_PER_SQM" => "Kaufpreis/ Quadratmeter",
      "RENT" => "Miete",
      "RENT_PER_SQM" => "Mietpreis/ Quadratmeter",
      "LEASE" => "Leasing",
      "LEASEHOLD" => "",
      "BUDGET_RENT" => "",
      "RENT_AND_BUY" => ""
    }

    PRICE_INTERVAL_TYPES = {
      "DAY" => "Tag",
      "WEEK" => "Woche",
      "MONTH" => "Monat",
      "YEAR" => "Jahr",
      "ONE_TIME_CHARGE" => "einmalig"
    }

    REAL_ESTATE_TYPES = {
      "APARTMENT_RENT" => "Wohnung Miete",
      "APARTMENT_BUY" => "Wohnung Kauf",
      "HOUSE_RENT" => "Haus Miete",
      "HOUSE_BUY" => "Haus Kauf",
      "GARAGE_RENT" => "Garage / Stellplatz Miete",
      "GARAGE_BUY" => "Garage / Stellplatz Kauf",
      "LIVING_RENT_SITE" => "Grundstück Wohnen Miete",
      "LIVING_BUY_SITE" => "Grundstück Wohnen Kauf",
      "TRADE_SITE" => "Grundstück Gewerbe",
      "HOUSE_TYPE" => "Typenhäuser",
      "FLAT_SHARE_ROOM" => "WG-Zimmer",
      "SENIOR_CARE" => "Altenpflege",
      "ASSISTED_LIVING" => "Betreutes Wohnen",
      "OFFICE" => "Büro / Praxis",
      "INDUSTRY" => "Hallen / Produktion",
      "STORE" => "Einzelhandel",
      "GASTRONOMY" => "Gastronomie / Hotel",
      "SPECIAL_PURPOSE" => "",
      "INVESTMENT" => "Gewerbeprojekte",
      "COMPULSORY_AUCTION" => "",
      "SHORT_TERM_ACCOMMODATION" => ""
    }

    # transforms, eg.
    # "SPECIAL_PURPOSE" => ""
    # to
    # "search:SpecialPurpose" => ""
    XSI_SEARCH_TYPES = lambda {
      return Hash[*REAL_ESTATE_TYPES.map{ |v|
          [
            "search:"+v.first.downcase.split("_").map!(&:capitalize).join,
            v[1]
          ]
        }.flatten
      ]
    }.()

    def self.format_marketing_type(marketing_type)
      MARKETING_TYPES[marketing_type] || ""
    end    

    def self.format_price_interval_type(price_interval_type)
      PRICE_INTERVAL_TYPES[price_interval_type] || ""
    end 

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
        :realestatetype => ["housebuy"],
        :geocodes => 1276,
        :username => "me"    
      }
      options = defaults.merge(options)
      types = options[:realestatetype]

      case types
        when String
          types = [types]
      end

      objects = []

      types.each do |type|
        options[:realestatetype] = type
        response = connection.get("search/region", options )
        if response.status == 200
          if response.body["resultlist.resultlist"].resultlistEntries[0]['@numberOfHits'] == "0"
            response.body["resultlist.resultlist"].resultlistEntries[0].resultlistEntries = []
          end
          objects.push response.body["resultlist.resultlist"].resultlistEntries[0]
        end
      end

      objects
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
