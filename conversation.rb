module TwitterBnter
  class Conversation
    
    attr_reader :convo
    
    def initialize(tweet)
      tweet.to_s =~ /(\d+)$/
      @tweet_id = $1 || raise("#{$1} is not a valid tweet")
      @convo = []
    end
    
    def run
      get_convo(@tweet_id.to_i)
    end
    
    def get_convo(tweet_id)
      tweet = Twitter.status(tweet_id)
      puts "adding #{tweet_id}"
      @convo << {:status => tweet.text, :user => tweet.user.screen_name}
      if tweet.in_reply_to_status_id_str
        get_convo(tweet.in_reply_to_status_id_str.to_i)
      end
    end
  end
end