#!/bin/bash

domains=("$wz")

# Username and password
username=("$user")
passwd=("$mm")

TITLE="${domains} 签到通知😋"
log_text=""
PUSH_TMP_PATH="./.tz.tmp"
send_message() {
    # TelegramBot 通知
    if [ "${tg_bot_TOKEN}" ] && [ "${tg_user_ID}" ]; then
        result_tgbot_log_text="${TITLE}\n${log_text}"
        echo -e "chat_id=${tg_user_ID}&parse_mode=Markdown&text=${result_tgbot_log_text}" >${PUSH_TMP_PATH}
        push=$(curl -k -s --data-binary @${PUSH_TMP_PATH} "https://api.telegram.org/bot${tg_bot_TOKEN}/sendMessage")
        push_code=$(echo ${push} | grep -o '"ok":true')
        if [ ${push_code} ]; then
            echo -e "【TelegramBot 推送结果】: 成功\n"
        else
            echo -e "【TelegramBot 推送结果】: 失败\n"
        fi
    fi
}

function auto_checkin(){
    curl -k -s -L -e  '; auto' -d "email=$2&passwd=$3&code=" -c /tmp/checkin.cook "https://$1/auth/login" > /dev/null
    retstr=$(curl -k -s -d "" -b /tmp/checkin.cook "https://$1/user/checkin")
    [ -z "${retstr}" ] && return 1
    echo -e ${retstr}
    log_text=$(echo "${retstr}" | awk -F '"msg":"|.","|..."}' '{print $2}')
    send_message
        rm -rf ${PUSH_TMP_PATH}
     #echo $(echo "${retstr}" | awk -F '"' '{print $4}')
}

for i in $( seq 0 $(( ${#username[@]}-1 )) ); do
    for d in ${domains[@]}; do
        echo "Checking in for ${username[i]} with domain $d"
        rm -rf /tmp/checkin.cook
        if ( auto_checkin $d ${username[i]} ${passwd[i]} ); then
            break
        else
            echo 'Checkin Failed!'
        fi
    done
done
