module Crunchbase
  module DataStructures

    class Item

      attr_reader :json_properties
      attr_reader :json_relationships
      attr_reader :json_metadata
      attr_reader :image_path_prefix
      attr_reader :www_path_prefix
      attr_reader :api_path_prefix



      class << self
        attr_accessor :item_attributes
        attr_accessor :crunchbase_item_type
        attr_accessor :max_results

        def max_results
          # customize items per page
          @max_results ||= 100000
        end

        def crunchbase_item_type
          # the crunchbase item type
          # populate with default class name
          # anyway we can match the crunchbase type declaring
          # @crunchbase_item_type = 'CustomType' in the class which inherit from Item
          @crunchbase_item_type || self.name
        end

      end

      def find_relationship_class(item_type)
        # looking for a class matching the actual crunchbase type
        # if not found use a OpenStruct class
        # reload classes so we can view all descendants of Item
        Rails.application.eager_load! unless Rails.configuration.cache_classes
        item_type_klasses = Crunchbase::DataStructures::Item.descendants.select{|klass| klass.crunchbase_item_type.to_s == item_type}
        # order klasses by name and select last class
        item_type_klasses.sort{|k1,k2| k1.name <=> k2.name}.last || OpenStruct
      end


      def initialize(json_properties, json_relationships = {}, json_metadata = {})
        @json_properties = json_properties
        @json_relationships = json_relationships
        @json_metadata = json_metadata
        @image_path_prefix = json_metadata['image_path_prefix']
        @www_path_prefix = json_metadata['www_path_prefix']
        @api_path_prefix = json_metadata['api_path_prefix']


      end

      def <=>(other)
        # a basic override for sorting element of this class in a Array
        self.class == other.class && self.created_at <=> other.created_at
      end


      def method_missing(method_name, *attr)
        value = nil
        check_for_attribute = method_name.to_s.underscore
        begin
          # we search methods first in the json properties keys and then in the json_relationships keys
          if self.json_properties.has_key?(check_for_attribute)
            value = json_properties.fetch(check_for_attribute)
          elsif self.json_relationships.has_key?(check_for_attribute)
            json_relation = self.json_relationships.fetch(check_for_attribute)
            relation_class = nil
            item_type = nil
            value = Array.new.tap do |v|
              relation_items = json_relation.fetch('items')
              relation_items.each do |item|
                # try to get the item type first by type attribute and then by item path
                # because for example person relationship doesn't have type attribute but
                # we can get the type parsing path person/person-permalink
                # lazy eval, assume all elements in relationship have the same time, eval once
                item_type ||= item['type'] || item['path'].split('/').first.camelize
                # search all descendants of Crunchbase::DataStructures::Item
                # looking for a class matching the actual crunchbase type
                # lazy eval, check for the matching class once
                relation_class ||= find_relationship_class(item_type)
                v << relation_class.send(:new, item, {}, self.json_metadata) if relation_class.respond_to?(:max_results) && v.size < relation_class.max_results
              end
            end
          else
            raise NoMethodError, method_name
          end
        rescue StandardError => e
          Rails.logger.debug "Method Missing Error : #{e.message}"
          value = nil
        ensure
          # ensure define singleton (metaclass) method at instance level
          # in current class returning the correct value || nil
          # the next time we call the same method we have no method_missing delegation
          define_singleton_method(check_for_attribute) { value }
          value
        end
      end

      def main_image
        get_image_path(self.primary_image.first.path) rescue nil
      end




      private

      def get_image_path(image_url)
        @image_path_prefix.nil? ? image_url : File.join(@image_path_prefix, image_url)
      end

      def get_www_path(www_url)
        @www_path_prefix.nil? ? www_url : File.join(@www_path_prefix, www_url)
      end

      def get_api_path(api_url)
        @api_path_prefix.nil? ? api_url : File.join(@api_path_prefix, api_url)
      end





    end







  end
end
