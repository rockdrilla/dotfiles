#!/bin/zsh

say_my_name() {
    set -a
    GIT_COMMITTER_NAME="$1"
    GIT_AUTHOR_NAME="$1"
    DEBFULLNAME="$1"
    set +a
}

say_my_email() {
    set -a
    GIT_COMMITTER_EMAIL="$1"
    GIT_AUTHOR_EMAIL="$1"
    DEBEMAIL="$1"
    set +a
}
