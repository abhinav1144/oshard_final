#!/bin/bash

a=`df /dev/sda1 | sed ' /Use%/d ' | awk '{print $5}'`

if [[ $a < 10% ]]
then
echo " vm is healthy on $(hostname) as on $(date)"
else
echo " vm is unhealthy on $(hostname) as on $(date)"|sudo mail -s "ALERT" practicevm4@gmail.com,amohd@osius.com,rvenkataramani@osidigital.com,smudunuri@osidigital.com,spradhan@osidigital.com,abvemula@osidigital.com,cbanuka@osidigital.com,dkasireddy@osidigital.com
fi

