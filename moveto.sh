#!/bin/bash
#-----------------------------------------------------------------
# Program:  move_sql002_back.sh
# Host:     xxxxx  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Replace with name of dedicated storage server
# Purpose:  Pull the DB database backup to permanent storage
# Author:   Acompany DBA
# Modified by Monktar Bello: handle for a new server and slight strategy
#-----------------------------------------------------------------
# Notes:    To be run by crontab a day after the backup is made.
#                Once pulled here, the backup will be kept for 30days
#        then moved with all the others to long term for 60 days.
#-----------------------------------------------------------------


# a "mount point" permanently linked to the directory on Aserver-sql002 where the backup gets created...
source=/opt/?

# Replace the following with the local path on storage server where the backups will be moved to and then kept for 60 days
target=/mnt/?

appid=move_backup_to_shortterm

scripts=/home/Acompany-svc/scripts
logfile=$scripts/$appid.log

msgfile=$scripts/$appid.msg

today=`date +'%Y%m%d'`

signa=ready_for_short_term
 
 
 cd $source
        signa=$(find .  -type f -name "ready_for_short_term_*.txt" | head -n 1)
        #can we process ?
        if [ ! -e $signa ]; then # attention space between each element in []
                exit 1
        fi

        # ie ready to copy

        while [ ! -z $signa ];  # -z to check if string length is zero -- get rid of any ready file for FULL, LOG, DIFF. we are moving all files regardless their type
        do
                rm $signa # because the user doen't the right to write file to root on destination directory
                signa=$(find .  -type f -name "ready_for_short_term_*.txt" | head -n 1)
        done

        # Delete any old msgfiles to avoid confusion from previous run
        if [ -e $msgfile ]; then  rm $msgfile; fi

        # Put daily marker in logfile
        echo ""               >> $logfile
        echo "-------------------------------------------------------------------------------" >> $logfile
        echo "$appid  `date`" >> $logfile
        echo "-------------------------------------------------------------------------------" >> $logfile
        echo ""               >> $logfile


        # Get free space on target drive
        cd $target
        space=`df .|head -2|tail -1`
        spacefree=`echo $space|cut -f4 -d" "`

        # Go into source subdir and get its disk usage
        cd $source
        ### bupdir=`ls -d */|tail -1`
                bupdir=$source

        cd $bupdir
        spaceneeded=`du .|tail -1|sed s'/\t/ /g'|cut -f1 -d" "`         ; # Converts the tab to a space so the cut works right

                # Compare space needed to space free, alert if insuff room
        if [ $spaceneeded -ge $spacefree ]; then

                echo "$appid on `hostname` FAILURE $today" >> $msgfile
                echo "Insufficient space on target drive." >> $msgfile

                echo "$appid on `hostname` FAILURE $today" >> $logfile
                echo "Insufficient space on target drive." >> $logfile
        else
                # Copy current backup to target -n no overwrite -a  archive -p preserve -R to refer to directory
                cmd=`echo "cp -napR  $bupdir/*  $target"`
                echo "Time before copy:  `date`" >> $logfile
                echo "$cmd" >> $logfile
                $cmd
                returncode=$? # capture return code
                echo "Time after  copy:  `date`" >> $logfile

           # Set group and owner privs on files just copied (even if they failed to finish)
                 chmod g+rwx -R $target/*
                 chmod o-rwx -R $target/*


                # If no problems copying, remove source files
                if [ $returncode -eq 0 ]; then
                        echo "$appid on `hostname` Success $today" >> $msgfile
                        #
                        echo "Copy to short term was successful. Attempting to remove from source..." >> $logfile
                        cd $source
                        #cd ..
                        echo "Time before rm:  `date`" >> $logfile
                        cmd=`echo "rm -fR $bupdir"`
                        echo "$cmd" >> $logfile
                        $cmd
                        returncode=$?
                        echo "Time after  rm:  `date`" >> $logfile
                        if [ $returncode -eq 0 ]; then
                                echo "Remove from source successful." >> $logfile
                        else
                                echo "Remove from source failed with return code $returncode but copy to short term succeeded." >> $logfile
                                echo "Please verify then manually delete from source $source." >> $logfile
                        fi
                else
                        echo "$appid on `hostname` COPY FAILURE $today with return code: $returncode" >> $msgfile


                        echo "Does not imply the backup failed, only that the copy to short-term did."    >> $msgfile
                        echo "Resolve issue then run  $appid.sh  from `hostname` host."  >> $msgfile

                        # Add lines from logfile so admin has more data to go on
                        echo ""                            >> $msgfile
                        echo "Tail 10 of logfile follows:" >> $msgfile
                        echo ""                            >> $msgfile
                        tail -10 $logfile                  >> $msgfile
                        tail -10 $logfile                  >> $msgfile
                fi
        fi

if [ -e $msgfile ]; then
        # Add the msgfile, good or bad, to the logfile

        cat $msgfile >> $logfile

        # Report both errors and success to DBA group.
        $scripts/emailToDB.sh  $msgfile
fi

#--------------------------------------------------------------
# End script
#--------------------------------------------------------------
                                                                                          
