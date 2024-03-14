#!/bin/bash 

family=$1
numRevisions=$(aws ecs list-task-definitions --family-prefix ${family}  --sort DESC --query 'length(taskDefinitionArns)')
lastRevision=$(aws ecs list-task-definitions --family-prefix ${family}  --sort DESC --query 'taskDefinitionArns[0]' |  jq -r 'split(":") | last')
firstRevision=$(aws ecs list-task-definitions --family-prefix ${family} --sort ASC --query 'taskDefinitionArns[0]' |  jq -r 'split(":") | last')
if [ "$numRevisions" -gt 10 ]; then
    aws ecs deregister-task-definition --task-definition ${family}:${firstRevision}  > /dev/null
fi
