##############################################################################################################################################################
#                                                   Script Name: Domain_Health_Check                                                                         #
#                                                   Description: This script generates the domain health check report.                                       #
#                                                   Script Owner: Suyog Deshpande (sd077224)                                                                 #
##############################################################################################################################################################
#!bin/bash
clear
rm -rf /tmp/health_checks.txt
echo ""
echo "Please select the node on which you're performing the health check"
echo ""
echo -e "\e[1;31m**PLEASE SELECT THE NODE CORRECTLY**\e[0m"
echo ""
echo "1)App Node"
echo "2)Gluster Node "
echo "3)iBus"
echo "4)P2Sentinel"
echo "5)Exit"
echo ""
echo "Enter your choice"
read choice
case "$choice" in

1)echo ""
echo -e "\e[1;32m Domain health check is in progress......\e[0m"
sleep 5
echo ""
echo ""
echo -e "\e[1;33m Below information will be sent to your email id once the script execution is completed\e[0m"
echo ""
echo ""
####Hostname
                i=`hostname`
                echo Servername = $i >> /tmp/health_checks.txt
                echo "Hostname= $i"
		sleep 3
### Date
                i=`date`
                echo DATE = $i >> /tmp/health_checks.txt
                echo "DATE= $i"
		sleep 3
###OS Version check
                i=`cat /etc/system-release`
                echo OS Version = $i >> /tmp/health_checks.txt
                echo "OS Version= $i"
		sleep 3
###Console IP
                echo ""
                if [[ `ipmitool lan print 2 | grep "^IP Address  "` ]];
                then
                i=`ipmitool lan print 2 | grep "^IP Address  "`
                echo Console $i >> /tmp/health_checks.txt
                echo "Found ILO/Console $i"
                else
                echo "This is not a physical server"
                fi
		sleep 3

#### Uptime and load on the server
                echo ""
                echo ""
                trigger=180
		load=`uptime | awk '{print $3}'`
		response=`echo | awk -v T=$trigger -v L=$load 'BEGIN{if ( L > T){ print "trigger"}}'`
		if [ "$response" > "$trigger" ]; then
		echo Server is up from= $load days >> /tmp/health_checks.txt
		echo ""
		echo -e "\e[1;31m Server is up  from $load days \e[0m" 
		else
		echo -e "\e[1;32m Server is up  from $load days \e[0m"
		fi
		sleep 3
	
####Load on the server                
                i=`uptime | awk '{print $10,$11,$12}'`
                echo Load average: $i >> /tmp/health_checks.txt
                echo "Average load on the server = $i"
		
###Memory and Swap check
                echo ""
                echo "Memeory and Swap check is in progress"
		sleep 3
                i=`free -h | grep -i mem | awk '{print $2}'`
                echo Total memory=$i >> /tmp/health_checks.txt
                echo "Total memory = $i"


                i=`free -h | grep -i mem | awk '{print $3}'`
                echo Used Memory=$i >> /tmp/health_checks.txt
                echo "Used Memory = $i"


                i=`free -h | grep -i mem | awk '{print $4}'`
                echo Free Memory=$i >> /tmp/health_checks.txt
                echo "Free Memory= $i"

                echo ""
                echo "Swap Memory Usage"
                i=`free -h | grep -i swap | awk '{print $2}'`
                echo Total Swap memory=$i >> /tmp/health_checks.txt
                echo "Total Swap Memory = $i"


                i=`free -h | grep -i swap | awk '{print $3}'`
                echo Used Swap memory=$i >> /tmp/health_checks.txt
                echo "Used Swap Memory = $i"
                echo "Used Swap Memory =$i"

                i=`free -h | grep -i swap | awk '{print $4}'`
                echo Free Swap memory=$i >> /tmp/health_checks.txt
#                echo "Memeory and Swap check is completed"

###RPM checki
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing RPM health check...."
		sleep 2
                if [[ `rpm -qa` ]];
                then
                echo "RPM database is working fine" >> /tmp/health_checks.txt
                echo -e "\e[1;32mRPM database is working fine\e[0m"
                else
                echo "RPM database is in hung state" >> /tmp/health_checks.txt
                echo -e "\e[1;31m RPM database is in hung state \e[0m"
                fi
