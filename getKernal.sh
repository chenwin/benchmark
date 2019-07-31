#!/bin/sh
save_sys_para(){
    echo $1=$(cat "/proc/sys/"$(echo  $1 | sed 's/\./\//g'))
}

save_para(){
    echo $1=$(cat $1)
}


while read line
do
    save_sys_para $line
done < kernel.para


fdisk -l | grep Disk | grep dev | awk -F: '{print $1}' | awk -F/ '{print $3}' > diskinfo.txt

while read disk
do
    save_para /sys/block/$disk/queue/scheduler
    save_para /sys/block/$disk/queue/max_segments
    save_para /sys/block/$disk/queue/max_sectors_kb
done < diskinfo.txt

rm diskinfo.txt

for CPUID in $(ls "/proc/sys/kernel/sched_domain")
do
  save_para /sys/devices/system/cpu/$CPUID/cpufreq/scaling_available_governors
  for domainid in $(ls "/proc/sys/kernel/sched_domain/$CPUID")
  do
    save_sys_para kernel.sched_domain.$CPUID.$domainid.busy_factor
    save_sys_para kernel.sched_domain.$CPUID.$domainid.busy_idx
    save_sys_para kernel.sched_domain.$CPUID.$domainid.cache_nice_tries
    save_sys_para kernel.sched_domain.$CPUID.$domainid.flags
    save_sys_para kernel.sched_domain.$CPUID.$domainid.forkexec_idx
    save_sys_para kernel.sched_domain.$CPUID.$domainid.idle_idx
    save_sys_para kernel.sched_domain.$CPUID.$domainid.imbalance_pct
    save_sys_para kernel.sched_domain.$CPUID.$domainid.max_interval
    save_sys_para kernel.sched_domain.$CPUID.$domainid.min_interval
    save_sys_para kernel.sched_domain.$CPUID.$domainid.name
    save_sys_para kernel.sched_domain.$CPUID.$domainid.newidle_idx
    save_sys_para kernel.sched_domain.$CPUID.$domainid.wake_idx
  done
done

cmd=`ifconfig eth0`
if [ -n cmd ];then
  net="eth0"
else
  net="eth0"
fi

save_sys_para net.ipv4.conf.$net.accept_local
save_sys_para net.ipv4.conf.$net.accept_redirects
save_sys_para net.ipv4.conf.$net.accept_source_route
save_sys_para net.ipv4.conf.$net.arp_accept
save_sys_para net.ipv4.conf.$net.arp_announce
save_sys_para net.ipv4.conf.$net.arp_filter
save_sys_para net.ipv4.conf.$net.arp_ignore
save_sys_para net.ipv4.conf.$net.arp_notify
save_sys_para net.ipv4.conf.$net.bootp_relay
save_sys_para net.ipv4.conf.$net.disable_policy
save_sys_para net.ipv4.conf.$net.disable_xfrm
save_sys_para net.ipv4.conf.$net.force_igmp_version
save_sys_para net.ipv4.conf.$net.forwarding
save_sys_para net.ipv4.conf.$net.log_martians
save_sys_para net.ipv4.conf.$net.mc_forwarding
save_sys_para net.ipv4.conf.$net.medium_id
save_sys_para net.ipv4.conf.$net.promote_secondaries
save_sys_para net.ipv4.conf.$net.proxy_arp
save_sys_para net.ipv4.conf.$net.proxy_arp_pvlan
save_sys_para net.ipv4.conf.$net.route_localnet
save_sys_para net.ipv4.conf.$net.rp_filter
save_sys_para net.ipv4.conf.$net.secure_redirects
save_sys_para net.ipv4.conf.$net.send_redirects
save_sys_para net.ipv4.conf.$net.shared_media
save_sys_para net.ipv4.conf.$net.src_valid_mark
save_sys_para net.ipv4.conf.$net.tag

save_sys_para net.ipv4.neigh.$net.anycast_delay
save_sys_para net.ipv4.neigh.$net.app_solicit
save_sys_para net.ipv4.neigh.$net.base_reachable_time
save_sys_para net.ipv4.neigh.$net.base_reachable_time_ms
save_sys_para net.ipv4.neigh.$net.delay_first_probe_time
save_sys_para net.ipv4.neigh.$net.gc_stale_time
save_sys_para net.ipv4.neigh.$net.locktime
save_sys_para net.ipv4.neigh.$net.mcast_solicit
save_sys_para net.ipv4.neigh.$net.proxy_delay
save_sys_para net.ipv4.neigh.$net.proxy_qlen
save_sys_para net.ipv4.neigh.$net.retrans_time
save_sys_para net.ipv4.neigh.$net.retrans_time_ms
save_sys_para net.ipv4.neigh.$net.ucast_solicit
save_sys_para net.ipv4.neigh.$net.unres_qlen
save_sys_para net.ipv4.neigh.$net.unres_qlen_bytes

for rx_tx in $(ls "/sys/class/net/$net/queues/")
do
  if [[ $rx_tx == rx-* ]];then
    save_para /sys/class/net/$net/queues/$rx_tx/rps_cpus
    save_para /sys/class/net/$net/queues/$rx_tx/rps_flow_cnt
  fi
done
echo "open files"=$(ulimit -a |grep "open files" |awk '{ print $4 }')
echo "max user processes"=$(ulimit -a |grep "max user processes" |awk '{ print $5 }')
echo "message queues"=$(ulimit -a |grep "message queues" |awk '{ print $6 }')
ipcs -l

