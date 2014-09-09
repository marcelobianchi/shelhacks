#!/bin/bash

## Color table
#
red=$(echo -e "\e[31m")
yellow=$(echo -e "\e[33m")
bold=$(echo -e "\e[;1m")
reset=$(echo -e "\e[m")

function help() {
cat <<EOF

${bold}doall.sh${reset}: Make scripts for SeismicHandler data processing
          Marcelo Bianchi <m.bianchi@iag.usp.br>

Usage: ${bold}doall.sh${reset} <Pattern> <Code> [Mode]
	
    Pattern: Is a file pattern without the QBN extenssion
    Code   : Is the SHC code. With language encoding like:
               '${red}]${reset}' is a new line
               '${red}\${name}${reset}' is substituted by the filename beeing generated
               '${red}\${nc}${reset}'   is the number-sequence auto-generated per file processed starting at 1
    Mode   : Is optional mode, 'S' for Script , 'C' for command line version, default is 'C'

Example:

    % ${bold}doall.sh${reset} '${yellow}*${reset}' '${yellow}del all]do \${name}${reset}' '${yellow}S${reset}'

EOF
}

###
## Parameter check
#

[ $# -eq 0 -o "$1" == "-h" -o "$1" == "--help" ] && help && exit 0

[ -z "$1" ] && echo "No pattern found." && exit 1
pattern="$1" && shift

[ -z "$1" ] && echo "No code found." && exit 1 
code=$(echo $1 | sed -e 's/"/\\"/g' | sed -e 's/#/\\#/g' | sed -e 's/(/\\(/g' | sed -e 's/;/\\;/g' | sed -e 's/)/\\)/g') && shift

[ -z "$1" ] && mode=C || mode="$1"

[ $mode != 'C' -a $mode != 'S' ] && echo "Invalid mode." && exit 1

### 
## Main Code
#

nc=0
for i in $(ls -1 $pattern.QBN)
do
	name=$(basename $i .QBN)
	cat << EOF | tr "]" "\n"
del all
del h:all
read $name all
$(eval echo $code)

EOF
	nc=$(( nc + 1 ))
done
[ $mode == 'C' ] && echo "quit y" && exit
[ $mode == 'S' ] && echo "return" && exit
