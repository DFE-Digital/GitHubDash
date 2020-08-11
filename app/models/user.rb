class User

    @name = ""
    @uid = ""
    @token = ""
    @provider = ""

    def initialize( values)
        @name     = values['name']
        @uid      = values['uid']
        @token    = values['token']
        @provider = values['provider']
    end

    def provider
        @provider
    end

    def token
        @token
    end

    def uid
        @uid
    end

    def name
      @name
    end

    def self.find( uid )
      if $redis.exists?( uid )
        red = $redis.get( uid )
        data = JSON.parse( red )
        return User.new( data )
      else
        return nil
      end
    end

    def self.find_and_refresh( auth )

      if $redis.exists?( auth["uid"] )
        red = $redis.get( auth["uid"] )
        data = JSON.parse( red )
      else
        data ={ "provider" => auth["provider"],"uid" => auth["uid"], "name" => auth["info"]["name"] , "token" => auth['credentials']['token'] }
        $redis.set( auth["uid"] , data.to_json)
      end
      print "Welcome ", data['name'] , "\n"
      return User.new( data )
    end
  
end