#!/usr/bin/env bash

# Init variables
account_name="$1"
# file_config_account="./config_$account_name"
# file_config_current="./config_current"
# file_config_output="./config"
# file_config_local="${HOME}/.ssh/config"
# file_config_backup="${HOME}/.ssh/config_backup"

file_current_name="./config_current"
file_account_name="config_nearsoft" # + account
file_config_output="config"

# Creating lists
declare -a list_file_current    # listTXT1
declare -a list_file_account    # listTXT2
block=""
endBlock=false 

###########################
# Read a file liby by line
########################### IFS= 
count_line=1
input_original="${file_current_name}"
while IFS= read -r line
do
    
    original_line=$line
    formatted_line=`echo ${line} | sed 's/ //g'`

    # echo "Line: [${count_line}]--'${formatted_line}'"
    # echo "${original_line} --Original"
    # echo "${formatted_line} --Formatted"

    if [ "$formatted_line" == "" ]; then
        echo "Empty line: $count_line"
        echo $block
        endBlock=true

    elif $endBlock ; then  # is the same like [$endBlock = true]
        
        block="${block}"

        endBlock=false
        
        echo "***END***"

        echo $block

        list_file_current=("${list_file_current[@]}" "${block}")
        echo "Length list: ${#list_file_current[@]}"

        # Clean variable
        block=""
        block="${formatted_line}"
    else
        # Se va armando el bloque
        block="${block}${formatted_line}"
        
        # echo "######"
        # echo $block

    fi

    # Agregar la ultima linea despues del vacio
    
    count_line="`expr $count_line + 1`"
done < "${input_original}"

echo $block
echo $formatted_line

if [ "$formatted_line" == "" ]; then
    echo "***FINAL***"
    echo $block
    list_file_current=("${list_file_current[@]}" "${block}")
fi

echo "Length list: ${#list_file_current[@]}"
echo "${list_file_current[@]}"
























# echo $block
# echo ${list_file_current[@]}

# COUNT=0
# for index in ${list_file_current[@]}; do
#     echo $COUNT

#     echo "Index: ${COUNT} --> ${list_file_current[COUNT]}"
#     COUNT="`expr $COUNT + 1`"
# done

# echo ${formatted_line[@]}

# remove all spaces between words
# echo $string | sed 's/ //g' 
# formatted=`echo $string | sed 's/ //g'`




