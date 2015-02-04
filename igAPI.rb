require 'instagram'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if development?

Instagram.configure do |config|
  config.client_id = "4f0fd4c146c34e70b4173ede0272733c"
  config.client_secret = "e6135616b6e849b18393d3150f49583d"
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end


def get_fullres_url_of_recent_instagram_of(search_term)
  client = Instagram.client
  hashtags = client.tag_search(search_term) # searches for existence of searchable hashtag.
  return nil unless hashtags.any? # becoz some hashtags are blocked by instagram (pornographic, mostly)
  gram = client.tag_recent_media(hashtags[0].name, {count: 1})[0]
  gram.images.standard_resolution.url
end