#                echo "RPM Health check completed"

#### Backup image list
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing Backup checks...."
                if [[ `/usr/openv/netbackup/bin/bpclimagelist` ]];
                then
                echo  "Backups are configured properly" >> /tmp/health_checks.txt
                echo -e "\e[1;32m Backups are configured correctly \e[0m"
                echo "Backup images list" >> /tmp/health_checks.txt
                /usr/openv/netbackup/bin/bpclimagelist >> /tmp/health_checks.txt
                else
                echo "Backups are not configured, please check manually" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Backups are not configured, please review manually \e[0m"
                fi
		sleep 3

###File System Check
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "File system check in progress"
		sleep 3
                if [[ `df -Ph | awk '0+$5 >= 85 {print}'` ]];
                then
                echo "Below File systems are above 85%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Few file systems are above 85% \e[0m"
                echo -e "\e[1;31m Details of the File systems that are above 85% has been sent to your email id \e[0m"
                df -Ph | awk '0+$5 >= 85 {print}' >> /tmp/health_checks.txt
                else
                echo "All the File systems are below 85% usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the File systems are having below 85% usage \e[0m"
                fi
		
##### Inode checks
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Checking inode usage..."
		sleep 3
                if [[ `df -Phi | awk '0+$5 >= 20 {print}'` ]];
                then
                echo "Below File systems are having inode usage more than 20%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Found File system exceeding 20% inode usage, details has been sent to your email \e[0m"
                df -Phi | awk '0+$5 >= 20 {print}' >> /tmp/health_checks.txt
                else
                echo "No File system is having above 20% inode usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the file systems are having below 20% inode usage \e[0m"
                fi
#                echo "Inode usage report completed"

###Notification Part
                echo ""
                echo ""
                echo ""
                echo "Enter your Mail id receive the report of check list (example suyog.deshpande@cerner.com)"
                read f1
                echo ""
                echo ""
                mail -a /tmp/health_checks.txt  -s "Domain health check report on - $(hostname)" $f1 < /dev/null
                echo""
                echo""
                echo -e "\e[1;36m Domain health check completed \e[0m"
                echo -e "\e[1;35m Domain health check report sent to: $f1 \e[0m"
                echo""
                echo""
;;

2)echo ""
echo -e "\e[1;32m Domain health check is in progress......\e[0m"
sleep 5
echo ""
echo ""
echo -e "\e[1;33m Below information will be sent to your email id once the script execution is completed\e[0m"
echo ""
echo ""
####Hostname
                i=`hostname`
                echo Servername = $i >> /tmp/health_checks.txt
                echo "Hostname= $i"
		sleep 3
### Date
                i=`date`
                echo DATE = $i >> /tmp/health_checks.txt
                echo "DATE= $i"
		sleep 3
###OS Version check
                i=`cat /etc/system-release`
                echo OS Version = $i >> /tmp/health_checks.txt
                echo "OS Version= $i"
		sleep 3
###Console IP
                echo ""
                if [[ `ipmitool lan print 2 | grep "^IP Address  "` ]];
                then
                i=`ipmitool lan print 2 | grep "^IP Address  "`
                echo Console $i >> /tmp/health_checks.txt
                echo "Found ILO/Console $i"
                else
                echo "This is not a physical server"
                fi
		sleep 3

#### Uptime and load on the server
                echo ""
                echo ""
                trigger=180
		load=`uptime | awk '{print $3}'`
		response=`echo | awk -v T=$trigger -v L=$load 'BEGIN{if ( L > T){ print "trigger"}}'`
		if [ "$response" > "$trigger" ]; then
		echo Server is up from= $load days >> /tmp/health_checks.txt
		echo ""
		echo -e "\e[1;31m Server is up  from $load days \e[0m" 
		else
		echo -e "\e[1;32m Server is up  from $load days \e[0m"
		fi
		sleep 3

####Load on the server                
                i=`uptime | awk '{print $10,$11,$12}'`
                echo Load average: $i >> /tmp/health_checks.txt
                echo "Average load on the server = $i"
		sleep 3

