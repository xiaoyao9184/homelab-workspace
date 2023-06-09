#!/bin/bash
current_path=$(pwd)
[[ -z "$mapping_stats" ]] && mapping_stats=${current_path}/../../git_stats.csv

while IFS="," read -r report prefix_date prefix_delimiter suffix_date suffix_delimiter repo name
do
    report=$(echo "$report" | tr -d '"' | tr -d '\r' )
    repo=$(echo "$repo" | tr -d '"' | tr -d '\r' )
    name=$(echo "$name" | tr -d '"' | tr -d '\r' )
    prefix_date=$(echo "$prefix_date" | tr -d '"' | tr -d '\r' )
    prefix_delimiter=$(echo "$prefix_delimiter" | tr -d '"' | tr -d '\r' )
    suffix_date=$(echo "$suffix_date" | tr -d '"' | tr -d '\r' )
    suffix_delimiter=$(echo "$suffix_delimiter" | tr -d '"' | tr -d '\r' )

    if [[ -z "$report" ]] || [[ -z "$repo" ]]
    then
        continue
    fi

    if [[ -z "$name" ]]
    then
        name=$(basename $repo)
    fi
    
    if [[ "$prefix_date" == "yes" ]]
    then
        date=$(date '+%Y-%m-%d')
        groupname="${date}${prefix_delimiter}${name}.html"
    fi

    if [[ "$suffix_date" == "yes" ]]
    then
        date=$(date '+%Y-%m-%d')
        groupname="${name}${suffix_delimiter}${date}.html"
    fi

    output=${report}/${groupname}
    filepath="$(dirname ${output})"
    filename="$(basename ${output})"
    mkdir -p ${filepath}

    echo "$repo -> $filepath -> $filename"
    echo ""
    docker run \
        --rm \
        -t \
        -v ${repo}:/git-projects/${name} \
        -v ${filepath}:/output-reports/${name} \
        -e GITINSPECTOR_PATH_GIT=/git-projects/${name} \
        -e GITINSPECTOR_PATH_OUTPUT=/output-reports/${name}/${filename} \
        -e GITINSPECTOR_CONFIG_FORMAT=html \
        -e GITINSPECTOR_CONFIG_TIMELINE=true \
        -e GITINSPECTOR_CONFIG_LOCALIZE_OUTPUT=true \
        -e GITINSPECTOR_CONFIG_WEEKS=true \
        xiaoyao9184/docker-gitinspector:latest

done < <(tail -n +2 ${mapping_stats})

