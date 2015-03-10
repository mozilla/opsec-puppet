#!/usr/bin/env bash
(
for env in $(ls /etc/puppet/environments); do
    echo Updating $env environment
    cd /etc/puppet/environments/$env
    [ "$env" == "production" ] && env="master"
    git fetch --all
    git reset --hard origin/$env
    librarian-puppet install
done
) 2>&1
