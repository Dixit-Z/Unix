#!/bin/bash

###############################################################################################################################################################################
#~ 													Anti Plagiat - TRINTA Bruno - IATIC3 - Projet UNIX
###############################################################################################################################################################################
function make_it_pretty(){
	sed -i "s/^tmp_//" $1 			#You don't want to confuse the user with some "tmp_" in his final record, ok?
	sed -i "s/-\ tmp_/-\ /" $1 
}
function replace_var(){
	sed -i "s/\$[^\ ]*\ /#\ /g"	$1	#For all variables in the line but not at the end of the line. Replace all the carac after $ until a space is found
	sed -i "s/\$[^\ ]*$/#\ /" $1	#For variables at the end of the line. Replace caracs after $ until the end of the line
}

function del_comm(){
	sed -i "s/#.*//" $1
}

function del_spaces(){
	sed -i "s/\ \ */\ /g" $1 		#Remove multiple space
	sed -i "s/\t\t*//" $1			#Remove all the tabs
	sed -i "s/^\ //" $1 			#Remove the first carac of a line if it's still a space (can't be more than one because of the first line)
	sed -i "s/\ $//" $1 			#It goes the same for the last carac
}

function oword_pline(){
	sed -i "s/\ /\\n/g" $1			#Replace a space by a return carriage
}

function del_empty_line(){
	sed -i "/^$/d" $1				#Remove the empty line, ^ for the beggining of the line, and $ for the end of the line.
}

function find_diff(){
	differences=`diff -a -y --suppress-common-lines $1 $2 | wc -l`	#-y allows to have 2 columns of the two files, we're removing the common lines, -a only text files.
	echo -e "$1 - $2 :\t\t $differences différences" >> ../rapport_differences				#writting the results in the file rapport_differences.
}

function compare_files(){
	for i in $*						#We have to compare all the args to the first one. Except itself, right?
	do
		if [[ $1 != $i ]]
		then
			find_diff $1 $i			#Are you even reading my comments ? Just kidding. Calling the function finding differences.
		fi
	done
	shift							#parameters from n+1 (here 1) to $# become $1 to $# - n+1. Args before n+1 are lost.
	if [[ $# > 1 ]]					#Calling this function til we have at least 2 args.
	then
		compare_files $*
	fi
}

function formating_files(){
	del_comm $1
	replace_var $1
	del_spaces $1
	oword_pline $1
	del_empty_line $1
	del_spaces $1					#Because of the tabs
	sort $1 -o $1					#We're now sorting the file so we don't care about the original disposal of the function and stuff
}

function existing_files(){
	for i in $*
	do
		if [[ ! -f $i ]]				#If one the file doesn't exist, we close the program
		then
		echo "Le fichier < $i > n'existe pas. Veuillez réessayer."
		exit 0;
		fi
	done
}

function sort_by_difference(){
	sort -t : -k2 rapport_differences -o rapport_differences		#Sort the final result in ascending order
}

echo "We are saving the genuine scripts in the directory saves. By doing this we can assure you that you won't lose any kind of information. Thank you."

if [[ ! -d saves ]]
then
	mkdir saves
fi

if [[ -d tmp ]]
then
	rm -fr tmp
	mkdir tmp
else
	mkdir tmp
fi

if [[ -f rapport_differences ]]
then
	>rapport_differences
else
	touch rapport_differences
fi

if [[ $# < 2 ]]
then
	echo "I can't compare only one file or less."
	exit 0
else
	existing_files $*
	for i in $*
	do
		cp $i saves/saved_$i
		cp $i tmp/tmp_$i
		formating_files tmp/tmp_$i
	done
fi

cd tmp	
compare_files `ls`
cd ..
rm -r tmp
sort_by_difference
make_it_pretty rapport_differences
cat rapport_differences
