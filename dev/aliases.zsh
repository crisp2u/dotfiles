alias ls='exa'
alias dir='ls -l'
alias tf='terraform'
alias tfpd='terraform plan -out=default.tfplan'
alias tfad='terraform apply default.tfplan'
alias tfi='terraform init'

alias hubps='hub pull-request -b staging -m "Deploy to staging"'
alias release='git stash && git fetch && git checkout deploy-to-staging && git rebase origin/master && git push origin deploy-to-staging && hubps && git checkout master && git stash pop'

db() { heroku psql $1_URL -a sl-addons; }

alias dbbl='db BAYUT_LIVE'
alias dbbs='db BAYUT_STAGING'
alias dbbd='db BAYUT_DEVELOPMENT'
alias dbsal='db BAYUT_SA_LIVE'
alias dbsas='db BAYUT_SA_STAGING'
alias dbsad='db BAYUT_SA_DEVELOPMENT'
alias dbjol='db BAYUT_JO_LIVE'
alias dbjos='db BAYUT_JO_STAGING'
alias dbjod='db BAYUT_JO_DEVELOPMENT'
alias dbzl='db ZAMEEN_LIVE'
alias dbzs='db ZAMEEN_STAGING'
alias dbzd='db ZAMEEN_DEVELOPMENT'
alias curltime="curl -w '\ntime_namelookup:  %{time_namelookup}\n       time_connect:  %{time_connect}\n    time_appconnect:  %{time_appconnect}\n   time_pretransfer:  %{time_pretransfer}\n      time_redirect:  %{time_redirect}\n time_starttransfer:  %{time_starttransfer}\n                    ----------\n         time_total:  %{time_total}\n' \"$@\" "

alias sl=/Users/cristian.pop/projects/sl/sl-cli/run.sh
