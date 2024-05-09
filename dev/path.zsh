export GROOVY_HOME=/usr/local/opt/groovy/libexec
export GOPATH=~/Projects/go
export PATH=$GROOVY_HOME/bin:$GOPATH/bin:$PATH
export PATH=/usr/local/opt/mysql-client@5.7/bin:$PATH
export PATH="/usr/local/opt/terraform@0.12/bin:$PATH"
#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
