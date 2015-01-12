class puppet::cron {
    case $::kernel {
        linux: {
            cron {
                "puppet":
                    ensure  => present,
                    command => "/bin/sleep $((RANDOM\%600)) && /usr/bin/puppet agent --onetime --no-daemonize --logdest syslog > /dev/null 2>&1",
                    user    => "root",
                    hour    => "*",
                    minute  => "*/30",
            }
        }
    }
}
