#!/bin/bash
#
# Script        :system_data_reader.sh
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Description   :Script to parse logs from system sar already collected data.
#                Useful to analyse the overall performance of a server. Note it doesn't collect
#                data in real time like data_collector.sh. This script just reads the sa* files
#                on your system (usually located under /var/log/sysstat), parses the info and generates
#                the graphs calling the script plotter.sh
# Dependencies  :sysstat,gnuplot
# Usage         :1)Give executable permissions to script -> chmod +x system_data_reader.sh
#                2)Execute script -> ./system_data_reader.sh
# License       :GPLv3
#

# ======================
# VARIABLES
# ======================

# To display time in 24h format
export LC_TIME="POSIX"
sysstat_logdir="/var/log/sysstat"

# ======================
# FUNCTIONS
# ======================

dump_sar_info(){
	# CPU
	sar -u -f $sysstat_logdir/$sa_file | grep -v -E "CPU|Average|^$" > data/cpu.dat &
	# RAM
	sar -r -f $sysstat_logdir/$sa_file | grep -v -E "[a-zA-Z]|^$" > data/ram.dat &
	# Swap
	sar -S -f $sysstat_logdir/$sa_file | grep -v -E "[a-zA-Z]|^$" > data/swap.dat &
	# Load average
	sar -q -f $sysstat_logdir/$sa_file | grep -v -E "[a-zA-Z]|^$" > data/loadaverage.dat &
	# IO transfer
	sar -b -f $sysstat_logdir/$sa_file | grep -v -E "[a-zA-Z]|^$" > data/iotransfer.dat &
	# Process/context switches
	sar -w -f $sysstat_logdir/$sa_file | grep -v -E "[a-zA-Z]|^$" > data/proc.dat &
}

check_sa_file(){
	if [ ! -f "$sysstat_logdir/$sa_file" ];then
		echo ""
		echo "ERROR: The file ${sysstat_logdir}/${sa_file} does not exist"
		echo "Please select a valid \"sa\" file from the list"
		exit 1
	fi
}

how_to_use(){
	echo "This script works without parameters. Just give execution permissions and launch with -> ./system_data_reader.sh"
}

# ======================
# MAIN
# ======================

if [ $# -ne 0 ];then
	how_to_use
else
	echo "List of sa* files available at this moment to retrieve data from:"
	echo ""
	echo "-------------------------------------------"
	for file in $(ls $sysstat_logdir | grep -v sar);do
		echo "File $file with data from $(sar -r -f $sysstat_logdir/$file | head -1 )";
	done
	echo "-------------------------------------------"
	echo ""
	echo "Note that the number that follows the \"sa\" file specifies the day of the data collected by sar daemon"
	echo -n "Please select a sa* file from the listed above: "
	read sa_file

	# Check if the selected sa_file exists
	check_sa_file

	# Dump data contained in selected sar file
	dump_sar_info

	# Call plotter.sh to generate the graphs
	./plotter.sh
fi