###Memory and Swap check
                echo ""
                echo "Memeory and Swap check is in progress"
		sleep 3
                i=`free -h | grep -i mem | awk '{print $2}'`
                echo Total memory=$i >> /tmp/health_checks.txt
                echo "Total memory = $i"


                i=`free -h | grep -i mem | awk '{print $3}'`
                echo Used Memory=$i >> /tmp/health_checks.txt
                echo "Used Memory = $i"


                i=`free -h | grep -i mem | awk '{print $4}'`
                echo Free Memory=$i >> /tmp/health_checks.txt
                echo "Free Memory= $i"

                echo ""
                echo "Swap Memory Usage"
                i=`free -h | grep -i swap | awk '{print $2}'`
                echo Total Swap memory=$i >> /tmp/health_checks.txt
                echo "Total Swap Memory = $i"


                i=`free -h | grep -i swap | awk '{print $3}'`
                echo Used Swap memory=$i >> /tmp/health_checks.txt
                echo "Used Swap Memory = $i"
                echo "Used Swap Memory =$i"

                i=`free -h | grep -i swap | awk '{print $4}'`
                echo Free Swap memory=$i >> /tmp/health_checks.txt
#                echo "Memeory and Swap check is completed"

###RPM checki
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing RPM health check...."
		sleep 3
                if [[ `rpm -qa` ]];
                then
                echo "RPM database is working fine" >> /tmp/health_checks.txt
                echo -e "\e[1;32mRPM database is working fine\e[0m"
                else
                echo "RPM database is in hung state" >> /tmp/health_checks.txt
                echo -e "\e[1;31m RPM database is in hung state \e[0m"
                fi
#                echo "RPM Health check completed"

