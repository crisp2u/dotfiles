dump_django_groups () {
	local OLD_CONTEXT=$(kubectl config current-context)
	kubectl config use-context "${1}" > /dev/null
	kubectl config set-context  --current --namespace "${1}"> /dev/null
 	
 	kubectl exec $(kubectl get pods -l service=web-tooling -n "${1}" -o name | head -1) -n "${1}" -c backend-tooling -- with-config bash -c 'cd /app/backend/${APP} && python manage.py dumpdata auth.group --no-color --natural-foreign --natural-primary  --format yaml 2> /dev/null'
 	
 	if [ -n "${OLD_CONTEXT}" ]; then
 		kubectl config use-context "${OLD_CONTEXT}"> /dev/null
    fi
 	
}

load_django_groups () {
	local OLD_CONTEXT
	OLD_CONTEXT=$(kubectl config current-context)
	kubectl config use-context "${1}"
	kubectl config set-context  --current --namespace "${1}"> /dev/null
	local BACKEND_POD=$(kubectl get pods -l service=web-tooling -n "${1}" -o name | head -1 | xargs basename)
	local TMP_DEST

	TMP_DEST=$(kubectl exec ${BACKEND_POD} -c backend-tooling -- mktemp)
	kubectl cp ${2} ${BACKEND_POD}:${TMP_DEST} -c backend-tooling
	kubectl exec ${BACKEND_POD} -c backend-tooling -- with-config bash -c "cd /app/backend/\${APP} && mv ${TMP_DEST} ${TMP_DEST}.yaml && python manage.py loaddata --format yaml ${TMP_DEST}.yaml"

 	if [ -n "${OLD_CONTEXT}" ]; then
 		kubectl config use-context "${OLD_CONTEXT}"
    fi
}

herokudiff() {
	PLAN_JSON=$(terraform show -json .terraform.plan)
	CHANGES_JSON=$(jq '.resource_changes[] | select(.address=="module.app.heroku_config.config") | {before: .change.before.sensitive_vars, after: .change.after.sensitive_vars}' <( printf "%s\n" $PLAN_JSON ))
	BEFORE_JSON=$(jq .before <( printf "%s\n" $CHANGES_JSON ))
	AFTER_JSON=$(jq .after <( printf "%s\n" $CHANGES_JSON ))

	# Show diff
	diff <( printf '%s\n' $BEFORE_JSON ) <( printf '%s\n' $AFTER_JSON )
}

get_ssh_key() {
	AWS_PROFILE=$1 chamber read -q  ssh-keys id_rsa.$1 > ~/.ssh/$1.pem && chmod 400  ~/.ssh/$1.pem
}


bastion() {

	ENVIRONMENT=$1
	IFS="-" read -r"${BASH_VERSION:+a}${ZSH_VERSION:+A}" TOKENS <<< "${ENVIRONMENT}"
	rm -f "${HOME}/.ssh/${ENVIRONMENT}.pem"
	AWS_PROFILE=${ENVIRONMENT} chamber read -q ssh-keys "id_rsa.${ENVIRONMENT}" > "${HOME}/.ssh/${ENVIRONMENT}.pem" && \
  	chmod 400 "${HOME}/.ssh/${ENVIRONMENT}.pem" && \
  	cat <<-EOT >> ~/.ssh/config

	Host ${ENVIRONMENT}-bastion
	    User ubuntu
	    HostName bastion.${TOKENS[3]}.${TOKENS[1]}-${TOKENS[2]}.run
	    IdentityFile ~/.ssh/${ENVIRONMENT}.pem
	    StrictHostKeyChecking no
	    UserKnownHostsFile=/dev/null
	EOT
}