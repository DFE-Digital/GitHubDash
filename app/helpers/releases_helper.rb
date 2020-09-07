module ReleasesHelper
    include Pagy::Frontend

    DUMMY_DATE = "1964-06-28T00:00:00.000+00:00"

    def timestamp_conversion( ptimestamp )
            if !ptimestamp
                return "Unknown"
            end

            return time_ago_in_words( Time.parse( ptimestamp ))
    end

    def first_line( text)
        text.lines.first
    end

    def user_role( current_user , project , environment )
        links = []

        if !environment.deployment_workflow
          return " "
        end

        if environment.release_prefix && current_user && Github.is_user_collaborator?( project.ref , current_user  )
          links << link_to( releases_path( {repo: project.ref , prefix: environment.release_prefix } )  ) do
                          content_tag(:i, "", class: "fas fa-cog" ).html_safe
          end
        end

        id = Github.action_name_to_id( project.ref , environment.deployment_workflow )
        if id
             branch =  environment.deployment_branch ? environment.deployment_branch : 'all'
             links << link_to( workflows_path( {repo: project.ref , branch: branch , id: id } )  ) do
                          content_tag(:i, "", class: "fas fa-dolly" ).html_safe
             end
        end

        return links.join(" ").html_safe
    end

    def list_pull_requests( current_user, repo )
        pr = Github.get_pull_requests( repo )
        if pr
            return pr
        else
            return []
        end
    rescue
        return []
    end

    def list_workflows( current_user, repo )
        pr = Github.get_workflows( repo )['workflows']
        if pr
            return pr
        else
            return []
        end
    end

    def list_workflow_last_successful_run( current_user , repo , name , branch = nil )

        id = Github.action_name_to_id( repo , name )

        pr = Github.get_workflow_runs(  repo , id , branch )
        if pr
            last_run = pr['workflow_runs'].find {|x| x['status'] == "completed" && x['conclusion'] == 'success'}
             if !last_run
                return { "created_at": DUMMY_DATE }
             end
             print( last_run )
            return last_run
        else
            return { "created_at": DUMMY_DATE }
        end
    rescue
         return { "created_at": DUMMY_DATE }
    end

    def list_workflow_last_run(current_user , repo , name , branch = nil )

        id = Github.action_name_to_id(  repo , name )

        pr = Github.get_workflow_runs( repo , id , branch)
        if pr
            last_run = pr['workflow_runs'].max_by{ |x| x[' run_number'] }  
            return last_run
        else
            return nil
        end
    rescue
        return nil
    end

    def map_conclusion_to_div(  data )
        status = data ? data['status'] : 'Unknown'
        conclusion = data ? data['conclusion'] : 'Unknown'

        if  status == 'in_progress'
            return  "pr_caution"
        end
        if status == 'completed' && conclusion == "success"
            return  "pr_good"
        end

        if status == 'Unknown' && conclusion == 'Unknown'
            return ""
        end

        return "pr_bad"

    end

    def map_conclusion_to_text(  data )
        status = data ? data['status'] : 'Unknown'
        conclusion = data ? data['conclusion'] : 'Unknown'

        if  status == 'in_progress'
            return  "In Progress"
        end
        if status == 'completed' && conclusion == "success"
                return  "Completed"
        end

        if conclusion == "cancelled"
                return  "Cancelled"
        end

        if status == 'Unknown' && conclusion == 'Unknown'
            return ""
        end

        return "Error"

    end
end
