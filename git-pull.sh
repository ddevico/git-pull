#!/bin/bash
#==============================================================================
#title           :git-pull.sh
#description     :This script will make a git fetch & git pull for a git branch.
#author		 :Davy Devico
#date            :2018-08-03
#version         :1.2
#usage		 :sh git-pull.sh
#notes           :Install gr to use this script.
#==============================================================================

OPTION="auto"
BRANCH=""

function changeNameGlobal()
{
	NEW_VALUE="\"$1\""
	NAME_GLOBAL=$2
	sed_param=s/${NAME_GLOBAL}=\".*/${NAME_GLOBAL}=${NEW_VALUE}/
	echo "foo" | sed -i $SCRIPTPATH/git-pull.sh -e "$sed_param" 2> /dev/null
	return=$?
	if [[ $return != 0 ]]; then
			echo -e "An error has occurred"
			exit
	fi
}

function getNameOfBranch()
{
	arr=("$@")
	tLen=${#arr[@]}
	branch=${arr[$i]##*=}
}

function getMaxFromBranch()
{
	arr=("$@")
	tlen=${#arr[@]}
	for ((i=0; i<$tlen; i+=1))
	do
		tab2[$i]=${arr[$i]##*-}
	done
	max=${tab2[0]}
	for n in "${tab2[@]}" ; do
		if [[ n > max ]]; then
			max=$n
		fi
	done
}

function autoMode()
{
	symbolic=$(gr git symbolic-ref HEAD --short 2> /dev/null)
	i=0
	for ligne in $symbolic; do
		if [ $ligne != "in" ]; then
			tab[$i]=$ligne
			i=$((i + 1))
		fi
	done
	tLen=${#tab[@]}
	
	trbInc=0
	releaseInc=0
	for ((i=2; i<$tLen; i+=3))
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
		fi
	else
		getMaxFromBranch "${trb[@]}"
		echoBranch="trb-bbt-release-"$max
		BRANCH=$echoBranch
	fi
}

SCRIPT="$(readlink --canonicalize-existing "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
cd $SCRIPTPATH

if [ ! -z "$1" ]; then
	if [[ $1 = '--help' ]]; then
		if [[ $OPTION = "auto" ]]; then
			autoMode
			echo -e "You are in \033[0;36mauto mode\033[0m on the branch \033[0;33m"$BRANCH"\033[0m\n\nTo switch to manual mode, use the -manual='name of branch' option :\n./git-pull -manual='name of branch'"
		else
			echo -e "You are in\033[0;36m manual mode\033[0m on the branch \033[0;33m"$BRANCH"\033[0m\n\nTo switch to auto mode, use the -auto option :\n./git-pull -auto"
		fi
		exit
	elif [[ $1 =~ ^-manual=[[:print:]]+ ]]; then
		changeNameGlobal "manual" "OPTION"
		getNameOfBranch "$1"
		changeNameGlobal "$branch" "BRANCH"
		echo -e "\033[0;36mManual mode\033[0m enabled\n\nyou have selected : \033[0;33m"$branch"\033[0m"
		exit
	elif [[ $1 = '-auto' ]]; then
		changeNameGlobal "auto" "OPTION"
		changeNameGlobal "" "BRANCH"
		autoMode
		echo -e "\033[0;36mAuto mode\033[0m enabled\n\nthe branch that will be pull is :\033[0;33m"$BRANCH"\033[0m"
		exit
	else
		echo -e "This option does not exist.\n--help for more informations"
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
tLen=${#tab[@]}

if [[ $OPTION = "auto" ]]; then
	autoMode
fi

printf "\033[0;33m\n__________________ GIT CHECKOUT TRB_BBT __________________\n"
gr git checkout $BRANCH
printf "\033[0;33m\n_______________________ GIT FETCH ________________________\n"
gr git fetch
printf "\033[0;33m\n________________ GIT PULL ORIGIN TRB_BBT _________________\n"
gr git pull origin $BRANCH
printf "\033[0;33m\n______________________ RETURN BRANCH _____________________\033[0m\n\n"

j=2
for ((i=1; i<$tLen; i+=3))
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
