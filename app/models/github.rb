require 'rest-client'
class Github
    GITHUB_URL    =  'https://api.github.com'.freeze
    EXPIRES       = 150
    TOKEN_EXPIRES = 28000
    TOKEN_KEY     = "last_token"

    def self.is_user_collaborator?( p_token , p_url)
      url = "#{GITHUB_URL}/repos/#{p_url}/collaborators"
      return false if !p_token #If we don't have a token we don't have access

      j_data = local_request(  p_token , url )
      print( "-> #{j_data} \n")

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

      key = purl

      if $redis.exists?( key )
        print( "Cached Data lookup #{key}\n")
        return JSON.parse( $redis.get( key ))
      end

      begin
        json = RestClient.get( purl , { :params => { :access_token => p_token }, :accept => :json })
        $redis.set( key , json )
        return ( JSON.parse( json ))
      rescue RestClient::ExceptionWithResponse => e
        print( JSON.parse(e.response) )
      end

      return nil

    end

end