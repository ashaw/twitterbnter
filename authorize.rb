module TwitterBnter
  # totally ripped from Fourrific
  class Authorize
    
    #get keys from YAML
    f = File.open(File.expand_path("../credentials.yml", __FILE__)) { |yf| YAML::load( yf ) }
    CONSUMER_KEY = f['keys']['key'].to_s
    CONSUMER_SECRET = f['keys']['secret'].to_s
    
    def initialize
      @consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET, {
             :site               => "http://bnter.com",
             :scheme             => :query_string,
             :http_method        => :get,
             :request_token_path => "/oauth/request_token",
             :access_token_path  => "/oauth/access_token",
             :authorize_path     => "/oauth/authorize"
            })
                                                  # add callback URL, or 4sq will ask you to
                                                  # enter a "pin" number in the app
      @request_token=@consumer.get_request_token :oauth_callback => "http://localhost:4567/"      
    end
    
    def get_tokens
      #store @request_token.token and @request_token.secret for use when you get the callback
      #ask user to visit @request_token.authorize_url
      
      @tokens = {}
      @tokens[:request_token] = @request_token.token
      @tokens[:secret] = @request_token.secret
      @tokens[:url] = @request_token.authorize_url
      
      @tokens
    end
    
    
    def access_token(oauth_token,secret,oauth_verifier)
      #... in your callback page:
      # request_token_key will be 'oauth_token' in the query paramaters of the incoming get request
      
      @request_token = OAuth::RequestToken.new(@consumer, oauth_token, secret)
      @access_token=@request_token.get_access_token :oauth_verifier => oauth_verifier
      
      @access_tokens = {}
      @access_tokens[:token] = @access_token.token
      @access_tokens[:secret] = @access_token.secret
      
      @access_tokens
      #store @access_token.token and @access_token.secret
    end
  end
end