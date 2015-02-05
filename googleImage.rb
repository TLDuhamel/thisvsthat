require 'google-search'

def get_top_google_image_for(search_term, color)
  search = Google::Search::Image.new(:query => search_term, :safe => :off,
    :image_size => :large
    )
  random = rand(15) # select a random from the top 15
  search.find { |i| i.index == random }
end