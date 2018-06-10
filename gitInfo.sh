#!/bin/bash

remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
pruned=true

ALL=false
BRANCH=$remote
FETCH=false
PRUNE=false

while true; do
  case "$1" in
    -a | --all ) ALL=true; shift ;;
    -f | --fetch ) FETCH=true; shift ;;
    -p | -fp | -pf | --prune ) PRUNE=true; shift ;;
    -af | -fa ) ALL=true; FETCH=true; shift ;;
    -ap | -pa ) ALL=true; PRUNE=true; shift ;;
    -b | --branch ) BRANCH="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ $PRUNE = true ]]; then
    git fetch -p
elif [[ $FETCH = true ]]; then
    git fetch
fi

print_status () {
    git branch -u $1 --quiet

    status=$(git status -sb -u no)
    name=$(echo $status | sed 's/^[^\.]*\.\.\.//;s/\s\[.*$//')
    ahead=$(echo $status | sed -r 's/^.*ahead//;s/(,.*)|].*$//')
    behind=$(echo $status | sed 's/^.*behind//;s/].*$//')

    printf "\e[39m%-27s" $name
    
    if [[ ${#status} -gt $((${#ahead} + 2)) ]]; then
        printf "\e[32m%4d ahead\e[39   " $ahead
    else
        if [[ ${#status} -le $((${#behind} + 2)) ]]; then
            printf "\e[94m       Up to date\e[39"
        else
            printf "\e[39m          \e[39"
        fi
    fi

    if [[ ${#status} -gt $((${#behind} + 2)) ]]; then
        printf "\e[31m%4d behind\e[39" $behind
    fi

    echo
}

print_status origin/master

if [[ $BRANCH != 'origin/master' ]]; then
    print_status $BRANCH
fi


for branch in $(git branch -r)
do
    if [[ $ALL = true && $branch != origin/master && $branch != origin/HEAD && $branch != '->' && $branch != $BRANCH ]]; then
        print_status $branch
    fi

    if [[ $branch = $remote ]]; then
        pruned=false
    fi
done


echo

if [[ $pruned = true && $remote != $(git rev-parse --abbrev-ref --symbolic-full-name @{u}) ]]; then
    echo -e "\e[31mRemote tracking branch $remote no longer exists. Will track master now.\e[39m"
    echo
    git branch -u origin/master
else
    git branch -u $remote --quiet
fi

git status -s