class Github
    GITHUB_URL    =  'https://api.github.com'.freeze
    EXPIRES       = 150
    GITHUB_TOKEN  = ENV['GITHUB_TOKEN']

    def self.is_user_collaborator?( p_url , current_user )
      url = "#{GITHUB_URL}/repos/#{p_url}/collaborators/#{current_user['extra']['raw_info']['login']}/permission"
      data = local_request( url )
      if data['permission'] == 'admin'
           return true
      else
           return false
      end
    end

    def self.tag_to_commit( p_url , tag )
       url = "#{GITHUB_URL}/repos/#{p_url}/tags"
       if !tag
          return nil
       end
       j_data = local_request( url )
       if !j_data
          return nil
       end
       commit = j_data.select {|x| x['name'] == tag }
       return commit['url']
    end

    def self.action_name_to_id( p_url , workflow_name)
       url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
       if !workflow_name
          return nil
       end
       j_data = local_request( url )
       if !j_data
          return nil
       end
       workflow = j_data['workflows'].select {|x| x['name'] == workflow_name }
       return workflow[-1]['id']
    end

    def self.get_pull_requests( p_url )
      url = "#{GITHUB_URL}/repos/#{p_url}/pulls?state=Open"
      return(  local_request( url ) )
    end

    def self.get_releases( p_url )
      url = "#{GITHUB_URL}/repos/#{p_url}/releases"
      return(  local_request( url ) )
    end

    def self.get_workflows( p_url )
      url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows?state=active"
      return(  local_request( url ) )
    end

    def self.get_workflow_runs( p_url , workflow_id , branch = nil ) 
      if branch && branch != 'all'
          url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows/#{workflow_id}/runs?branch=master"
      else
          url = "#{GITHUB_URL}/repos/#{p_url}/actions/workflows/#{workflow_id}/runs"
      end

      if !workflow_id
          return {"error" => "No data Found"}
      end

      return(  local_request( url ) )

    end

    private

    def self.local_request(  purl )

      uri = URI(purl)
      key = purl

      if $redis.exists?( key )
        print( "Cached Data lookup #{purl}\n")
        return JSON.parse( $redis.get( key ))
      end

      req = Net::HTTP::Get.new(uri)
      req[ "Authorization" ] = "token #{GITHUB_TOKEN}"

      res = Net::HTTP.start(uri.hostname, uri.port ,  :use_ssl => uri.scheme == 'https' ) {|http|
        http.request(req)
      }

      if res.kind_of? Net::HTTPOK 
        print "Authorised Request (#{purl})\n"
        data = JSON.parse( res.body )
        $redis.set( key , res.body ,  "ex": EXPIRES )
        return data
      else
        print( "Error  #{res}  Data lookup #{purl}\n")
        return nil
      end

    end

end
