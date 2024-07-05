#!/bin/zsh

BUILDAH_FORMAT=docker
BUILDAH_ISOLATION=chroot

typeset -x -m 'BUILDAH_*'

BUILD_IMAGE_NETWORK=host
BUILD_IMAGE_PUSH=0

typeset -x -m 'BUILD_IMAGE*'