#### Backup image list
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing Backup checks...."
		sleep 3
                if [[ `/usr/openv/netbackup/bin/bpclimagelist` ]];
                then
                echo  "Backups are configured properly" >> /tmp/health_checks.txt
                echo -e "\e[1;32m Backups are configured correctly \e[0m"
                echo "Backup images list" >> /tmp/health_checks.txt
                /usr/openv/netbackup/bin/bpclimagelist >> /tmp/health_checks.txt
                else
                echo "Backups are not configured, please check manually" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Backups are not configured, please review manually \e[0m"
                fi
#                echo "Backup checks completed"

###File System Check
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "File system check in progress"
		sleep 3
                if [[ `df -Ph | awk '0+$5 >= 85 {print}'` ]];
                then
                echo "Below File systems are above 85%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Few file systems are above 85% \e[0m"
                echo -e "\e[1;31m Details of the File systems that are above 85% has been sent to your email id \e[0m"
                df -Ph | awk '0+$5 >= 85 {print}' >> /tmp/health_checks.txt
                else
                echo "All the File systems are below 85% usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the File systems are having below 85% usage \e[0m"
                fi
#                echo "File system checks are completed"
##### Inode checks
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Checking inode usage"
		sleep 3
                if [[ `df -Phi | awk '0+$5 >= 20 {print}'` ]];
                then
                echo "Below File systems are having inode usage more than 20%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Found File system exceeding 20% inode usage, details has been sent to your email \e[0m"
                df -Phi | awk '0+$5 >= 20 {print}' >> /tmp/health_checks.txt
                else
                echo "No File system is having above 20% inode usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the file systems are having below 20% inode usage \e[0m"
                fi

###### Glusterd Service status
                                echo ""
                                echo ""
                                echo "Checking for Glusterd Service status"
				sleep 3
                                if [[ `service glusterd status | grep -i running` ]]; then
                                echo "Glusterd service is running" >> /tmp/health_checks.txt
                                echo -e "\e[1;32m Glusterd service is running \e[0m"
                                else
                                echo -e "\e[1;31m Glusterd service inactive please check manually \e[0m"
                                fi


#### Glusterfsd service status
                                echo ""
                                echo ""
                                echo "Checking for Glusterfd Service status"
				sleep 3
                                if [[ `service glusterfsd status | grep -i running` ]]; then
                                echo "Glusterd service is running" >> /tmp/health_checks.txt
                                echo -e "\e[1;32m Glusterfsd service is running \e[0m"
                                else
                                echo -e "\e[1;31m Glusterfsd service inactive please check manually \e[0m"
                                fi

#### Samba service status
                                echo ""
                                echo ""
                                echo "Checking for Samba Service status"
				sleep 3
                                if [[ `service smb status  | grep -i running` ]]; then
                                echo "Samba service is running" >> /tmp/health_checks.txt
                                echo -e "\e[1;32m Samba service is running \e[0m"
                                else
                                echo -e "\e[1;31m Samba service inactive please check manually \e[0m"
                                fi

### Gluster volume information
                                echo ""
                                echo ""
                                echo "Checking for gluster volume status"
				sleep 3
                                if [[ `gluster volume status` ]];
                                then
                                echo -e "\e[1;33m Gluster volume status output added to the report \e[0m"
                                gluster volume status >> /tmp/health_checks.txt
                                else
                                echo -e "\e[1;31m Gluster volume status failed \e[0m"
                                fi

#### Gluster File system mount check
                                echo ""
                                echo ""
                                echo "Checcking for Gluster mount point"
				sleep 3
                                if [[ `df -Th | grep -i gluster` ]];
                                then
                                echo "Gluster file system is mounted" >> /tmp/health_checks.txt
                                echo -e "\e[1;32m Gluster file system is mounted \e[0m"
                                else
                                echo "Gluster file system is not mounted please check" >> /tmp/health_checks.txt
                                echo -e "\e[1;31m Gluster file system is not mounted please check \e[0m"
                                fi
				
#####Testing file creation
				echo ""
				echo ""
				echo "Creating testing.file please wait"
				sleep 3
				if [[ `df -Th | grep glusterfs | awk '{print $7}'` ]];
				then
				i=`df -Th | grep glusterfs | awk '{print $7}' | head -1`
				echo "testing_health" >> $i/testing.file
				echo -e "\e[1;32m testing.file created sucessfully under: $i\e[0m"
				else
				echo -e "\e[1;31m Unable to create test file,please check the gluster file system \e[0m"
				fi
				
#####Testing file creation part 2 				
				if [[ `df -Th | grep glusterfs | awk '{print $7}'` ]];
				then
				i=`df -Th | grep glusterfs | awk '{print $7}' | tail -1`
				echo "testing_health" >> $i/testing.file
				echo -e "\e[1;32m testing.file created sucessfully under: $i\e[0m"
				else
				echo -e "\e[1;31m Unable to create test file,please check the gluster file system \e[0m"
				fi
				
###Notification Part				
                                echo ""
                                echo "Enter your Mail id receive the report of check list (example suyog.deshpande@cerner.com)"
               		        read f1
               		        echo ""
               		        echo ""
               		        mail -a /tmp/health_checks.txt  -s "Domain health check report on - $(hostname)" $f1 < /dev/null
               		        echo""
               		        echo""
               		        echo -e "\e[1;36m Domain Health check completed \e[0m"
               		        echo ""
               		        echo ""
               		        echo -e "\e[1;35m Domain health check report sent to: $f1 \e[0m"
               		        echo""
               		        echo""
;;

3)echo ""
echo -e "\e[1;32m Domain health check is in progress......\e[0m"
sleep 3
echo ""
echo ""
echo -e "\e[1;33m Below information will be sent to your email id once the script execution is completed\e[0m"
echo ""
echo ""
####Hostname
                i=`hostname`
                echo Servername = $i >> /tmp/health_checks.txt
                echo "Hostname= $i"
		sleep 3
### Date
                i=`date`
                echo DATE = $i >> /tmp/health_checks.txt
                echo "DATE= $i"
		sleep 3
###OS Version check
                i=`cat /etc/system-release`
                echo OS Version = $i >> /tmp/health_checks.txt
                echo "OS Version= $i"
		sleep 3
###Console IP
                echo ""
                if [[ `ipmitool lan print 2 | grep "^IP Address  "` ]];
                then
                i=`ipmitool lan print 2 | grep "^IP Address  "`
                echo Console $i >> /tmp/health_checks.txt
                echo "Found ILO/Console $i"
                else
                echo "This is not a physical server"
                fi
		sleep 3

