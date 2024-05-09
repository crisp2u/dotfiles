alias ls='exa'
alias dir='ls -l'

alias hubps='hub pull-request -b staging -m "Deploy to staging"'
alias curltime="curl -w '\ntime_namelookup:  %{time_namelookup}\n       time_connect:  %{time_connect}\n    time_appconnect:  %{time_appconnect}\n   time_pretransfer:  %{time_pretransfer}\n      time_redirect:  %{time_redirect}\n time_starttransfer:  %{time_starttransfer}\n                    ----------\n         time_total:  %{time_total}\n' \"$@\" "
alias curlh="curl -s -o /dev/null --dump-header - \"$@\""alias hubps='hub pull-request -b staging -m "Deploy to staging"'
