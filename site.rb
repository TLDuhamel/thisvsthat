# myapp.rb
require 'sinatra'
require 'sinatra/content_for'
require "sinatra/reloader" if development?
require_relative 'igAPI'

PIX_DIR = settings.public_folder + "/pix/"
vote_hash = Hash.new(0)


helpers do
  def get_this_that_img_url (thisthat)
    if File.exist?(PIX_DIR + thisthat +".jpg")
      this_img = url("/pix/" + thisthat +".jpg")
    elsif (imgsrc = get_fullres_url_of_recent_instagram_of(thisthat))
      this_img = imgsrc
    else
      this_img = "http://www.clker.com/cliparts/Z/Z/S/Y/S/w/red-circle-cross-transparent-background-hi.png"
    end
  end
end

get '/' do
  erb :home
end

get '/*/vs/*' do |this, that|

  this_img = get_this_that_img_url(this)
  that_img = get_this_that_img_url(that)

  this_that_hash = {
    :this => this, 
    :that => that,
    :this_votes => vote_hash[this+that] ? vote_hash[this+that] : 0 ,
    :that_votes => vote_hash[that+this] ? vote_hash[that+this] : 0 ,
    :this_img => this_img,
    :that_img => that_img,
  }

  erb :versus, :locals => this_that_hash
end

get '/vote_*/*/*' do |vote, this, that|
  #vote for this (vote_this) or for that (vote_that)
  if vote == "that"
    winner = that
    loser = this
  elsif vote == "this"
    winner = this
    loser = that
  else
    return 500
  end

  string = "#{winner}#{loser}"
  vote_hash[string] += 1

  redirect "/#{this}/vs/#{that}"
end

post '/upload' do
  # Ensure we have been passed required params
  unless params[:file] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:name])
    @error = "No file selected"
    return 500
  end
  
  # Create local file
  begin
    local_file = File.open(pix_dir + name +".jpg", 'ab')  

    while blk = tmpfile.read(65536)
      local_file.write(blk)
    end

    local_file.close
  end

  redirect "TIMMY/vs/#{name}"
end