#### Uptime and load on the server
                echo ""
                echo ""
                trigger=180
		load=`uptime | awk '{print $3}'`
		response=`echo | awk -v T=$trigger -v L=$load 'BEGIN{if ( L > T){ print "trigger"}}'`
		if [ "$response" > "$trigger" ]; then
		echo Server is up from= $load days >> /tmp/health_checks.txt
		echo ""
		echo -e "\e[1;31m Server is up  from $load days \e[0m" 
		else
		echo -e "\e[1;32m Server is up  from $load days \e[0m"
		fi
		sleep 3

####Load on the server                
                i=`uptime | awk '{print $10,$11,$12}'`
                echo Load average: $i >> /tmp/health_checks.txt
                echo "Average load on the server = $i"
		sleep 3

###Memory and Swap check
                echo ""
                echo "Memeory and Swap check is in progress"
                i=`free -h | grep -i mem | awk '{print $2}'`
                echo Total memory=$i >> /tmp/health_checks.txt
                echo "Total memory = $i"
		

                i=`free -h | grep -i mem | awk '{print $3}'`
                echo Used Memory=$i >> /tmp/health_checks.txt
                echo "Used Memory = $i"


                i=`free -h | grep -i mem | awk '{print $4}'`
                echo Free Memory=$i >> /tmp/health_checks.txt
                echo "Free Memory= $i"

                echo ""
                echo "Swap Memory Usage"
                i=`free -h | grep -i swap | awk '{print $2}'`
                echo Total Swap memory=$i >> /tmp/health_checks.txt
                echo "Total Swap Memory = $i"


                i=`free -h | grep -i swap | awk '{print $3}'`
                echo Used Swap memory=$i >> /tmp/health_checks.txt
                echo "Used Swap Memory = $i"
                echo "Used Swap Memory =$i"

                i=`free -h | grep -i swap | awk '{print $4}'`
                echo Free Swap memory=$i >> /tmp/health_checks.txt
		sleep 3

###RPM checki
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing RPM health check...."
                if [[ `rpm -qa` ]];
                then
                echo "RPM database is working fine" >> /tmp/health_checks.txt
		sleep 3
                echo -e "\e[1;32mRPM database is working fine\e[0m"
                else
                echo "RPM database is in hung state" >> /tmp/health_checks.txt
                echo -e "\e[1;31m RPM database is in hung state \e[0m"
                fi
#                echo "RPM Health check completed"

