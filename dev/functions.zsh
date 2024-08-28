function wait-for-url() {
    echo "Testing $1"
    timeout -s TERM 45 bash -c \
    'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
    do echo "Waiting for ${0}" && sleep 2;\
    done' ${1}
    echo "OK!"
    curl -I $1
}

function wait-for-fail-url() {
    echo "Testing $1"
    timeout -s TERM 145 bash -c \
    'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" == "200" ]];\
    do echo "Waiting for ${0}" && sleep 2;\
    done' ${1}
    echo "OK!"
    curl -I $1
}


function tfcleam() {
    echo "Cleaning up .terraform from $1"
    find $1 -type d -name ".terraform" -exec rm -rf {} \;
    echo "Done!"
}