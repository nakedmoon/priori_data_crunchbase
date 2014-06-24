module Crunchbase
  module Utils
    class ApiRequest

      attr_accessor :response

      def initialize(url, headers, url_params = {})
        uri = URI.parse(url)
        uri.query = URI.encode_www_form(url_params)
        @response = Net::HTTP.get_response(uri)
      end

    end


  end
end