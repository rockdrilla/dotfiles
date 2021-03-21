#!/bin/zsh

chase() { setopt chase_dots chase_links ; }
nochase() { unsetopt chase_dots chase_links ; }
nochase
