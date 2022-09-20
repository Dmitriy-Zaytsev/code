#! /bin/bash
echo "--------------------$0----------------------"
[ -x /usr/bin/reboot_router.sh ] || exit 0 #Либо скрипт доступен для исполнения пользователю запустившему сценарий, иначе exit 0.
. /lib/lsb/init-functions # прочитаем lsb(linux standard base)-библиотека
#функций инициализации,для вывода сообщений на консоль, содержит в себе функции
#которые мы будем применять ниже, также в этом  скрипте указанно прочитать
#/lib/lsb/init-functions.d/20-left-info-blocks.

case "$1" in
    start)echo ...............start.................;
    log_daemon_msg "Start scritp RELOAD_ROUTER.SH" "RELOAD_ROUTER." || true;
    sleep 1
#nohup-изгонирование сигналов потери связи, &>/dev/null-stdout,stderr>/dev/null, &-background.
    if [ -e /var/run/reb.pid ] #Если pid есть (процесс запущен/не факт конечно).
       then log_end_msg 1
           echo -e  "\nScript RELOAD_ROUTER already running.";exit
#S-start,q-quiet,m-создать pid file(если программа не создаёт),p-какой pid,x-exec, b-background(в фоне).
       elif start-stop-daemon -c 1000 -S -q -b -m -p /var/run/reb.pid -x /usr/bin/reboot_router.sh
#or nohup-изгонирование сигналов потери связи, &>/dev/null-stdout,stderr>/dev/null, &-background.
# elif nohub start-stop-daemon -S -q -m -p /var/run/reb.pid -x /usr/bin/reboot_router.sh &>/dev/null &
          then
               log_end_msg 0 || true
          else
               log_end_msg 1 || true
    fi
    ;;
    stop)echo ".................stop..................";
    log_daemon_msg "Stop scritp RELOAD_ROUTER.SH" "RELOAD_ROUTER" || true;
    sleep 1
    if [ ! -e /var/run/reb.pid ]
      then log_end_msg 1 || true
           echo -e "\nScript RELOAD_ROUTER already not running(no /var/run/reb.pid)."
#o-oknodo, заместо 0 возврощает 1, за место 1  0.
      elif start-stop-daemon -c 1000 -K -o -q -p /var/run/reb.pid &>/dev/null
          then
              rm /var/run/reb.pid
              log_end_msg 0 || true
          else
              log_end_msg 1 || true
    fi
    ;;
esac





: ........................................................................
comment () {


grep "log_daemon_msg ()" /lib/lsb/init-functions -A 15
log_daemon_msg () {
    if [ -z "${1:-}" ]; then #Если нет $1
        return 1 #Выйти передав 1, не выполнено.
    fi
    log_daemon_msg_pre "$@"

    if [ -z "${2:-}" ]; then #Если нет $2, $1-есть.
        /bin/echo -n "$1:" || true
        return ##Выйти передав 0,выполнено.
    fi
#Если у на есть как мимнимум 2 аргумента,(см.пред.идущие условия) тогда.
    /bin/echo -n "$1: $2" || true
    log_daemon_msg_post "$@"
}

grep "log_daemon_msg_pre ()" /lib/lsb/init-functions.d/20-left-info-blocks -A 5
log_daemon_msg_pre () {
    if log_use_fancy_output; then #если на функция вернула 0 тогда напечатаем [....].
        /bin/echo -n "[....] " || true
    fi
}

grep "log_use_fancy_output (" /lib/lsb/init-functions -A 20
log_use_fancy_output () {
    TPUT=/usr/bin/tput
    EXPR=/usr/bin/expr
    if  [ -t 1 ] && #дескриптор 1(stdout) связан ли с термин.устройством.
        [ "x${TERM:-}" != "x" ] && #$XTERM не пустой.
        [ "x${TERM:-}" != "xdumb" ] && #$XTERM не = dumb.
        [ -x $TPUT ] && [ -x $EXPR ] && #фйлы доступны для исполнения.
        $TPUT hpa 60 >/dev/null 2>&1 && #Отступить 60 позиций, но это всё полетит в /dev/null, так что это проверка возможно ли раскрасить текст.
        $TPUT setaf 1 >/dev/null 2>&1 #Установить сцет шрифта(красный). но это всё полетит в /dev/null, так что это проверка возможно ли раскрасить текст.
    then
        [ -z $FANCYTTY ] && FANCYTTY=1 || true #Тогда переменной присвоим 1.
    else
        FANCYTTY=0 #Иначе 0.
    fi
    case "$FANCYTTY" in #если все условия выполнились (if then) тогда  $FANCYTTY=1.
        1|Y|yes|true)   true;; #$?=0, будет равна результату исполнения последней команды скрипта, true = return 0.
        *)              false;; #$?=1, можно заменить на return 1.
    esac
}
grep "log_daemon_msg_post ()" /lib/lsb/init-functions
    log_daemon_msg_post () { :; } #Больше эта функция ни где не описываеться.


grep "log_end_msg ()" /lib/lsb/init-functions -A 32
og_end_msg () {
    # If no arguments were passed, return
    if [ -z "${1:-}" ]; then
        return 1 #Если нет аргумента для функции тогда, завершить функцию с результатом выполнения 1(неудача).
    fi

    local retval
    retval=$1

    log_end_msg_pre "$@" #передать другой функции все свои переменные ,выводит ok,warn,fail в цвете.
    if log_use_fancy_output; then #если на функция вернула 0 значит вывод может стать красивей.
        RED=$( $TPUT setaf 1)
        YELLOW=$( $TPUT setaf 3)
        NORMAL=$( $TPUT op)
    else
        RED=''
        YELLOW=''
        NORMAL=''
    fi

    if [ $1 -eq 0 ]; then #Если 0 передали функции тогда в конце строки поставит ".".
        echo "." || true
    elif [ $1 -eq 255 ]; then #255-warning.
        /bin/echo -e " ${YELLOW}(warning).${NORMAL}" || true
    else #Если не 0 и не 255, тогда filed красным.
        /bin/echo -e " ${RED}failed!${NORMAL}" || true
    fi
    log_end_msg_post "$@"
    return $retval
}

grep "log_end_msg_pre ()" /lib/lsb/init-functions.d/20-left-info-blocks -A 20
log_end_msg_pre () {
    if log_use_fancy_output; then #если на функция вернула 0 значит вывод может стать красивей.
        RED=$( $TPUT setaf 1)
        GREEN=$( $TPUT setaf 2)
        YELLOW=$( $TPUT setaf 3)
        NORMAL=$( $TPUT op)

        $TPUT civis || true #Скрыть курсор.
        $TPUT sc && \ #Сохранить позицию курсора.
        $TPUT hpa 0 && \ #Встать в начало строки.
        if [ $1 -eq 0 ]; then #Если передали 0 функции.
            /bin/echo -ne "[${GREEN} ok ${NORMAL}" || true
        elif [ $1 -eq 255 ]; then #Если 255.
            /bin/echo -ne "[${YELLOW}warn${NORMAL}" || true
        else #$1= все кроме 1 и 255.
            /bin/echo -ne "[${RED}FAIL${NORMAL}" || true
        fi && \
        $TPUT rc || true #Восстановить позицию курсора.
        $TPUT cnorm || true #Показать курсор.
    fi
}
}
