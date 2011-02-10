require 'rubygems'
require 'twitter'
require 'yaml'
require 'sinatra'
require 'oauth'
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
    <head>
    <%= style %>
    </head>
    <body>
    <h1>Bntify a conversation ending with this Tweet ID or URL</h1>
    <form method="post" action="/bntify">
      <input type="text" name="tweet" style="width:600px;height:30px;font-size:22px">
      <input type="submit">
    </form>
    <hr />
    <p>By @<a href="http://twitter.com/a_l">a_l</a></p>
    </body>
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
    @payload = TwitterBnter::Bntify.new(session[:token], session[:secret], twitter.convo).submit
  else
    @payload = {"status" => "Not a conversation"}
  end
    erb <<-HTML
      <head>
        <%= style %>
      </head>
      <body>
      <% if @payload['status'] == "success" %>
        <h1>Successfully Bntified!</h1>
          <h2><a href="http://bnter.com/convo/<%= @payload['conversation_id'] %>">Visit Bnter <%= @payload['conversation_id'] %></a></h2>
      <% else %>
        <h1>Error: <%= @payload['status'] %>
      <% end %>
      <hr />
      <p>By @<a href="http://twitter.com/a_l">a_l</a></p>
      </body>
    HTML
end

def style
  <<-CSS
    <style>
    body {
      width:960px;margin:10px auto;
      font-family:"Helvetica Neue",Helvetica,arial,sans-serif;
      color:#333;
      }   
    </style>
  CSS
end