#!/usr/bin/env bash
(
sudo service puppetmaster stop
for env in $(ls /etc/puppet/environments); do
    echo Updating $env environment
    cd /etc/puppet/environments/$env
    [ "$env" == "production" ] && env="master"
    git fetch --all
    git reset --hard origin/$env
    /usr/local/bin/librarian-puppet update
done
sudo service puppetmaster start
) 2>&1
