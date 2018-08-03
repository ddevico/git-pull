#!/bin/bash
#==============================================================================
#title           :git-pull.sh
#description     :This script will make a git fetch & git pull for a git branch.
#author		 :Davy Devico
#date            :2018-08-03
#version         :1.0    
#usage		 :sh git-pull.sh
#notes           :Install gr to use this script.
#==============================================================================

BRANCH="trb-bbt-release-1806"

i=0
j=2
cd $(pwd)
symbolic=$(gr git symbolic-ref HEAD --short 2> /dev/null)
for ligne in $symbolic; do
	if [ $ligne != "in" ]; then
		tab[$i]=$ligne
		i=$((i + 1))
	fi
done
cpt=${#tab[@]}
printf "\n______________ GIT CHECKOUT TRB_BBT ______________\n"
gr git checkout $BRANCH
printf "\n___________________ GIT FETCH ____________________\n"
gr git fetch
printf "\n____________ GIT PULL ORIGIN TRB_BBT _____________\n"
gr git pull origin $BRANCH
printf "\n__________________ RETURN BRANCH _________________\n\n"
for ((i=1; i<$cpt; i+=3))
do
	path=$(basename ${tab[$i]})
	path=`echo $path | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"`
	initialBranch=${tab[$j]}
	printf "%s\n" $path
	cd $path
	git checkout $initialBranch
	cd ..
	printf "\n"
	j=$((3 + j))
done
