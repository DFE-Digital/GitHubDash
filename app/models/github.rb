class Github
    GITHUB_URL    =  'https://api.github.com'.freeze
    EXPIRES       = 150
    TOKEN_EXPIRES = 28000

    def self.action_name_to_id( user , p_url , workflow_name)
       key = "#{p_url}#{workflow_name}"
       url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"

       if $redis.exists?( key )
        return $redis.get( key )
       end

       j_data = JSON.parse(local_request( user , url ))
       workflow = j_data['workflows'].select {|x| x['name'] == workflow_name }
       $redis.set( key , workflow[-1]['id'] , "ex": EXPIRES  )
       return workflow[-1]['id']
    end

    def self.get_pull_requests( user , p_url )
      key = "pull_requests_#{p_url}"
      url = "#{GITHUB_URL}/repos/#{p_url}/pulls?state=Open"

      if $redis.exists?( key )
         return JSON.parse( $redis.get( key ) )
      end

      data = local_request( user , url )
      $redis.set( key , data ,  "ex": EXPIRES )
      return JSON.parse(data)
    end

    def self.get_workflows( user , p_url )
      key = "get_workflows_#{p_url}"
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"

      if $redis.exists?( key )
        return JSON.parse( $redis.get( key ) )
      end

      data = local_request( user , url )
      $redis.set( key , data ,  "ex": EXPIRES )
      return JSON.parse(data)

    end

    def self.get_workflow_runs( user, p_url , workflow_id)
      key = "get_workflow_runs_#{p_url}#{workflow_id}"
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows/#{workflow_id}/runs"

      if !workflow_id
          return {"error" => "No data Found"}
      end

      if $redis.exists?( key )
        return JSON.parse( $redis.get( key ) )
      end

      #print( "Workflow url #{url}\n")
      ####https://api.github.com/repos/DFE-Digital/get-into-teaching-api/actions/runs/1396979
      data = local_request( user , url )
      $redis.set( key , data , "ex": EXPIRES )
      return JSON.parse(data)

    end

    def self.local_request( user , purl )
      #print "URL = " , purl, "\n"
      #print "Token = " , user.token , "\n"
      key = "last_token"
      uri = URI(purl)
      req = Net::HTTP::Get.new(uri)

      if user
        req[ "Authorization" ] = "token #{user.token}"
        $redis.set( key , user.token , "ex": TOKEN_EXPIRES  )
      else
        if $redis.exists?( key )
          temp = $redis.get( key )
          req[ "Authorization" ] = "token #{temp}"
        end
      end
  
      print( "Getting data: #{purl}\n")
      res = Net::HTTP.start(uri.hostname, uri.port , :use_ssl => uri.scheme == 'https' ) {|http|
        http.request(req)
      }
  
      if res.kind_of? Net::HTTPSuccess
        return res.body
      elsif res.kind_of? Net::HTTPUnauthorized
        print "Unauthorised Request (#{user.token})\n"
        return nil
      else
        print res , " (Error return)\n"
        return nil
      end
    end
  
  end