class Github
    GITHUB_URL    =  'https://api.github.com'.freeze
    EXPIRES       = 150
    TOKEN_EXPIRES = 28000
    TOKEN_KEY     = "last_token"

    def self.is_user_collaborator?( p_token , p_url)
      url = "#{GITHUB_URL}/#{p_url}/collaborators"
      return true
    end

    def self.action_name_to_id( p_token , p_url , workflow_name)
       url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
       if !workflow_name
          return nil
       end
       j_data = local_request(  p_token , url )
       workflow = j_data['workflows'].select {|x| x['name'] == workflow_name }
       return workflow[-1]['id']
    end

    def self.get_pull_requests( p_token , p_url )
      url = "#{GITHUB_URL}/repos/#{p_url}/pulls?state=Open"
      return(  local_request(  p_token , url ) )
    end

    def self.get_workflows( p_token , p_url )
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
      return(  local_request(  p_token , url ) )
    end

    def self.get_workflow_runs( p_token, p_url , workflow_id)
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows/#{workflow_id}/runs"

      if !workflow_id
          return {"error" => "No data Found"}
      end

      return(  local_request(  p_token , url ) )

    end

    private

    def self.local_request( p_token , purl )
      #print "URL = " , purl, "\n"
      #print "Token = " , user.token , "\n"

      uri = URI(purl)
      req = Net::HTTP::Get.new(uri)
      key = purl

      if $redis.exists?( key )
        print( "Cached Data lookup #{purl}\n")
        return JSON.parse( $redis.get( key ))
      end

      if p_token
        print( "Authorised User look up of #{purl}\n")
        req[ "Authorization" ] = "token #{p_token}"
      else
        if $redis.exists?( TOKEN_KEY )
          print( "Authorised user (cached token) look up of #{purl}\n")
          temp = $redis.get( TOKEN_KEY )
          req[ "Authorization" ] = "token #{temp}"
        else
          print( "Anonymous look up of #{purl}\n")
        end

      end

      res = Net::HTTP.start(uri.hostname, uri.port , :use_ssl => uri.scheme == 'https' ) {|http|
        http.request(req)
      }

      if res.kind_of? Net::HTTPSuccess
        data = JSON.parse( res.body )
        $redis.set( key , res.body ,  "ex": EXPIRES )
        if( p_token)
            $redis.set( TOKEN_KEY , p_token, "ex": TOKEN_EXPIRES  )
        end
        return data
      elsif res.kind_of? Net::HTTPUnauthorized
        print "Unauthorised Request (#{p_token})\n"
        if $redis.exists?( TOKEN_KEY )
          $redis.del( TOKEN_KEY )
        end
        return nil
      else
        print res , " (Error return)\n"
        return nil
      end
    end

end