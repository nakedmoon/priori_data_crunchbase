module Crunchbase
  module Actions
    module Fetch

      USER_KEY = '8f02ce81cc8970315d489ea2d2333c42'
      BASE_URL = 'http://api.crunchbase.com/v/2/'

      module ClassMethods


        def fetch(permalink)
          url_params = {}
          url_params['user_key'] = USER_KEY
          headers = {}
          url = File.join(BASE_URL, self.crunchbase_member_routing, permalink)
          request = Crunchbase::Utils::ApiRequest.new(url, headers, url_params)
          raise StandardError, request.response.code if request.response.code.to_i >400
          response = JSON.parse(request.response.body)
          error = response['data']['error']
          raise StandardError, error['message'] if error && error['code']>400
          return response
        end

        private :fetch # make private on inherited class
      end


      def self.included(host_class)
        host_class.extend(ClassMethods)
      end



    end
  end
end