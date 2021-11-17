##############################################################################################################################################################
#             		                            Script Name: Linux_Reboots_checks                                                                               
#             		                            Description: This script generates all pre and post reboot checks.                                              
#             		                            Scrit Owner: Suyog Deshpande (sd077224)	                                                                        
##############################################################################################################################################################
clear
echo "Linux reboot checks"
echo ""
echo "1.Pre-reboot checks"
echo "2.Post-reboot checks"
echo "3.Compare Pre/Post checks"
echo "4.Exit"
echo "Enter your choice"
read choice
case "$choice" in


1)rm -f /tmp/pre_reboot_checks.txt
          echo ===============================*PRE_REBOOT_CHECKS_RESULT*=============================== >> /tmp/pre_reboot_checks.txt
         i=`date`
         echo DATE = $i >> /tmp/pre_reboot_checks.txt
         echo ""
		 i=`uptime`
		 echo UPTIME = $i >> /tmp/pre_reboot_checks.txt
         i=`hostname`
         echo Servername = $i >> /tmp/pre_reboot_checks.txt
         echo ""
         i=`uname -r`
         echo Kernel Version = $i >> /tmp/pre_reboot_checks.txt
         echo ""
         i=`cat /etc/system-release`
         echo OS Version = $i >> /tmp/pre_reboot_checks.txt
         echo ""
         i=`df -h | wc -l`
         echo File System Count = $i >> /tmp/pre_reboot_checks.txt
         rm -f /tmp/comp_pre_reboot_checks.txt
         i=`df -h | wc -l`
         echo File System Count = $i >> /tmp/comp_pre_reboot_checks.txt
         echo ""
         echo **********************************FILESYTEM********************************** >> /tmp/pre_reboot_checks.txt
         
         df -h >> /tmp/pre_reboot_checks.txt
         df -h | awk '{print $6}' >> /tmp/comp_pre_reboot_checks.txt
         echo **********************************FSTAB********************************** >> /tmp/pre_reboot_checks.txt
         
         cat /etc/fstab >> /tmp/pre_reboot_checks.txt
         cat /etc/fstab >> /tmp/comp_pre_reboot_checks.txt

###Differnce_report
		 if find /usr/local/cwx/diff_inst.ksh 
		 then 
		 echo "Generating diffrence report please wait"
		 /usr/local/cwx/diff_inst.ksh >> /tmp/pre_reboot_checks.txt
		 cat /tmp/pre_reboot_checks.txt >> /tmp/comp_pre_reboot_checks.txt
		 else 
		 echo "This is not a App node skipping difference report check"
		 fi 
         echo "Enter your Mail id (example suyog.deshpande@cerner.com)"
         read f1
		 mail -a /tmp/pre_reboot_checks.txt  -s "Pre-reboot checks- $(hostname)" $f1 < /dev/null
         echo""
         echo""
         echo "Pre-reboot checks are sent to: $f1"
         echo""
         echo""
;;

2)rm -f /tmp/post_reboot_checks.txt
         echo  ===============================*POST_REBOOT_CHECKS_RESULT*=============================== >> /tmp/post_reboot_checks.txt
         i=`date`
         echo DATE = $i >> /tmp/post_reboot_checks.txt
         echo ""
         i=`hostname`
         echo Servername = $i >> /tmp/post_reboot_checks.txt
         echo ""
         i=`uname -r`
         echo Kernel Version = $i >> /tmp/post_reboot_checks.txt
         echo ""
         i=`cat /etc/system-release`
         echo OS Version = $i >> /tmp/post_reboot_checks.txt
         echo ""
         i=`df -h | wc -l`
         echo File System Count = $i >> /tmp/post_reboot_checks.txt
         rm -f /tmp/comp_post_reboot_checks.txt
         i=`df -h | wc -l`
         echo File System Count = $i >> /tmp/comp_post_reboot_checks.txt
         echo ""
         i=`mount -a`
         echo Result of File mouting = $i >> /tmp/post_reboot_checks.txt
         echo ""
         echo **********************************FILESYTEM********************************** >> /tmp/post_reboot_checks.txt
         
         df -h >> /tmp/post_reboot_checks.txt
         df -h | awk '{print $6}' >> /tmp/comp_post_reboot_checks.txt
         echo **********************************FSTAB********************************** >> /tmp/post_reboot_checks.txt
         
         cat /etc/fstab >> /tmp/post_reboot_checks.txt
         cat /etc/fstab >> /tmp/comp_post_reboot_checks.txt

###Differnce_report
		 if find /usr/local/cwx/diff_inst.ksh 
		 then 
		 echo "Generating diffrence report please wait"
		 /usr/local/cwx/diff_inst.ksh >> /tmp/post_reboot_checks.txt
		 cat /tmp/post_reboot_checks.txt >> /tmp/comp_post_reboot_checks.txt
		 else 
		 echo "This is not a App node skipping difference report check"
		 fi 
         echo "Enter your Mail id (example suyog.deshpande@cerner.com)"
         read f1
		 mail -a /tmp/pre_reboot_checks.txt  -s "Pre-reboot checks- $(hostname)" $f1 < /dev/null
         echo""
         echo""
         echo "Pre-reboot checks are sent to: $f1"
         echo""
         echo""		 
         
;;

3) rm -f  /tmp/diff_result.txt
         file1="/tmp/comp_pre_reboot_checks.txt"
         file2="/tmp/comp_post_reboot_checks.txt"
         
         if cmp -s  "$file1" "$file2"; then
             printf 'Pre-checks and Post checks are same' >> /tmp/diff_result.txt
         else
             echo "File Sytem Mismatch Found" >> /tmp/diff_result.txt
             diff -y -w --suppress-common-lines "$file1" "$file2" >> /tmp/diff_result.txt
         fi
         echo "Enter your Mail id (example suyog.deshpande@cerner.com)"
         read f1
         file=/tmp/diff_result.txt
         mail -a /tmp/diff_result.txt  -s "Pre/Post checks Comp" $f1 < /dev/null

esac
