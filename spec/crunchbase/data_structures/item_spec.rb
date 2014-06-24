require 'rails_helper'
require 'spec_helper'

describe 'Crunchbase::DataStructures::Item' do

  before do

    @logger = Logger.new(STDOUT)

    class BaseItem < Crunchbase::DataStructures::Item


    end

    class SearchableItem < Crunchbase::DataStructures::Item
      include Crunchbase::Extensions::Searchable
      @crunchbase_item_type = 'Organization'
    end

    class TeamMember < Crunchbase::DataStructures::Item
      include Crunchbase::Extensions::Searchable
      @crunchbase_item_type = 'Person'
    end

    class RelationShipItem < Crunchbase::DataStructures::Item
      @crunchbase_item_type = 'TestItemType'

    end

    @item_properties = {'key_one' => 1, 'key_two' => 2}
    @item_relationships = {'first_relation' =>
                               {'items' => [
                                   {'type' => 'TestItemType', 'name' => 'ItemOne'},
                                   {'type' => 'TestItemType', 'name' => 'ItemTwo'}
                               ]
                               },
                           'second_relation' =>
                                {'items' => [
                                    {'path' => 'test_item_type/item_one', 'name' => 'ItemOne'},
                                    {'path' => 'test_item_type/item_two', 'name' => 'ItemTwo'}
                                ]
                                },
                            'third_relation' =>
                                {'items' => [
                                    {'type' => 'TestItemTypeNotFound', 'name' => 'ItemOne'},
                                    {'type' => 'TestItemTypeNotFound', 'name' => 'ItemTwo'}
                                ]
                                }
    }






  end

  context 'BaseItem' do
    it 'inherit class methods' do
      expect(BaseItem).to respond_to(:crunchbase_item_type)
    end

    it 'should set current crunchbase_item_type' do
      expect(BaseItem.crunchbase_item_type).to eq(BaseItem.name) # default to BaseItem.name
      BaseItem.crunchbase_item_type = 'NotABaseItem'
      expect(BaseItem.crunchbase_item_type).to eq('NotABaseItem')
    end

    it 'should be correctly initialized' do
      base_item = BaseItem.new(@item_properties, @item_relationships)
      expect(base_item.json_properties).to eq(@item_properties)
      expect(base_item.json_relationships).to eq(@item_relationships)
      expect(base_item.json_metadata).to eq({})
    end

    it 'should be define dynamic methods' do
      base_item = BaseItem.new(@item_properties)
      expect(base_item).not_to respond_to(:key_one) # method key one not defined
      expect(base_item.key_one).to eq(1) # defining instance method key_one and return key_one value
      expect(base_item).to respond_to(:key_one) # method key_one defined
    end

    it 'should return the correct relationship class' do
      base_item = BaseItem.new(@item_properties)
      expect(base_item.find_relationship_class('TestItemType')).to eq(RelationShipItem)
      expect(base_item.find_relationship_class('TestItemTypeNotFound')).to eq(OpenStruct)
    end

    it 'should return the correct relationship value for the first_relation' do
      base_item = BaseItem.new(@item_properties, @item_relationships)
      expect(base_item).not_to respond_to(:first_relation) # method first_relation one not defined
      item_first_relation = base_item.first_relation
      expect(base_item).to respond_to(:first_relation) # method first_relation is defined
      item_first_relation.each_with_index do |relation, index|
        expect(relation.class).to eq(RelationShipItem)
        expect(relation).not_to respond_to(:name) # method name one not defined
        expect(relation.name).to eq(@item_relationships['first_relation']['items'][index]['name']) # defining instance method name and return name value
        expect(relation).to respond_to(:name) # method name defined
      end
    end

    it 'should return the correct relationship value for the second_relation' do
      base_item = BaseItem.new(@item_properties, @item_relationships)
      expect(base_item).not_to respond_to(:second_relation) # method second_relation not defined
      item_second_relation = base_item.second_relation
      expect(base_item).to respond_to(:second_relation) # method second_relation is defined
      item_second_relation.each_with_index do |relation, index|
        expect(relation.class).to eq(RelationShipItem) # testing against path rather than explicit type
        expect(relation).not_to respond_to(:name) # method name one not defined
        expect(relation.name).to eq(@item_relationships['second_relation']['items'][index]['name']) # defining instance method name and return name value
        expect(relation).to respond_to(:name) # method name defined
      end
    end

    it 'should return the correct relationship value for the third_relation' do
      base_item = BaseItem.new(@item_properties, @item_relationships)
      expect(base_item).not_to respond_to(:third_relation) # method second_relation not defined
      item_third_relation = base_item.third_relation
      expect(base_item).to respond_to(:third_relation) # method second_relation is defined
      item_third_relation.each_with_index do |relation, index|
        expect(relation.class).to eq(OpenStruct) # testing against no matching class found
        expect(relation).to respond_to(:name) # method name is already defined because OpenStruct instance
        expect(relation.name).to eq(@item_relationships['third_relation']['items'][index]['name']) # defining instance method name and return name value
      end
    end




  end


  context 'SearchableItem' do
    it 'have mixin methods' do
      expect(SearchableItem).to respond_to(:find_by_name)
      expect(SearchableItem).to respond_to(:find_by_permalink)
    end

    it 'crunchbase_item_type should be Organization' do
      expect(SearchableItem.crunchbase_item_type).to eq('Organization') # default value
    end

    it 'crunchbase_member_routing should be organization' do
      expect(SearchableItem.crunchbase_member_routing).to eq('organization') # default value
    end

    it 'crunchbase_collection_routing should be organization' do
      expect(SearchableItem.crunchbase_collection_routing).to eq('organizations') # default value
    end

    it 'have mixin variables' do
      expect(SearchableItem).to respond_to(:items_per_page)
      expect(SearchableItem).to respond_to(:crunchbase_member_routing)
      expect(SearchableItem).to respond_to(:crunchbase_collection_routing)
    end

    it 'should be set items_per_page' do
      expect(SearchableItem.items_per_page).to eq(10) # default value
      SearchableItem.items_per_page = 100
      expect(SearchableItem.items_per_page).to eq(100)
    end

    it 'search method is private' do
      expect{SearchableItem.search}.to raise_error(NoMethodError,"private method `search' called for SearchableItem:Class")
    end

    it 'fetch method is private' do
      expect{SearchableItem.fetch}.to raise_error(NoMethodError,"private method `fetch' called for SearchableItem:Class")
    end

    it 'find by name populate with organizations' do
      @logger.info("Searching organizations for string 'Priori'....")
      organizations = SearchableItem.find_by_name('Priori')
      items_per_page = organizations.count - 1
      @logger.info("Found #{organizations.count} organizations....")
      if items_per_page>0
        @logger.info("Limit items per page to #{items_per_page}....")
        SearchableItem.items_per_page = items_per_page
        organizations = SearchableItem.find_by_name('Priori')
        @logger.info("Found #{organizations.count} organizations....")
        expect(organizations.count).to be <= items_per_page # check page limit
      end
      organizations.each do |organization|
        expect(organization.class).to eq(SearchableItem)
        expect(organization).not_to respond_to(:name)
        expect(organization.name).to eq(organization.json_properties['name']) # defining instance method name and return name value
        expect(organization).to respond_to(:name) # method name defined
      end
      if organizations.count > 0
        permalink = SearchableItem.get_permalink_from_url(organizations.first.url)
        @logger.info("Searching for organization with permalink '#{permalink}'....")
        organization = SearchableItem.find_by_permalink(permalink)
        expect(organization.permalink).to eq(permalink) # check page limit
        @logger.info("Found organization '#{organization.name}' with permalink '#{organization.permalink}'")
      end
    end

    it 'populate organizations team with TeamMember class' do
      @logger.info("Getting organizations matching string 'Priori'....")
      organizations = SearchableItem.find_by_name('Priori')
      if organizations.count > 0
        permalink = SearchableItem.get_permalink_from_url(organizations.first.url)
        organization = SearchableItem.find_by_permalink(permalink)
        unless organization.nil?
          @logger.info("Loaded organization #{organization.name} with permalink '#{organization.permalink}'")
          expect(organization).not_to respond_to(:current_team) # method second_relation not defined
          organization_current_team = organization.current_team
          expect(organization).to respond_to(:current_team) # method second_relation is defined
          organization_current_team.each_with_index do |team_member,index|
            expect(team_member.class).to eq(TeamMember) # we have also Person class matching, but TeamMember is the last in alphabetic order
            expect(team_member).not_to respond_to(:path)
            expect(team_member.path).to eq(organization.json_relationships['current_team']['items'][index]['path'])
            expect(team_member).to respond_to(:path)
            team_member_permalink = TeamMember.get_permalink_from_url(team_member.path)
            @logger.info("Finding person with permalink '#{team_member_permalink}'....")
            team_member_from_api = TeamMember.find_by_permalink(team_member_permalink)
            @logger.info("Loaded person with permalink '#{team_member_from_api.permalink}'....")
            expect(team_member_from_api.permalink).to eq(team_member_permalink)
          end
        end
      end
    end
  end






end




