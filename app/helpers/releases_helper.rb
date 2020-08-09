module ReleasesHelper
    DUMMY_DATE = "1964-06-28T00:00:00.000+00:00"
    def timestamp_conversion( ptimestamp )
            if !ptimestamp
                return "Unknown"
            end

            time = Time.parse( ptimestamp )
            return time.strftime( "%A #{time.day.ordinalize} at %-I:%M %P" )
    end

    def list_pull_requests( user, repo )
        pr = Github.get_pull_requests( user, repo )
        if pr
            return pr
        else
            return []
        end
    rescue
        return []
    end

    def list_workflows( user, repo )
        pr = Github.get_workflows( user, repo )['workflows']
        if pr
            return pr
        else
            return []
        end
    end

    def list_workflow_last_successful_run( user, repo , name )

        id = Github.action_name_to_id( user, repo , name )

        pr = Github.get_workflow_runs( user, repo , id)
        if pr
            last_run = pr['workflow_runs'].find {|x| x['status'] == "completed" && x['conclusion'] == 'success'}
             if !last_run
                return { "created_at": DUMMY_DATE }
             end
            return last_run
        else
            return { "created_at": DUMMY_DATE }
        end
    rescue
         return { "created_at": DUMMY_DATE }
    end

    def list_workflow_last_run( user, repo , name )

        id = Github.action_name_to_id( user, repo , name )

        pr = Github.get_workflow_runs( user, repo , id)
        if pr
            last_run = pr['workflow_runs'].find {|x| x['run_number'] == pr['total_count'] }
            #print( "Checking run -> " , last_run[ 'run_number'] , "\n" )
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
            return  "pr_column_warning"
        end
        if status == 'completed' && conclusion == "success"
            return  "pr_column_ok"
        end

        if status == 'Unknown' && conclusion == 'Unknown'
            return ""
        end

        return "pr_column_error"

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