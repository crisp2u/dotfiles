export LANG=en_US.UTF-8
export EDITOR='subl -w'

export NODE_OPTIONS=--max_old_space_size=4096
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export ALGOLIA_ADMIN_API_KEY=donotindex
export PATH="/usr/local/opt/postgresql/bin:$PATH"
export PATH="/usr/local/opt/node@8/bin:$PATH"
export PATH="$HOME/Library/Python/3.7/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
export AWS_SDK_LOAD_CONFIG=true
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
#setopt HIST_BEEP                 # Beep when accessing nonexistent history.