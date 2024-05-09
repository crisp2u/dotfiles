#!/bin/bash

GROUP=$1

if [[ $GROUP == "" ]]; then
	echo "USAGE: $0 app_group"
	exit 1;
fi 

echo "Fetching cluster nodes..."
nodes=$(kubectl get no -o json)

taints=(
	"monitoring"
	"ops"
	"whatsapp"
	"ovation"
	"strat"
	"strat-web"
	"strat-workers"
	"auth"
)

for t in "${taints[@]}" ; do
    taint_nodes=$(echo $nodes | jq -r ".items[] | select(.metadata.labels | has(\"eks-module/version\") | not) | select(.metadata.labels | .[\"$GROUP/group\"] == \"$t\") | .metadata.name" | xargs)
    
    if [[ $taint_nodes == "" ]]; then
    	echo "No nodes found for taint $t."
	else
	    echo "Found nodes for group taint $t: [$taint_nodes]"
		for tn in ${taint_nodes}; do
			read -p "Do you want to drain ${t} node with hostname (${tn}) [y/N] " ans

			case $ans in
				[yY] ) echo "Draining node";
						kubectl drain $tn --delete-local-data --ignore-daemonsets --force;
						;;
				* ) echo "Skiping node ${tn}..."
						;;
			esac
		done
	fi
done