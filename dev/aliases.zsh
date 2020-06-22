alias tf='terraform'

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
