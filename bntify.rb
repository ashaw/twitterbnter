module TwitterBnter
  class Bntify
    def initialize(access,secret,convo)
      #bnter only allows 3 messages so far
      @convo = convo.length > 2 ? convo[-3,3] : convo
      
      @consumer = OAuth::Consumer.new(TwitterBnter::Authorize::CONSUMER_KEY,TwitterBnter::Authorize::CONSUMER_SECRET, {
             :site               => "http://bnter.com/api/v1",
             :scheme             => :header,
             :http_method        => :post,
            })
            
      @access_token = OAuth::AccessToken.new(@consumer, access, secret)     
    end
    
    def build_bnter_hash
      @bnter_hash = {}
      @convo.each_with_index do |item,idx|
        msg_idx = idx + 1
        @bnter_hash["message_#{msg_idx}"] = item[:status]
        @bnter_hash["message_#{msg_idx}_author"] = item[:user]
      end
      @bnter_hash
    end
    
    def submit
      self.build_bnter_hash
      p @bnter_hash
      bnter = @access_token.post "http://bnter.com/api/v1/conversations/create.json", @bnter_hash.to_json, {"Content-Type" => "application/json"}
      p bnter.to_s, bnter.body.to_s
    end
  end
end