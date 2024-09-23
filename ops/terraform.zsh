# Terraform

# check_tunnel checks if a tunnel should be opened
# if it should (the .with-tunnel file exists), then it establish the connection and returns the host
# it exits with code 1 only if the tunnel cannot connect
check_tunnel() {
	if command -v tunnel.sh 1>/dev/null 2>&1; then
		local with_tunnel_file="${1:-".with-tunnel"}"

		if [ -f "$with_tunnel_file" ]; then
			local tunnel_data="$(cat $with_tunnel_file)"

			local host="$(echo $tunnel_data | awk '{print $1}')"
			local address="$(echo $tunnel_data | awk '{print $2}')"

			tunnel.sh open $host $address >/dev/null 2>&1
			if [ "$?" != "0" ]; then
				exit 1
			fi

			echo "$host"
		fi
	fi

	exit 0
}

# Terra*Wrapper
# Wrapper over any Terraform command that identifies the correct Terra-tool to use
# and also makes sure the environment is loaded correctly
function t() {
	if [ -f "terragrunt.hcl" ]; then
		command terragrunt "$@"
	else
		command terraform "$@"
	fi
}

# Terra*Wrapper Plan
function tp() {
	local host="$(check_tunnel)"
	if [ "$?" = "0" ]; then
		t plan -out=".terraform.plan" $@

		if command -v tunnel.sh 1>/dev/null 2>&1 && [ ! -z "$host" ]; then
			tunnel.sh close $host
		fi
	fi
}

# Terra*Wrapper Apply
function ta() {
	local host="$(check_tunnel)"
	if [ "$?" = "0" ]; then
		t apply $@ ".terraform.plan";

		if command -v tunnel.sh 1>/dev/null 2>&1 && [ ! -z "$host" ]; then
			tunnel.sh close $host
		fi
	fi
}