#### Backup image list
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing Backup checks...."
		sleep 3
                if [[ `/usr/openv/netbackup/bin/bpclimagelist` ]];
                then
                echo  "Backups are configured properly" >> /tmp/health_checks.txt
                echo -e "\e[1;32m Backups are configured correctly \e[0m"
                echo "Backup images list" >> /tmp/health_checks.txt
                /usr/openv/netbackup/bin/bpclimagelist >> /tmp/health_checks.txt
                else
                echo "Backups are not configured, please check manually" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Backups are not configured, please review manually \e[0m"
                fi
#                echo "Backup checks completed"

###File System Check
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "File system check in progress"
		sleep 3
                if [[ `df -Ph | awk '0+$5 >= 85 {print}'` ]];
                then
                echo "Below File systems are above 85%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Few file systems are above 85% \e[0m"
                echo -e "\e[1;31m Details of the File systems that are above 85% has been sent to your email id \e[0m"
                df -Ph | awk '0+$5 >= 85 {print}' >> /tmp/health_checks.txt
                else
                echo "All the File systems are below 85% usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the File systems are having below 85% usage \e[0m"
                fi
#                echo "File system checks are completed"
##### Inode checks
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Checking inode usage"
		sleep 3
                if [[ `df -Phi | awk '0+$5 >= 20 {print}'` ]];
                then
                echo "Below File systems are having inode usage more than 20%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Found File system exceeding 20% inode usage, details has been sent to your email \e[0m"
                df -Phi | awk '0+$5 >= 20 {print}' >> /tmp/health_checks.txt
                else
                echo "No File system is having above 20% inode usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the file systems are having below 20% inode usage \e[0m"
                fi

###ibus_checks
		echo ""
		echo ""
		rm -rf /tmp/ibus-details.txt
		if [[ `find /usr/local/cwx/ibus_info.sh` ]]; then
		echo "Found the ibus details as below:"
		echo ""
		/usr/local/cwx/ibus_info.sh >> /tmp/health_checks.txt
		/usr/local/cwx/ibus_info.sh >> /tmp/ibus-details.txt
		i=`cat /tmp/ibus-details.txt | grep -i Sonic | head -1`
		echo -e "\e[1;35m $i \e[0m"
		sleep 3
		i=`cat /tmp/ibus-details.txt | grep -i java`
		echo -e "\e[1;35m $i \e[0m"
		sleep 3
		i=`cat /tmp/ibus-details.txt | grep -i ibus | tail -1`
		echo -e "\e[1;35m $i \e[0m"
		sleep 3
		i=`mysql --version`
		echo -e "\e[1;35m Mysql is running on: $i \e[0m"
		else
		echo "No ibus details found,please verify manually"
		fi

		
###Notification Part				
               echo ""
               echo "Enter your Mail id receive the report of check list (example suyog.deshpande@cerner.com)"
               read f1
               echo ""
               echo ""
               mail -a /tmp/health_checks.txt  -s "Domain health check report on - $(hostname)" $f1 < /dev/null
               echo""
               echo""
               echo -e "\e[1;36m Domain Health check completed \e[0m"
               echo ""
               echo ""
               echo -e "\e[1;35m Domain health check report sent to: $f1 \e[0m"
               echo""
               echo""

;;

4)echo ""
echo -e "\e[1;32m Domain health check is in progress......\e[0m"
sleep 5
echo ""
echo ""
echo -e "\e[1;33m Below information will be sent to your email id once the script execution is completed\e[0m"
echo ""
echo ""
####Hostname
                i=`hostname`
                echo Servername = $i >> /tmp/health_checks.txt
                echo "Hostname= $i"
		sleep 3
### Date
                i=`date`
                echo DATE = $i >> /tmp/health_checks.txt
                echo "DATE= $i"
		sleep 3
###OS Version check
                i=`cat /etc/system-release`
                echo OS Version = $i >> /tmp/health_checks.txt
                echo "OS Version= $i"
		sleep 3
###Console IP
                echo ""
                if [[ `ipmitool lan print 2 | grep "^IP Address  "` ]];
                then
                i=`ipmitool lan print 2 | grep "^IP Address  "`
                echo Console $i >> /tmp/health_checks.txt
                echo "Found ILO/Console $i"
                else
                echo "This is not a physical server"
                fi
		sleep 3

#### Uptime and load on the server
                echo ""
                echo ""
                trigger=180
		load=`uptime | awk '{print $3}'`
		response=`echo | awk -v T=$trigger -v L=$load 'BEGIN{if ( L > T){ print "trigger"}}'`
		if [ "$response" > "$trigger" ]; then
		echo Server is up from= $load days >> /tmp/health_checks.txt
		echo ""
		echo -e "\e[1;31m Server is up  from $load days \e[0m" 
		else
		echo -e "\e[1;32m Server is up  from $load days \e[0m"
		fi
		sleep 3

####Load on the server                
                i=`uptime | awk '{print $10,$11,$12}'`
                echo Load average: $i >> /tmp/health_checks.txt
                echo "Average load on the server = $i"
		sleep 3

###Memory and Swap check
                echo ""
                echo "Memeory and Swap check is in progress"
		sleep 3
                i=`free -h | grep -i mem | awk '{print $2}'`
                echo Total memory=$i >> /tmp/health_checks.txt
                echo "Total memory = $i"


                i=`free -h | grep -i mem | awk '{print $3}'`
                echo Used Memory=$i >> /tmp/health_checks.txt
                echo "Used Memory = $i"


                i=`free -h | grep -i mem | awk '{print $4}'`
                echo Free Memory=$i >> /tmp/health_checks.txt
                echo "Free Memory= $i"

                echo ""
                echo "Swap Memory Usage"
                i=`free -h | grep -i swap | awk '{print $2}'`
                echo Total Swap memory=$i >> /tmp/health_checks.txt
                echo "Total Swap Memory = $i"


                i=`free -h | grep -i swap | awk '{print $3}'`
                echo Used Swap memory=$i >> /tmp/health_checks.txt
                echo "Used Swap Memory = $i"
                echo "Used Swap Memory =$i"

                i=`free -h | grep -i swap | awk '{print $4}'`
                echo Free Swap memory=$i >> /tmp/health_checks.txt
		sleep 3

