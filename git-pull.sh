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

OPTION="manual"
BRANCH="release-1806"

function changeNameGlobal()
{
	NEW_VALUE="\"$1\""
	NAME_GLOBAL=$2
	sed_param=s/${NAME_GLOBAL}=\".*/${NAME_GLOBAL}=${NEW_VALUE}/
	sed -i $SCRIPTPATH/git-pull.sh -e "$sed_param"
}

function getNameOfBranch()
{
	arr=("$@")
	tLen=${#arr[@]}
	branch=${arr[$i]##*=}
	changeNameGlobal "$branch" "BRANCH"
}

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

SCRIPT="$(readlink --canonicalize-existing "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
cd $SCRIPTPATH

if [ ! -z "$1" ]; then
	if [[ $1 = '--help' ]]; then
		if [[ $OPTION = "auto" ]]; then
			echo -e "You are in automatic mode.\n\nTo switch to manual mode, use the -manual='name of branch' option :\n./git-pull -manual='name of branch'"
		else
			echo -e "You are in manual mode on "$BRANCH"\n\nTo switch to auto mode, use the -auto option :\n./git-pull -auto"
		fi
		exit
	elif [[ $1 =~ ^-manual=[[:print:]]+ ]]; then
		changeNameGlobal "manual" "OPTION"
		getNameOfBranch "$1"
		echo -e "Manual mode enabled\nyou have selected : "$branch
		exit
	elif [[ $1 = '-auto' ]]; then
		changeNameGlobal "auto" "OPTION"
		changeNameGlobal "" "BRANCH"
		echo "Auto mode enabled"
		exit
	else
		echo -e "This option does not exist.\n-help for more informations"
		exit
	fi
fi

symbolic=$(gr git symbolic-ref HEAD --short 2> /dev/null)
i=0
for ligne in $symbolic; do
	if [ $ligne != "in" ]; then
		tab[$i]=$ligne
		i=$((i + 1))
	fi
done
tlen=${#tab[@]}

if [[ $option = "auto" ]]; then
	trbInc=0
	releaseInc=0
	for ((i=2; i<$tlen; i+=3))
	do
		if [[ ${tab[$i]} =~ ^trb-[a-z]{3}-release-[0-9]{4}$ ]]; then
			trb[$trbInc]=${tab[$i]}
			trbInc=$((trbInc + 1))
		fi
		if [[ ${tab[$i]} =~ ^release-[0-9]{4}$ ]]; then
			release[$releaseInc]=${tab[$i]}
			releaseInc=$((releaseInc + 1))
		fi
	done
	if [ -z "$trb" ]; then
	    if [ -z "$release" ]; then
			echoBranch="master"
			BRANCH=$echoBranch
		else
			getMaxFromBranch "${release[@]}"
			echoBranch="release-"$max
			BRANCH=$echoBranch
			echo $BRANCH
		fi
	else
		getMaxFromBranch "${trb[@]}"
		echoBranch="trb-bbt-release-"$max
		BRANCH=$echoBranch
		echo $BRANCH
	fi
fi

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
