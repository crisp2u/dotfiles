alias k='kubectl'
#ops
alias ops='export AWS_PROFILE=empg-ops && kubectl config use-context ops'

#Olx Pk
alias olxpd='export AWS_PROFILE=olx-pk-dev'
alias olxps='export AWS_PROFILE=olx-pk-stage'
alias olxpp='export AWS_PROFILE=olx-pk-prod'
alias olxpg='export AWS_PROFILE=olx-pk-global'

alias chamberd='AWS_PROFILE=olx-pk-dev chamber'
alias chambers='AWS_PROFILE=olx-pk-stage chamber'
alias chamberp='AWS_PROFILE=olx-pk-prod chamber'
alias olxbd='sshuttle --verbose --dns -NHr olx-pk-dev-bastion 10.0.0.0/12'
alias olxbs='sshuttle --verbose --dns -NHr olx-pk-stage-bastion 10.10.0.0/12'
alias olxbp='sshuttle --verbose --dns -NHr olx-pk-prod-bastion 10.20.0.0/12'
alias olxkd='kubectl config use-context olx-pk-development --namespace olx-pk-development'
alias olxks='kubectl config use-context olx-pk-staging --namespace olx-pk-staging'
alias olxkp='kubectl config use-context olx-pk-production --namespace olx-pk-live'
alias olxdbo='psql $(chamberp export ovation-olx-pk-production -f json | jq -r .DATABASE_URL)'
alias olxdb='psql $(chamberp export olx-pk-production -f json | jq -r .DATABASE_URL)'
alias olxdbr='psql $(chamberp export olx-pk-production -f json | jq -r .DATABASE_READ_REPLICA_URL)'
alias olxdbs='psql $(chambers export olx-pk-staging -f json | jq -r .DATABASE_URL)'
alias olxdbd='psql $(chamberd export olx-pk-development -f json | jq -r .DATABASE_URL)'

#Olx EG
alias egpd='export AWS_PROFILE=olx-eg-dev'
alias egbd='sshuttle --verbose --dns -NHr olx-eg-dev-bastion 10.11.0.0/12'

alias egps='export AWS_PROFILE=olx-eg-stage'
alias egbs='sshuttle --verbose --dns -NHr olx-eg-stage-bastion 10.21.0.0/12'

alias egpp='export AWS_PROFILE=olx-eg-prod'
alias egbp='sshuttle --verbose --dns -NHr olx-eg-prod-bastion 10.31.0.0/12'



#Olx BH
alias bhpd='export AWS_PROFILE=olx-bh-dev'
alias bhbd='sshuttle --verbose --dns -NHr olx-bh-dev-bastion 10.12.0.0/12'

alias bhpp='export AWS_PROFILE=olx-bh-prod'
alias bhbp='sshuttle --verbose --dns -NHr olx-bh-prod-bastion 10.22.0.0/12'

alias bhps='export AWS_PROFILE=olx-bh-stage'
alias bhbs='sshuttle --verbose --dns -NHr olx-bh-stage-bastion 10.22.0.0/12'
alias bhks='kubectl config use-context olx-bh-staging --namespace olx-bh-staging'

alias bhpp='export AWS_PROFILE=olx-bh-prod'
alias bhbp='sshuttle --verbose --dns -NHr olx-bh-prod-bastion 10.32.0.0/12'
alias bhkp='kubectl config use-context olx-bh-production --namespace olx-bh-production'

#Olx OM

alias ompp='export AWS_PROFILE=olx-om-prod'
alias ombp='sshuttle --verbose --dns -NHr olx-om-prod-bastion 10.35.0.0/12'
alias omkp='kubectl config use-context olx-om-production --namespace olx-om-production'

#Olx LB
alias lbpd='export AWS_PROFILE=olx-lb-dev'
alias lbbd='sshuttle --verbose --dns -NHr olx-lb-dev-bastion 10.13.0.0/12'
alias lbkd='kubectl config use-context olx-bh-development --namespace olx-bh-development'

alias lbps='export AWS_PROFILE=olx-lb-stage'
alias lbbs='sshuttle --verbose --dns -NHr olx-lb-stage-bastion 10.23.0.0/12'
alias lbks='kubectl config use-context olx-lb-staging --namespace olx-lb-staging'

alias lbpp='export AWS_PROFILE=olx-lb-prod'
alias lbbp='sshuttle --verbose --dns -NHr olx-lb-prod-bastion 10.33.0.0/12'
alias lbkp='kubectl config use-context olx-lb-production --namespace olx-lb-production'
alias lbdap='AWS_PROFILE=olx-lb-prod pg_activity $(chamber export olx-lb-production -f json | jq -r .DATABASE_URL) --rds'
#Olx SA
alias sapp='export AWS_PROFILE=olx-sa-prod'

#Olx QA

