#init write
sh diskbench.sh -d /dev/vdb,/dev/vdc,/dev/vdd,/dev/vde,/dev/vdf,/dev/vdg,/dev/vdh,/dev/vdi,/dev/vdj,/dev/vdk -p testcases-init.txt
sleep 300

#test single disk,just one dev
sh diskbench.sh -d /dev/vdb -p testcases-mapr6.txt
sleep 30

for i in `seq 3`;
do
  sh diskbench.sh -d /dev/vdb,/dev/vdc,/dev/vdd,/dev/vde,/dev/vdf,/dev/vdg,/dev/vdh,/dev/vdi,/dev/vdj,/dev/vdk -p testcases-mapr6.txt
  if [[ $i < 3 ]];then
    sleep 300
  fi
done
