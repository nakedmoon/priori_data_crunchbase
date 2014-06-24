Ruby ORM dor Crunchbase.

The basic goal of **Crunchbase ORM** is to get items from Crunchbase and create a full mapping between Crunchbase items 
(Oranizations, Products, People, ...) and system Classes.

## Requirements
Ruby 2.1.1 and Ruby On Rails 4.1.1

## Installation

```console
git clone https://github.com/nakedmoon/priori_data_crunchbase
cd priori_data_crunchbase
bundle 'install'
```

## Start
```console
rails s
```
And go to http://localhost:3000/crunchbase/index


## Test
The test coverage cover only the critical aspects of metaprogramming; it don't cover controller for now.
This because you can reuse the library in any other system with different models, controllers and views.

```console
rspec
```

## Usage
The application guesses the actual Object in wich pull the Crunchbase item, looking in to class 
variable **@crunchbase_item_type**; for example if we want the **TestClass** contains the **Organization** item:


```ruby                                                                                     
class TestClass < Crunchbase::DataStructures::Item
    @crunchbase_item_type = 'Organization'
end
```
 
 If you want search over all *organizations* (AJAX request) or get a specific *organization* (API request) you
 need to include the **Crunchbase::Extensions::Searchable** module:

```ruby                                                                                     
class TestClass < Crunchbase::DataStructures::Item
    include Crunchbase::Extensions::Searchable
    @crunchbase_item_type = 'Organization'
end
```
 and you will able to use finders:

```ruby
TestClass.find_by_name('amazon') # return an array of TestItem objects
TestClass.find_by_permalink('amazon') # return a TestItem object matching 'amazon' prmalink
```


 Anyway the **@crunchbase_item_type** being populated starting to class name, so if you use Organization as 
 class name, you don't need to configure **@crunchbase_item_type**. 
 In the same way on every object instance which inherit from **Crunchbase::DataStructures::Item**, you can 
 get all attributes and relationships; for example the *current_team* of an *organization* contains an array 
 of *Person* Crunchbase items, so you can declare:
 
```ruby                                                                                     
class MyCustomPerson < Crunchbase::DataStructures::Item
    @crunchbase_item_type = 'Person'
end 
```
 and then we have:
 
```ruby                                                                                     
organization = TestClass.find_by_permalink('amazon')
organization.current_team # return an Array of MyCustomPerson instances
```



 


 
 

 
 
 
 
 
 
 
 
 