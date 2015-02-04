# myapp.rb
require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'igAPI'

pix_dir = settings.public_folder + "/pix/"
vote_hash = Hash.new

get '/' do
  erb :home
end

get '/*/vs/*' do |this, that|

  if File.exist?(pix_dir + this +".jpg")
    this_img = url("/pix/" + this +".jpg")
  elsif (imgsrc = get_fullres_url_of_recent_instagram_of(this))
    this_img = imgsrc
  else
    this_img = "http://www.clker.com/cliparts/Z/Z/S/Y/S/w/red-circle-cross-transparent-background-hi.png"
  end

  if File.exist?(pix_dir + that +".jpg")
    that_img = url("/pix/" + that +".jpg")
  elsif (imgsrc = get_fullres_url_of_recent_instagram_of(that)) 
    that_img = imgsrc
  else 
    that_img = "http://www.clker.com/cliparts/Z/Z/S/Y/S/w/red-circle-cross-transparent-background-hi.png"
  end 


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

  string = winner.to_s + loser.to_s
  if vote_hash[string].is_a? Integer
    vote_hash[string] += 1
  else
    vote_hash[string] = 1
  end

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