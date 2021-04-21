#! /bin/zsh

OIFS="$IFS"
IFS=$'\n'

CURRENT_YEAR=$(date +'%Y')
echo "Current year is ${CURRENT_YEAR}"

FILES=($(find "$(dirname "$PWD")" -type f | grep '\.swift'))
echo "Found ${#FILES[@]} files with .swift extension"

for f in "${FILES[@]}"
do
	sed -i "" "s/Copyright (c) [0-9]\{4\} Adyen N.V./Copyright (c) ${CURRENT_YEAR} Adyen N.V./g" "$f"
	if [ "$?" -eq "0" ]; 
	then
		
	else
		echo "Error encountered with ${f}"
	fi 
done

IFS="$OIFS"
