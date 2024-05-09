export LANG=en_US.UTF-8
export EDITOR='subl -w'
export KUBE_EDITOR='code --wait'
export HELM_DIFF_COLOR=true

export NODE_OPTIONS=--max_old_space_size=4096
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export ALGOLIA_ADMIN_API_KEY=donotindex
export PATH="/usr/local/opt/postgresql/bin:$PATH"
export PATH="/usr/local/opt/node@8/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

export INFRASTRUCTURE_EMPG_HOME=/Users/cristian.pop/projects/sl/infra/infrastructure-empg/
export INFRASTRUCTURE_MODULES_HOME=/Users/cristian.pop/projects/sl/infra/infrastructure-modules/

# https://nikgrozev.com/2019/10/03/switch-between-multiple-kubernetes-clusters-with-ease/
# Set the default kube context if present
DEFAULT_KUBE_CONTEXTS="$HOME/.kube/config"
if test -f "${DEFAULT_KUBE_CONTEXTS}"
then
  export KUBECONFIG="$DEFAULT_KUBE_CONTEXTS"
fi

# Additional contexts should be in ~/.kube/custom-contexts/ 
CUSTOM_KUBE_CONTEXTS="$HOME/.kube/custom-contexts"
mkdir -p "${CUSTOM_KUBE_CONTEXTS}"

OIFS="$IFS"
IFS=$'\n'
for contextFile in `find "${CUSTOM_KUBE_CONTEXTS}" -type f -name "*"`  
do
    export KUBECONFIG="$contextFile:$KUBECONFIG"
done
IFS="$OIFS"
