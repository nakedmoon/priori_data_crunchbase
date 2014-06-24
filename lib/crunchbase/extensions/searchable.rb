module Crunchbase
  module Extensions
    module Searchable


      # including this module in a Item class
      # we can search over Ajax Post and Api
      # the reason of manually include this module is that we can have a Item
      # not searchable by Ajax Post or Api (PressReference, ImageAsset)

      def self.included(host_class)

        host_class.send(:include, Crunchbase::Actions::Search)
        host_class.send(:include, Crunchbase::Actions::Fetch)

        class << host_class

          # adding some accessor for searching
          attr_accessor :items_per_page
          attr_accessor :crunchbase_member_routing
          attr_accessor :crunchbase_collection_routing



          def items_per_page
            # customize items per page
            @items_per_page ||= 10
          end


          def list_object_proc
            # lambda proc to apply on each record
            lambda{|r| self.new(r)}
          end

          def find_by_name(name, page = 0)
            # search using Ajax Post and populate an Array of Matching Objects
            # for example Organization.find_by_name('amazon')
            # get an Array of Organization objects with the name matching 'amazon'
            records = []
            begin
              limit_per_page = self.items_per_page > self.max_results ? self.max_results : self.items_per_page
              records = search(name, page, limit_per_page).map(&self.list_object_proc)
            rescue StandardError => e
              records = []
              Rails.logger.error "#{e.message}"
            ensure
              return records
            end
          end

          def find_by_permalink(permalink)
            # search an Item by its permalink
            record = nil
            begin
              json = fetch(permalink)
              json_data = json.fetch('data')
              record = self.new(json_data.fetch('properties'), json_data.fetch('relationships'), json.fetch('metadata'))
            rescue StandardError => e
              record = nil
              Rails.logger.error "#{e.message}"
            ensure
              return record
            end
          end

          def get_permalink_from_url(url)
            url.match(/^[\/]{0,1}#{crunchbase_member_routing}\/(.+)/)[1] rescue nil
          end

          def crunchbase_member_routing
            # the crunchbase action for get a single item of a given collection (for example /organization)
            # populate with default singular class name
            # anyway we can overwrite declaring
            # @crunchbase_member_routing = 'organization' in the class which inherit from Item
            @crunchbase_member_routing ||= self.crunchbase_item_type.downcase
          end

          def crunchbase_collection_routing
            # the crunchbase action for get collection of items (for example /organizations)
            # populate with default pluralized class name
            # anyway we can overwrite declaring
            # @crunchbase_collection_routing = 'organizations' in the class which inherit from Item
            @crunchbase_collection_routing ||= self.crunchbase_item_type.downcase.pluralize
          end




        end


        def crunchbase_link
          begin
            if self.permalink
              get_www_path(File.join(self.class.crunchbase_member_routing, self.permalink))
            elsif self.path
              get_www_path(self.path)
            elsif self.url
              self.url
            else
              raise StandardError
            end
          rescue
            nil
          end
        end


      end

    end
  end

end








