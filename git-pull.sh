#!/bin/bash
#==============================================================================
#title           :git-pull.sh
#description     :This script will make a git fetch & git pull for a git branch.
#author		 :Davy Devico
#date            :2018-08-03
#version         :1.1
#usage		 :sh git-pull.sh
#notes           :Install gr to use this script.
#==============================================================================

#BRANCH="trb-bbt-release-1806"

function getMaxFromBranch()
{
	arr=("$@")
	for ((i=0; i<$tLen; i+=1))
	do
		tab[$i]=${arr[$i]##*-}
	done
	max=${tab[0]}
	for n in "${tab[@]}" ; do
	    ((n > max)) && max=$n
	done
}

symbolic=$(gr git symbolic-ref HEAD --short 2> /dev/null)
i=0
for ligne in $symbolic; do
	if [ $ligne != "in" ]; then
		tab[$i]=$ligne
		i=$((i + 1))
	fi
done

tlen=${#tab[@]}
trbInc=0
releaseInc=0
for ((i=2; i<$tlen; i+=3))
do
	if [[ ${tab[$i]} =~ ^trb-[a-z]{3}-release-[0-9]{4}$ ]]; then
		trb[$trbInc]=${tab[$i]}
		#echo ${trb[$trbInc]}
		trbInc=$((trbInc + 1))
	fi
	if [[ ${tab[$i]} =~ ^release-[0-9]{4}$ ]]; then
		release[$releaseInc]=${tab[$i]}
		#echo ${release[$releaseInc]}
		releaseInc=$((releaseInc + 1))
	fi
done
if [ -z "$trb" ]; then
    if [ -z "$release" ]; then
		$BRANCH="master"
	else
		getMaxFromBranch "${release[@]}"
		BRANCH="release-"$max
		echo $BRANCH
	fi
else
	getMaxFromBranch "${trb[@]}"
	BRANCH="trb-bbt-release-"$max
	echo $BRANCH
fi

SCRIPT="$(readlink --canonicalize-existing "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
cd $SCRIPTPATH

printf "\n______________ GIT CHECKOUT TRB_BBT ______________\n"
gr git checkout $BRANCH
printf "\n___________________ GIT FETCH ____________________\n"
gr git fetch
printf "\n____________ GIT PULL ORIGIN TRB_BBT _____________\n"
gr git pull origin $BRANCH
printf "\n__________________ RETURN BRANCH _________________\n\n"

j=2
for ((i=1; i<$tlen; i+=3))
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
