#!/bin/bash

set +ex

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[0;92m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

main_domains=(
	# "dubizzle.com.lb" # This was set to AWS
	"dubizzle.com.eg"
	"dubizzle.com.bh"
	"dubizzle.com.kw"
	"dubizzle.com.om"
	"dubizzle.sa"
	"dubizzle.jo"
	"dubizzle.qa"
)

secondary_domains=(
	"dubizzle.eg"
	"dubizzle.bh"
	"dubizzle.sa.com"
	"dubizzle.com.jo"
	"dubizzle.com.qa"
	"dubizzle.com.pk"
	"dubizzle.pk"
)

printf '|----------------------|----------------------|----------------------|----------------------|\n'
printf "| %20s | %20s | %20s | %20s |\n" "Domain" "1.1.1.1" "8.8.8.8" "8.8.4.4"
printf '|----------------------|----------------------|----------------------|----------------------|\n'

function code_to_str() {
	if [ $1 -gt 0 ]; then
		echo -e -n "${RED}FAIL${NC}"
	else
		echo -e -n "${GREEN}OK${NC}"
	fi
}

add_color() {
	echo -e -n "${2}$1${NC}"
}

verify_list() {
	local color=$1
	local ns=$2
	shift 2
	local arr=("$@")
	for i in "${arr[@]}"
	do
		dig +short @1.1.1.1 NS $i | grep $ns > /dev/null
		cloudflare_resp="$(code_to_str $?)"
		dig +short @8.8.8.8 NS $i | grep $ns > /dev/null
		google1_resp="$(code_to_str $?)"
		dig +short @8.8.4.4 NS $i | grep $ns > /dev/null
		google2_resp="$(code_to_str $?)"

		colored_domain="$(add_color $i $color)"

		printf "| %31s | %31s | %31s | %31s |\n" $colored_domain $cloudflare_resp $google1_resp $google2_resp
	done
}

verify_list $LIGHT_GREEN "dubizzledns.net" "${main_domains[@]}" 
verify_list $YELLOW "ns.cloudflare.com" "${secondary_domains[@]}"

printf '|----------------------|----------------------|----------------------|----------------------|\n'
