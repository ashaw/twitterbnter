module TwitterBnter
  class Bntify
    def initialize(access,secret,convo)
      #bnter only allows 3 messages so far
      @convo = convo.length > 2 ? convo[-3,3] : convo
      @convo.reverse!
      
      @consumer = OAuth::Consumer.new(TwitterBnter::Authorize::CONSUMER_KEY,TwitterBnter::Authorize::CONSUMER_SECRET, {
             :site               => "http://bnter.com",
             :scheme             => :query_string,
             :http_method        => :get,
            })
            
      @access_token = OAuth::AccessToken.new(@consumer, access, secret)     
    end
    
    def build_bnter_hash
      @bnter_hash = {}
      @convo.each_with_index do |item,idx|
        msg_idx = idx + 1
        @bnter_hash["message_#{msg_idx}"] = item[:status]
        @bnter_hash["message_#{msg_idx}_author_twitter_screen_name"] = item[:user]
        @bnter_hash["message_#{msg_idx}_author"] = item[:user]
        
      end
      @bnter_hash
    end
    
    def submit
      self.build_bnter_hash
      bnter = @access_token.post "/api/v1/conversations/create.json?#{@bnter_hash.to_params}"
      JSON.parse(bnter.body.to_s)
    end
  end
end

class Hash
  def to_params
    self.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")
  end
end