###RPM checki
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing RPM health check...."
		sleep 3
                if [[ `rpm -qa` ]];
                then
                echo "RPM database is working fine" >> /tmp/health_checks.txt
                echo -e "\e[1;32mRPM database is working fine\e[0m"
                else
                echo "RPM database is in hung state" >> /tmp/health_checks.txt
                echo -e "\e[1;31m RPM database is in hung state \e[0m"
                fi
#                echo "RPM Health check completed"

#### Backup image list
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Performing Backup checks...."
		sleep 3
                if [[ `/usr/openv/netbackup/bin/bpclimagelist` ]];
                then
                echo  "Backups are configured properly" >> /tmp/health_checks.txt
                echo -e "\e[1;32m Backups are configured correctly \e[0m"
                echo "Backup images list" >> /tmp/health_checks.txt
                /usr/openv/netbackup/bin/bpclimagelist >> /tmp/health_checks.txt
                else
                echo "Backups are not configured, please check manually" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Backups are not configured, please review manually \e[0m"
                fi
#                echo "Backup checks completed"

###File System Check
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "File system check in progress"
		sleep 3
                if [[ `df -Ph | awk '0+$5 >= 85 {print}'` ]];
                then
                echo "Below File systems are above 85%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Few file systems are above 85% \e[0m"
                echo -e "\e[1;31m Details of the File systems that are above 85% has been sent to your email id \e[0m"
                df -Ph | awk '0+$5 >= 85 {print}' >> /tmp/health_checks.txt
                else
                echo "All the File systems are below 85% usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the File systems are having below 85% usage \e[0m"
                fi
#                echo "File system checks are completed"
##### Inode checks
                echo ""
                echo ""
                echo "" >> /tmp/health_checks.txt
                echo "" >> /tmp/health_checks.txt
                echo "Checking inode usage"
		sleep 3
                if [[ `df -Phi | awk '0+$5 >= 20 {print}'` ]];
                then
                echo "Below File systems are having inode usage more than 20%" >> /tmp/health_checks.txt
                echo -e "\e[1;31m Found File system exceeding 20% inode usage, details has been sent to your email \e[0m"
                df -Phi | awk '0+$5 >= 20 {print}' >> /tmp/health_checks.txt
                else
                echo "No File system is having above 20% inode usage" >> /tmp/health_checks.txt
                echo -e "\e[1;32m All the file systems are having below 20% inode usage \e[0m"
                fi
#                echo "Inode usage report completed"

#####Clsetup_checks
		echo ""
		echo ""		
		echo "Please wait clsetup check is in progress......" 
		if [[ `clsetup status sensage` ]];
		then
		echo ""
		else
		echo -e "\e[1;31m clsetup not found, please review manually \e[0m"
		fi

####Listener status
		echo ""
		echo ""
		echo "Checking Listener status"
		sleep 3
		if [[ `netstat -nap | grep :900` ]];
                then
                echo -e "\e[1;32m Listener is running \e[0m"
                else
                echo -e "\e[1;31m Unable to find any running listner \e[0m"
                fi

###Notification Part
                echo ""
                echo ""
                echo ""
                echo "Enter your Mail id receive the report of check list (example suyog.deshpande@cerner.com)"
                read f1
                echo ""
                echo ""
                mail -a /tmp/health_checks.txt  -s "Domain health check report on - $(hostname)" $f1 < /dev/null
                echo""
                echo""
                echo -e "\e[1;36m Domain health check completed \e[0m"
                echo -e "\e[1;35m Domain health check report sent to: $f1 \e[0m"
                echo""
                echo""
;;
esac