alias qapp='export AWS_PROFILE=olx-qa-prod'
alias qabp='sshuttle --verbose --dns -NHr olx-qa-prod-bastion 10.36.0.0/12'
alias qakp='kubectl config use-context olx-qa-production --namespace olx-qa-production'
alias qadsp='psql $(chamber export olx-qa-production -f json | jq -r .DATABASE_URL)'
alias qadop='psql $(chamber export ovation-olx-qa-production -f json | jq -r .DATABASE_URL)'
alias qadkp='psql $(chamber export keycloak/production/rds -f json | jq -r .DATABASE_URL)'
alias qadap='pg_activity $(chamber export olx-qa-production -f json | jq -r .DATABASE_URL) --rds'

#Olx Jo

alias jopp='export AWS_PROFILE=olx-jo-prod'
alias jobp='sshuttle --verbose --dns -NHr olx-jo-prod-bastion 10.37.0.0/12'
alias jokp='kubectl config use-context olx-jo-production --namespace olx-jo-production'


#Olx Kw

alias kwpp='export AWS_PROFILE=olx-kw-prod'
alias kwbp='sshuttle --verbose --dns -NHr olx-kw-prod-bastion 10.38.0.0/12'
alias kwkp='kubectl config use-context olx-kw-production --namespace olx-kw-production'


#Dubizzle TS

alias dbzpp='export AWS_PROFILE=dubizzle-ts-prod'
alias dbzbp='sshuttle --verbose --dns -NHr dubizzle-ts-prod-bastion 10.69.0.0/12'
alias dbzkp='kubectl config use-context dubizzle-ts-production --namespace tubescreamer'

alias dbzps='export AWS_PROFILE=dubizzle-ts-stage'
alias dbzbs='sshuttle --verbose --dns -NHr dubizzle-ts-stage-bastion 10.49.0.0/12'
alias dbzks='kubectl config use-context dubizzle-ts-staging --namespace tubescreamer'


#Bayut
#dev
alias bapd='export AWS_PROFILE=bayut-dev'
alias babd='sshuttle --verbose --dns -NHr bayut-dev-bastion 10.19.0.0/12'
alias bakd='kubectl config use-context bayut-development --namespace bayut-development'
#stage
alias baps='export AWS_PROFILE=bayut-stage'
alias babs='sshuttle --verbose --dns -NHr bayut-stage-bastion 10.29.0.0/16'
alias baks='kubectl config use-context bayut-staging --namespace bayut-staging'
#prod
alias bapp='export AWS_PROFILE=bayut-prod'
alias babp='sshuttle --verbose --dns -NHr bayut-prod-bastion 10.39.0.0/12'
alias bakp='kubectl config use-context bayut-production --namespace bayut-production'

#Bayut Jordan
#dev
alias bjpd='export AWS_PROFILE=bayut-jo-dev'
alias bjbd='sshuttle --verbose --dns -NHr bayut-jo-dev-bastion 10.41.0.0/16'
alias bjkd='kubectl config use-context bayut-jo-development --namespace bayut-jo-development'
#prod
alias bjpp='export AWS_PROFILE=bayut-jo-prod'
alias bjbp='sshuttle --verbose --dns -NHr bayut-jo-prod-bastion 10.61.0.0/16'
alias bjkp='kubectl config use-context bayut-jo-production --namespace bayut-jo-production'


#Bayut SA
#prod
alias bsapp='export AWS_PROFILE=bayut-sa-prod'
alias bsabp='sshuttle --verbose --dns -NHr bayut-sa-prod-bastion 10.80.0.0/16'
alias bsakp='kubectl config use-context bayut-sa-production --namespace bayut-sa-production'


#Zameen
#stage
alias zaps='export AWS_PROFILE=zameen-stage'
alias zabd='sshuttle --verbose --dns -NHr zameen-stage-bastion 10.101.0.0/16'
alias zakd='kubectl config use-context zameen-staging --namespace zameeen-staging'


#Bproperty
#prod
alias bpapp='export AWS_PROFILE=bproperty-prod'
alias bpbp='sshuttle --verbose --dns -NHr bproperty-prod-bastion 10.90.0.0/16'
alias bpakp='kubectl config use-context bproperty-production --namespace bproperty-production'


#Lamudi ID
#prod
alias liapp='export AWS_PROFILE=lamudi-id-prod'
alias libp='sshuttle --verbose --dns -NHr lamudi-id-prod-bastion 10.110.0.0/16'
alias liakp='kubectl config use-context lamudi-id-production --namespace lamudi-id-production'


#Lamudi PH
#prod
alias lpapp='export AWS_PROFILE=lamudi-ph-prod'
alias lpbp='sshuttle --verbose --dns -NHr lamudi-ph-prod-bastion 10.130.0.0/16'
alias lpakp='kubectl config use-context lamudi-ph-production --namespace lamudi-ph-production'
