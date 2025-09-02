####### old version of "scripting-for-public /linux.sh" ###########

mkdir dossierbello
cat > jecreeunfichier_executable_pour_bash.sh
#en commentaire : save ici ie ctrl+d
cp file1 copie_de_file1 # -r pour un dossier
mv file1 est_copie_de_file1
rm supprime_ce_fichier
chmod u+rwx permis_user_sur_file1
ls -l #permission sur les objets
bash execute_cefichier.sh
chown monktar_ownerde file1 # -R 


#use help in command ligne: 
#   man [option].. [command name]..
#    man -k [key_word] # relevant
#    man -a [key_word] # all mathcing 
# https://www.tutorialkart.com/bash-shell-scripting/bash-current-date-and-time/
# https://linuxgazette.net/18/bash.html
#https://doc.ubuntu-fr.org/tutoriel/learn_unix_in_10_minutes
#https://www.gnu.org/software/bash/manual/bash.html#Looping-Constructs
#https://linux.die.net/man/1/bash
#https://www.guru99.com/linux-commands-cheat-sheet.html#:~:text=%20%20%20%20Command%20%20%20,with%20detaile%20...%20%2025%20more%20rows%20

#https://www.sitepoint.com/cron-jobs/
crontab -e # to edit the job file. if nano ctrl+x ie save exit -- ctrl+o exit then Enter to return to cmd line -- 
crontab -l 
# 2>&1 ie both standard output and error output AND /dev/null ie noemail to the owner of this crontab
# the script does send email to dba. every 20min. the log backup happen every 15min. a "done" file control when to move file
# min hour dom moy dow **** /20 ie every. you can list all values 1-5 or 1,2,3,4,5
*/20 * * * * /home/Acompany-svc/scripts/move_sql002_backup.sh >/dev/null 2>&1
#------------------------------------------------------------------------
#copie between server to your /home/mbello. To just the directory:  cd $HOME OR cd ~ <> cd - => revient au dossier précédent
scp ./fileName mbello@serverName:~ 

