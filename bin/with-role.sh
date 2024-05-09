#!/usr/bin/env bash
role_arn=$1
shift
role_session_name=$(date +%s-assume-session)


if [[ ! -z ${role_arn} ]] ; then
     #backup service account role if any
     BACKUP_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
     BACKUP_AWS_ROLE_ARN=${AWS_ROLE_ARN:-}
     BACKUP_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
     BACKUP_AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN:-}
     BACKUP_AWS_WEB_IDENTITY_TOKEN_FILE=${AWS_WEB_IDENTITY_TOKEN_FILE:-}
     #unset this 

     temp_role=$(aws sts assume-role \
          --role-arn $role_arn \
          --role-session-name $role_session_name)

     unset AWS_ROLE_ARN 
     unset AWS_WEB_IDENTITY_TOKEN_FILE

     export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
     export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
     export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

fi

exec "$@"


if [[ ! -z ${role_arn} ]] ; then
  #restore
     export AWS_ACCESS_KEY_ID=${BACKUP_AWS_ACCESS_KEY_ID:-}
     export AWS_ROLE_ARN=${BACKUP_AWS_ROLE_ARN:-}
     export AWS_SECRET_ACCESS_KEY=${BACKUP_AWS_SECRET_ACCESS_KEY:-}
     export AWS_SESSION_TOKEN=${BACKUP_AWS_SESSION_TOKEN:-}
     export AWS_WEB_IDENTITY_TOKEN_FILE=${BACKUP_AWS_WEB_IDENTITY_TOKEN_FILE:-}
fi
