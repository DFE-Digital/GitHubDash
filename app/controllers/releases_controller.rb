require 'pagy/extras/array'
require 'pagy/extras/bulma'

include ActionView::Helpers::DateHelper

class ReleasesController < ApplicationController
  include Pagy::Backend

  def time_between( pstart , pend )
            if !pstart || !pend
                return 0
            end
            start = Time.parse( pstart )
            end_time = Time.parse( pend )
            return( (end_time - start).to_i )
  end

  def timestamp_conversion( ptimestamp )
            if !ptimestamp
                return "Unknown"
            end

            return Time.parse( ptimestamp )
  end

  def show () 
     formatted_data = []
     failed_runs = []
     good_runs = []
     labels = []
     xmin = 999999
     xmax = 0
     unformatted_data =  Github.get_workflow_runs(  params[:repo] , params[:id]  , params[:branch] )['workflow_runs']

   
     unformatted_data.each do | workflow |

        xlast_time = timestamp_conversion( workflow['created_at'] ) 
        xtook      = time_between( workflow['created_at'] , workflow['updated_at'] )  

        element = { message:   workflow['head_commit']['message'] ,
                    author:    workflow['head_commit']['author']['name'] ,
                    last_run:  time_ago_in_words( xlast_time ),
                    state:     workflow['conclusion'] ,
                    run_number: workflow['run_number'] ,
                    took:      xtook   }
        if xtook > xmax 
          xmax = xtook 
        end

        if xtook < xmin 
          xmin = xtook 
        end

        labels << workflow['run_number']
        if workflow['conclusion'] == "success"
            good_runs   << xtook
            failed_runs   << 0
        else
            good_runs   << 0
            failed_runs   << xtook
        end

        formatted_data << element
     end

     @options = { responsive:          true ,
                  maintainAspectRatio: false ,
                  scales: {
                      xAxes: [{
                        stacked: true,
                        display: true,
                        scaleLabel: { display: true, labelString: 'Run' }
                      }],
                      yAxes: [{
                        stacked: true,
                        display: true,
                        scaleLabel: { display: true, labelString: 'Seconds' },
                        ticks: { min: xmin, max: xmax.ceil(-2), stepSize: ((xmax - xmin ) / 10 ).ceil(-2) }
                      }]
                    }
                }

     @data = { labels: labels ,
             datasets: [
            {
                label: 'Failed Runs',
                backgroundColor: 'rgba(151,0,0,1)',
                data: failed_runs
            }  ,
            {
                label: 'Succesful Runs',
                backgroundColor: 'rgba(0,151,0,1)',
                data: good_runs
            } ] }


     @pagy , @workflows = pagy_array( formatted_data , page: params[:page] , items: 15 ) 
  end
end
