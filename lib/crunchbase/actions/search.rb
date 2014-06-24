module Crunchbase
  module Actions
    module Search

      SEARCH = {:url => 'http://search-3.crunchbase.com/1/indexes/main_production/query',
                :defaults => {'facets' => '*',
                              'distinct' => true
                }
      }

      API_KEY = '4de80b596b657e1250ae068635686c3b'
      APP_ID = 'A0EF2HAQR0'

      module ClassMethods


        def search(query, page = 0, hits_per_page = 15)
          url_params = Hash.new
          url_params['facetFilters'] = "type:#{self.crunchbase_item_type}"
          url_params['query'] = query.to_s
          url_params['hitsPerPage'] = hits_per_page
          url_params['page'] = page
          url_params.compact.merge!(SEARCH[:defaults])
          headers = {"X-Algolia-API-Key" => API_KEY, "X-Algolia-Application-Id" => APP_ID}
          request = Crunchbase::Utils::PostJsonRequest.new(SEARCH[:url], headers, url_params)
          raise StandardError, request.response.code if request.response.code.to_i >=400
          response = JSON.parse(request.response.body)
          return response.fetch('hits')



          #hits
          #{"logo_url_120_120"=>"http://images.crunchbase.com/image/upload/w_120,h_120,c_pad,g_center/v1397180711/55350ec099270194720309754ecaf94b.jpg", "location_name"=>"Seattle, Washington, United States", "n_investments"=>26, "markets"=>["Consumer Goods", "Groceries", "Crowdsourcing", "E-Commerce"], "type"=>"Organization", "primary_role"=>"company", "url"=>"/organization/amazon", "logo_url_100_100"=>"http://images.crunchbase.com/image/upload/w_100,h_100,c_pad,g_center/v1397180711/55350ec099270194720309754ecaf94b.jpg", "batch_indexed_at"=>1403322061538, "total_funding"=>8000000, "funded_on"=>[807260400538], "organization"=>true, "founded_on"=>760089600538, "locations"=>["d3d408384bbbb09438656c4cf9970090", "f110fca2105599f6996d011c198b3928", "86caa7e091fbce586e4cd58e799dd2bd"], "description"=>"Amazon is an international e-commerce company and online retailer that sells various products such as books, movies, electronics and others.", "logo_url_30_30"=>"http://images.crunchbase.com/image/upload/w_30,h_30,c_pad,g_center/v1397180711/55350ec099270194720309754ecaf94b.jpg", "name"=>"Amazon", "n_relationships"=>1709, "logo_url_60_60"=>"http://images.crunchbase.com/image/upload/w_60,h_60,c_pad,g_center/v1397180711/55350ec099270194720309754ecaf94b.jpg", "logo_url"=>"http://images.crunchbase.com/image/upload/v1397180711/55350ec099270194720309754ecaf94b.jpg", "roles"=>["Company", "Investor"], "homepage"=>"http://amazon.com", "objectID"=>"05554f656aa94dd162718ce2d60f10c4", "_highlightResult"=>{"markets"=>[{"value"=>"Consumer Goods", "matchLevel"=>"none", "matchedWords"=>[]}, {"value"=>"Groceries", "matchLevel"=>"none", "matchedWords"=>[]}, {"value"=>"Crowdsourcing", "matchLevel"=>"none", "matchedWords"=>[]}, {"value"=>"E-Commerce", "matchLevel"=>"none", "matchedWords"=>[]}], "name"=>{"value"=>"<em>Amazon</em>", "matchLevel"=>"full", "matchedWords"=>["amazon"]}}}
          #"matchedWords"=>[]}], "name"=>{"value"=>"<em>Amazon</em> Relocation Moving & Storage", "matchLevel"=>"full", "matchedWords"=>["amazon"]}}}]


        end

        private :search # make private on inherited class
      end


      def self.included(host_class)
        host_class.extend(ClassMethods)
      end




    end
  end
end







