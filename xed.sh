#!/usr/bin/env bash

${1:?"Set file for editing or type --help for help"}

if [ "$1" = "--help" ]
then
  cat <<EOF
Usage:
  edit file.name

Commands:
  e      - edit line, type new line for replace current
  r      - remove line
  i      - insert new line
  x/q    - save changes and exit
  ^c     - abort and exit without saving
  Eneter - skip line and go to next
EOF
  exit
fi

if [ ! -f "$1" ]
then
  echo "File $1 not exists!"
  exit 1
fi



echo -n > tmp.file

cmd="s"
starteditline=${2:-1}
line=$starteditline
i=0

mapfile -t rows < "$1"

for row in "${rows[@]}"
do
  if (( 0 < starteditline ))
  then
    ((i++))
    if (( i < starteditline ))
    then
      echo "$row" >> tmp.file
      continue
    fi
  fi

  echo -ne "\e[91m"; printf "%03d" $line; echo -e "\e[95m $row \e[39m"

  if [[ $cmd = [xq] ]]
  then
    echo "$row" >> tmp.file
  else
    read -n 1 -s cmd
    case $cmd in
      "e")
        echo -ne "\e[33m" ; read -r -p "  : " replace ; echo -ne "\e[39m"
        echo "${row//*/$replace}" >> tmp.file
        ;;
      "r")
        echo -ne "\e[91m" ; printf "%03d" $line ; echo -e " line removed \e[39m"
        ;;
      "i")
        echo "$row" >> tmp.file
        echo -ne "\e[95m" ; read -r -p "new line: " newline ; echo -ne "\e[39m"
        echo "$newline" >> tmp.file
        ;;
      *)
        echo "$row" >> tmp.file
        ;;
    esac
  fi

  ((line++))
done

sed -i 's/^\\ / /g' tmp.file
cat tmp.file > "$1" && rm tmp.file

#EOF#
