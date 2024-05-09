alias tf='terraform'

alias hubps='hub pull-request -b staging -m "Deploy to staging"'
alias release='git stash && git fetch && git checkout deploy-to-staging && git rebase origin/master && git push origin deploy-to-staging && hubps && git checkout master && git stash pop'