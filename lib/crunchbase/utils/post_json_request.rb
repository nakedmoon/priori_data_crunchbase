module Crunchbase
  module Utils
    class PostJsonRequest

      attr_accessor :connection
      attr_accessor :request
      attr_accessor :response

      def initialize(url, headers, url_params = {}, spam_debug = false)
        headers['Content-Type'] = 'application/json'
        uri = URI.parse(url)
        params = URI.encode_www_form(url_params)
        @connection = Net::HTTP.new(uri.host, uri.port)
        @request = Net::HTTP::Post.new(uri.path, headers)
        @request.body = {params:params}.to_json
        @connection.set_debug_output $stdout if spam_debug
        @connection.read_timeout = 10
        @connection.open_timeout = 10
        @response = @connection.start{|http| http.request(@request)}
      end

    end


  end
end