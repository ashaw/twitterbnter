require 'rubygems'
require 'twitter'
require 'yaml'
require 'sinatra'
require 'oauth'
require 'rest_client'
require 'json'
require File.expand_path("../authorize.rb", __FILE__)
require File.expand_path("../conversation.rb", __FILE__)
require File.expand_path("../bntify.rb", __FILE__)

enable :sessions

get '/' do  
  if params[:oauth_token]
    h = TwitterBnter::Authorize.new
    t = h.access_token(params[:oauth_token],session[:request_secret], params[:oauth_verifier])
    session[:token] = t[:token]
    session[:secret] = t[:secret]
    
    #if you reload the page with the oauth param, you 500, better to redirect and kill the possibility
    redirect '/' 
    
  elsif session[:token].nil?
    redirect '/login' 
  end

  # at this point they're logged in. let's do this
  erb <<-HTML
    <h1>Bntify this tweet</h1>
    <form method="post" action="/bntify">
      <input type="text" name="tweet">
      <input type="submit">
    </form>
  HTML

end

get '/login' do
  
  h = TwitterBnter::Authorize.new
  t = h.get_tokens
  
  session[:request_token] = t[:request_token]
  session[:request_secret] = t[:secret]
  @url = t[:url]
  
  redirect "#{@url}"
  erb :login
end

post '/bntify' do
  tweet = params[:tweet]
  
  twitter = TwitterBnter::Conversation.new(tweet)
  twitter.run
  p twitter.convo
  if twitter.convo.length > 1
    TwitterBnter::Bntify.new(session[:token], session[:secret], twitter.convo).submit
  end
end