#!/bin/bash

DIR="$( cd "$( dirname "$0"  )" && pwd  )"

########################################
#                                      #
#            Install                   #
#                                      #
########################################

function base_config
{
    yum -y install unzip tar make gcc bc 
    echo Y | apt-get install unzip tar automake make gcc expect
    chmod 755 $DIR/*.sh
    sh getKernal.sh > $DIR/result/kernel.txt
}

# Step 1 : Install Geekbench3

function geekbench3_install
{
    cd $DIR/geekbench3
  
	if [ -f dist -o -d dist ]; then
        rm -rf dist
    fi
    tar -xvf Geekbench-3.4.2-Linux.tar.gz
    cd dist/Geekbench-3.4.2-Linux
    ./geekbench_x86_64 -r lhcici521@163.com qpp6g-kq4el-bo72w-mdngp-2kcvx-eu2uq-gjrkp-l5q7r-qi36y
    ./geekbench_x86_64 --sysinfo
    if [ $? -eq 0 ]; then
        echo -e "\n===> Checked, Geekbench installed successed(Geekbench3)...(^^)"
    fi
}

# Step 2 : Install fio
function fio_install
{
    cp $DIR/fio /usr/bin/
    chmod 755 /usr/bin/fio
    echo "===>fio install success(^^)"
}
	

# Step 3 : Install netperf/qperf


# Step 4 install stream

function stream_install
{
    cd $DIR/stream
    gcc -O3 -fopenmp -DSTREAM_ARRAY_SIZE=64000000 -DNTIME=20 -o stream stream.c
    chmod 755 stream
    cp stream /usr/bin/
    echo "===>stream install success"
}

# Step 5 install UnixBench

function unixbench_install
{
    cd $DIR
    rm -rf $DIR/UnixBench
    tar -xvf $DIR/UnixBench.tar.gz
    cd $DIR/UnixBench
    make
    if [ $? -ne 0 ]
    then
        sed -i 's/-march=native//g' Makefile
        make clean
        make
    fi
    
    echo "===>UnixBench install success~"
}

function all_install
{
    #1.install geekbench3
    echo "======>Step 1 : install geekbench3"
    geekbench3_install
    
    #4.install stream
    echo "======>Step 4 : install stream" 
    stream_install   

    #5.install UnixBench
    #echo "=======>Step 5 : install UnixBench"
    #unixbench_install    
}

#########################################################################################
#1.Get info 
echo "=========>getting info ..."
mkdir -p $DIR/result
sh $DIR/getInfo.sh > $DIR/result/info.txt

#2.base config
echo "=========>base config"
base_config

curl --connect-timeout 3 -m 5 -s http://169.254.169.254/latest/meta-data/instance-type > $DIR/result/hw-flavor.txt&
curl --connect-timeout 3 -m 5 -s http://100.100.100.200/latest/meta-data/instance/instance-type > $DIR/result/ali-flavor.txt&

all_install
echo "===>!!!!!![NOTICE] : Please confirm that firewall is OFF and permit_root_login is on before running test"

