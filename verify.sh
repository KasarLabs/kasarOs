check_script() {
    ps aux | grep $1
}

check_script rc.local