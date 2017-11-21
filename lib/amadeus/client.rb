# require 'net/https'
# require 'json'
require 'logger'

module Amadeus
  # The Amadeus client library for accessing
  # the travel APIs.
  class Client
    # The API key used to authenticate against the API
    attr_reader :api_key
    # The API secret used to authenticate against the API
    attr_reader :api_secret
    # The logger used to output warnings and debug messages
    attr_reader :logger

    # Initialize using your credentials:
    #
    #   amadeus = Amadeus::Client.new(
    #     api_key:    'YOUR_API_KEY',
    #     api_secret: 'YOUR_API_SECRET'
    #   )
    #
    # Alternatively, initialize the library using
    # the environment variables +AMADEUS_API_KEY+
    # and +AMADEUS_API_SECRET+
    #
    #   amadeus = Amadeus::Client.new
    def initialize(options = {})
      @api_key = initialize_required(:api_key, options)
      @api_secret = initialize_required(:api_secret, options)
      @logger = initialize_logger(options)
      @logger.level = initialize_optional(:log_level, options, Logger::WARN)
    end

    # The namespace for the checkin links and locations APIs:
    #
    #   amadeus.reference_data.urls.checkin_links
    #   amadeus.reference_data.locations
    #
    def reference_data
      Amadeus::Client::ReferenceData.new(self)
    end

    # The namespace for the shopping APIs:
    #
    #   amadeus.shopping.flight_destinations
    #   amadeus.shopping.flight_offers
    #   amadeus.shopping.flight_dates
    #   amadeus.shopping.hotel_offers
    #   amadeus.shopping.hotels
    #
    def shopping
      Amadeus::Client::Shopping.new(self)
    end

    # The namespace for the travel analytics APIs:
    #
    #   amadeus.travel.analytics.air_traffics
    #   amadeus.travel.analytics.fare_searches
    #
    def travel
      Amadeus::Client::Travel.new(self)
    end

    private

    # Tries to find a required option by string, symbol,
    # or environment variable.
    #
    # If it can not find any, it raises an +ArgumentError+
    def initialize_required(key, options)
      initialize_optional(key, options) ||
        raise(ArgumentError, "Missing required argument: #{key}")
    end

    # Tries to find an option option by string, symbol,
    # and when it can not find it defaults to the provided
    # default option.
    def initialize_optional(key, options, default = nil)
      options[key] ||
        options[key.to_s] ||
        ENV["AMADEUS_#{key.to_s.upcase}"] ||
        default
    end

    def initialize_logger(options)
      options[:logger] || options['logger'] || Logger.new(STDOUT)
    end
  end
end
