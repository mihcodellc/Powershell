
#!/bin/dash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# Program: job_check_non_freq_cubes.sh
# Author:  Monktar Bello  2024-09-25
# Purpose: if the last build status is failed for frequent elasticubes, try to rebuild them. Sisense won't allow this one to launch a new build when the elacticube is in state of building
# for test("toBefound","atLeastAflag") make sure the flag is mentioned
# url for curl is depending on what API offers and you may have to use different API
#jq is not jquery but jq is a lightweight and flexible command-line JSON processor. ref/tutorial at https://jqlang.github.io/jq/
# allows used this -w "%{http_code}\n" before url passed for curl; it gives error code for search
# note powershell "Elastic*"
#---------------------------------------------------------------------------------------------------------------------------------------------------------------

#update 10/28/2024 by Monktar Bello: get all matching cubes without looking at failed or stopped then build on condtions
#                                    #failed ? build. --  not build in last 24hours and not failed ? build

appid=test
scripts=/home/dbaAdmin/scripts
logfile=$scripts/$appid.log

days_old=4

num_cube=0
max_cube_tobuild=3


# Request a new session token
new_token=$(curl -X POST "http://website_address:port/api/v1/authentication/login" -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d 'username=<login>&password=<password>' | jq -r '.access_token')



echo "" > $logfile
echo "=========================================================================" >> $logfile
echo "`date` START" >> $logfile
echo "" >> $logfile

#debug
echo "$new_token"



# select (.title | test("Remittance|Prod";"xin")) | .oid' # xin for regular expression
# select (.title | test("Remittance|Prod";"xin") | not) | .oid' # not like test("")

# check all info in the json
curl -X GET \
-H "Authorization: Bearer $new_token" \
-H "Content-Type: application/json" \
"http://website_address:port/api/v1/elasticubes/getElasticubes" | jq -r '.[] |
select(.title == "TitleA" or .title == "TitleB") '


# 2. Fetch Elasticubes with failed builds and not stopped
# -w below is to find any error code
matching_cubes=$(
curl -X GET \
-H "Authorization: Bearer $new_token" \
-H "Content-Type: application/json" \
"http://website_address:port/api/v1/elasticubes/getElasticubesWithMetadata" | jq -r '.[] |  # getElasticubesWithMetadata provide status VS getElasticubes
select(.title == "TitleA" or .title == "TitleB") | .oid'
)

#rebuild failed cubes
#cube_oid refers to different key depends on whether you are elasticube or build API
for cube_oid in $matching_cubes; do
#    echo "Rebuilding Elasticube with ID: $cube_oid"
#        echo "Rebuilding Elasticube with ID: $cube_oid" >> $logfile
         echo "Looping cubes ... " >> $logfile
#        echo "\n Try to ReBuild**************************************"

                # check that is still failed and the last is not old than X day and not being built
        response=$(curl -X GET \
        -H "Authorization: Bearer $new_token" \
        -H "Content-Type: application/json" \
        "http://website_address:port/api/v1/elasticubes/getElasticubesWithMetadata" )


        lastBuiltUtc=$(echo "$response" | jq -r '.[] |  select (.oid == $a_oid) | .lastBuiltUtc ' --arg a_oid "$cube_oid")

        lastBuildStatus=$(echo "$response" | jq -r '.[] |  select (.oid == $a_oid) | .lastBuildStatus ' --arg a_oid "$cube_oid")

        status=$(echo "$response" | jq -r '.[] |  select (.oid == $a_oid) | .status[0] ' --arg a_oid "$cube_oid")

        status1=$(echo "$response" | jq -r '.[] |  select (.oid == $a_oid) | .status[1] ' --arg a_oid "$cube_oid")

        cube_title=$(echo "$response" | jq -r '.[] |  select (.oid == $a_oid) |  .title ' --arg a_oid "$cube_oid")


                #echo "Build last time: $lastBuiltUtc have ${lastBuiltUtc:6:13} extract"  # 13 ie digits for datetime
                #if not, then try rebuild
                #lastBuiltUtc=$(echo "$lastBuiltUtc" | grep -o '[0-9]*' | sed 's/ *//g')# source of error of conversion to date


                convert_divider=1000
                lastBuiltUtc=${lastBuiltUtc:6:13} #2>/dev/null # tag as bad substitution, try to ignore
                quotient=$(echo "$lastBuiltUtc/$convert_divider" | bc) # bc because large number
                #echo  "Here after division $quotient"
                human_readable_date=$(date -d @$quotient +"%Y-%m-%d")
                #echo "$human_readable_date"

                 # Get the current date in YYYY-MM-DD format and compared to last built date
                current_date=$(date +"%Y-%m-%d")
                date_var_epoch=$(date -d "$human_readable_date" +%s) # convert to epoch time
                current_date_epoch=$(date -d "$current_date" +%s)
                difference=$((current_date_epoch - date_var_epoch))
                difference_days=$((difference / 86400))  # Convert the difference from seconds to days ie 86400 seconds in a day


                echo "`date`  Check Build of Elasticube with ID: $cube_oid and title: $cube_title and building_status: "$status1" and build_statusfilter: "$status" built $difference_days days ago" >>  $logfile

                # if its not old than less than $days_old days
                if [[ "$status1" == "null"  ]]; then
                        #failed ? build. --  not build in last 24hours and not failed ? build
                        if [[ "$lastBuildStatus" == "failed" || $difference_days -lt $days_old && $difference_days -gt 1 && "$lastBuildStatus" != "failed" ]]; then
                         echo "`date` Rebuilding Elasticube with ID: $cube_oid and title: $cube_title " >> $logfile
                         echo "`date` Rebuilding Elasticube with ID: $cube_oid and title: $cube_title and status1: "$status1" and statusfilter:  "$status" "

                        curl -X POST \
                        -H "Authorization: Bearer $new_token" \
                        -H "Content-Type: application/json" \
                        -w "%{http_code}\n" "http://website_address:port/api/v2/builds" \
                        -d "{ \"datamodelId\": \"$cube_oid\", \"buildType\": \"full\"}" >> $logfile


                        sleep 8
                        echo "\n Build starts************************************"  >> $logfile

                        response=$(curl -X GET \
                        -H "Authorization: Bearer $new_token" \
                        -H "Content-Type: application/json" \
                        "http://website_address:port/api/v1/elasticubes/getElasticubesWithMetadata"
                        )

                        ##print status before move to next one
                        #echo $response | jq '.[] | select (.oid == $a_oid) |
                        #{name: .title, status: .status[0], status1: .status[1] , build_status: .lastBuildStatus, lastBuildTime: .lastBuildTime,
                        #        lastBuiltUtc: .lastBuiltUtc, lastBuildAttempt: .lastBuildAttempt}' --arg a_oid "$cube_oid"  >> $logfile

                        echo "\n Build ends************************************"  >> $logfile

                        #control how many to buil
                        num_cube=$((num_cube + 1))

                        if [[ "$num_cube" -gt "$max_cube_tobuild" ]]; then
                           exit 0 # 0 ie success
                        fi
                    else
                            echo "The difference is $days_old days or more or built in last 24hours for the cube named $cube_title " >> $logfile
                    fi

                else
                        echo "The cube named $cube_title is being built. " >> $logfile
                fi


done

echo "" >> $logfile
echo "`date` DONE" >> $logfile
