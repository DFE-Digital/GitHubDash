class Github
    GITHUB_URL    =  'https://api.github.com'.freeze
    EXPIRES       = 150
    TOKEN_EXPIRES = 28000
    TOKEN_KEY     = "last_token"

    def self.action_name_to_id( user , p_url , workflow_name)
       key = "#{p_url}#{workflow_name}"
       url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
       if !workflow_name
          return nil
       end
       j_data = local_request( key, user , url )
       workflow = j_data['workflows'].select {|x| x['name'] == workflow_name }
       return workflow[-1]['id']
    end

    def self.get_pull_requests( user , p_url )
      key = "pull_requests_#{p_url}"
      url = "#{GITHUB_URL}/repos/#{p_url}/pulls?state=Open"
      return(  local_request( key, user , url ) )
    end

    def self.get_workflows( user , p_url )
      key = "get_workflows_#{p_url}"
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
      return(  local_request( key, user , url ) )
    end

    def self.get_workflow_runs( user, p_url , workflow_id)
      key = "get_workflow_runs_#{p_url}#{workflow_id}"
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows/#{workflow_id}/runs"

      if !workflow_id
          return {"error" => "No data Found"}
      end

      return(  local_request( key, user , url ) )

    end

    private

    def self.local_request( key ,user , purl )
      #print "URL = " , purl, "\n"
      #print "Token = " , user.token , "\n"

      uri = URI(purl)
      req = Net::HTTP::Get.new(uri)

      if $redis.exists?( key )
        print( "Cached Data lookup #{purl}\n")
        return JSON.parse( $redis.get( key ))
      end

      if user
        print( "Authorised User look up of #{purl}\n")
        req[ "Authorization" ] = "token #{user.token}"
        $redis.set( TOKEN_KEY , user.token , "ex": TOKEN_EXPIRES  )
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
        return data
      elsif res.kind_of? Net::HTTPUnauthorized
        print "Unauthorised Request (#{user.token})\n"
        return nil
      else
        print res , " (Error return)\n"
        return nil
      end
    end

end