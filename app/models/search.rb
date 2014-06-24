class Search
  include ActiveModel::Model

  attr_accessor :search_string

  validates :search_string, presence: true, length: { maximum: 300 }


end