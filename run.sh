#!/bin/bash

DIR="$( cd "$( dirname "$0"  )" && pwd  )"


function geekbench3_run
{
    echo "======>Running Geekbench3, please wait for about one minute..."
    cd $DIR/geekbench3/dist/Geekbench-3.4.2-Linux
	CPU_INFO=`cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ":" '{print $2}'`
	echo "CPUINFO= $CPU_INFO"
	mkdir -p $DIR/result/raw/geekbench3
	DATE=`date +"%Y%m%d_%H%M%S"`
    RESULT=$DIR/result/raw/geekbench3/runlog-$DATE
    if [ ! -f $DIR/result/geekbench.csv ]
    then
        echo "date,cpu,int,float,mem,score,int_multi,float_multi,mem_multi,score_multi" > $DIR/result/geekbench.csv
    fi
    if [ ! -f $DIR/result/geekbench-avg.csv ]
    then
        echo "int,float,int_multi,float_multi,score,score_multi" > $DIR/result/geekbench-avg.csv
    fi
    ./geekbench_x86_64 -n | tee $RESULT
    
    int_s=`grep "Integer Score"        $RESULT | awk '{print $3}'` 
    int_m=`grep "Integer Score"        $RESULT | awk '{print $4}'`
    float_s=`grep "Floating Point Score" $RESULT | awk '{print $4}'` 
    float_m=`grep "Floating Point Score" $RESULT | awk '{print $5}'`
    mem_s=`grep "Memory Score"         $RESULT | awk '{print $3}'`
    mem_m=`grep "Memory Score"         $RESULT | awk '{print $4}'`
    score_s=`grep "Geekbench Score"      $RESULT | awk '{print $3}'`
    score_m=`grep "Geekbench Score"      $RESULT | awk '{print $4}'`
    #$DATE-$CPU_INFO $int_s $float_s $mem_s $score_s $int_m $float_m $mem_m $score_m
    echo "$DATE,$CPU_INFO,$int_s,$float_s,$mem_s,$score_s,$int_m,$float_m,$mem_m,$score_m" >> $DIR/result/geekbench.csv
    
    avg_int_s=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$3} END {print sum/NR}'`
    avg_float_s=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$4} END {print sum/NR}'`
    avg_int_m=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$7} END {print sum/NR}'`
    avg_float_m=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$8} END {print sum/NR}'`
    avg_score_s=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$6} END {print sum/NR}'`
    avg_score_m=`cat $DIR/result/geekbench.csv |grep -v '^d' |awk -F',' '{sum+=$10} END {print sum/NR}'`
    echo "$avg_int_s,$avg_float_s,$avg_int_m,$avg_float_m,$avg_score_s,$avg_score_m" >> $DIR/result/geekbench-avg.csv
    echo "===>geekbench3 run successful,result in $DIR/result/geekbench.csv,raw result in $DIR/result/raw/geekbench3..."
}

function stream_run
{
    CPU_NUM=`more /proc/cpuinfo | grep "processor"|wc -l`
    export OMP_NUM_THREADS=$CPU_NUM
    
    DATE=`date +"%Y%m%d_%H%M%S"`
    mkdir -p $DIR/result/raw/stream
    RESULT=$DIR/result/raw/stream/runlog-$DATE
    if [ ! -f $DIR/result/stream.csv ]
    then
        echo "Copy(MB/s),Scale,Add,Triad" > $DIR/result/stream.csv
    fi
    if [ ! -f $DIR/result/stream-avg.csv ]
    then
        echo "Copy(GB/s),Scale,Add,Triad" > $DIR/result/stream-avg.csv
    fi
    
    stream | tee $RESULT
    
    copy=`grep "Copy:"        $RESULT | awk -F " " '{print $2}'` 
    scale=`grep "Scale:"        $RESULT | awk -F " " '{print $2}'`
    add=`grep "Add:" $RESULT | awk -F " " '{print $2}'` 
    triad=`grep "Triad:" $RESULT | awk -F " " '{print $2}'`
    echo "$copy,$scale,$add,$triad" >> $DIR/result/stream.csv
    #copy_GB=`echo "scale=2;$copy/1024;" | bc`
    #scale_GB=`echo "scale=2;$scale/1024;" | bc`
    #add_GB=`echo "scale=2;$add/1024;" | bc`
    #triad_GB=`echo "scale=2;$triad/1024;" | bc`
    #echo "$copy_GB,$scale_GB,$add_GB,$triad_GB" >> $DIR/result/stream.csv
    
    avg_copy=`cat $DIR/result/stream.csv |grep -v '^C' |awk -F',' '{sum+=$1} END {print sum/(NR*1024)}'`
    avg_scale=`cat $DIR/result/stream.csv |grep -v '^C' |awk -F',' '{sum+=$2} END {print sum/(NR*1024)}'`
    avg_add=`cat $DIR/result/stream.csv |grep -v '^C' |awk -F',' '{sum+=$3} END {print sum/(NR*1024)}'`
    avg_triad=`cat $DIR/result/stream.csv |grep -v '^C' |awk -F',' '{sum+=$4} END {print sum/(NR*1024)}'`
    echo "$avg_copy,$avg_scale,$avg_add,$avg_triad" >> $DIR/result/stream-avg.csv  
}

function unixbench_run
{
    chmod -R 755 $DIR/UnixBench
    cd $DIR/UnixBench
    DATE=`date +"%Y%m%d_%H%M%S"`
    mkdir -p $DIR/result/raw/unixbench
    unixbench_log=$DIR/result/raw/unixbench/runlog-$DATE
    ./Run | tee $unixbench_log
    result=`grep "System Benchmarks Index Score" $unixbench_log | awk '{print $5}'`
    echo $result >> $DIR/result/unixbench.csv
    
}

function all_run
{
    #1.netperf/qperf run
    #net_run
    
    #2.run geekbench3
    geekbench3_run
    
    #3.run fio
    #fio_run
    
    #4.run stream
    stream_run
    
    #5.run unixbench
    #unixbench_run
}

mkdir -p $DIR/result/raw
all_run
