#!/bin/bash

CK_HOME=`pwd`

username=monitor
key="$CK_HOME/key/id_rsa.hc"
check_shell="gen_node_report"

mkdir -p ./reports_`date +%Y%m%d`

cat checklist.txt  |grep -v "^#" |grep -v "^$" |awk '{print $1}' | while read ip
do
echo $ip
scp -i $key -o StrictHostKeyChecking=no $CK_HOME/tools/$check_shell $username@$ip:~/
ssh -tt -n -i $key -o StrictHostKeyChecking=no $username@$ip "./$check_shell"
scp -i $key -o StrictHostKeyChecking=no $username@$ip:~/healcheck_report_*.tgz ./reports_`date +%Y%m%d`
done

cp $CK_HOME/tools/report_head.csv $CK_HOME/reports_`date +%Y%m%d`/report_`date +%Y%m%d`.csv
cd $CK_HOME/reports_`date +%Y%m%d`
ls *.tgz | xargs -i tar xzvf {}
find ./ -name healcheck_report | xargs -i cat {} >> report_`date +%Y%m%d`.csv
cd -

