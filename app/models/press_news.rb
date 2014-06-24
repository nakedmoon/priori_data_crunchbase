class PressNews < Crunchbase::DataStructures::Item

  # declaing crunchbase_item_type
  # we know that we can use an instance of PressNews
  # as container for a PressReference item
  @crunchbase_item_type = 'PressReference'

  @max_results = 5

end