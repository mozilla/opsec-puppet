class puppet::agent(
    $server = "192.168.1.3",
    $certname = "puppetmaster.example.net"
) {
    case $::kernel {
        linux: {
            cron {
                "puppet":
                    ensure  => present,
                    command => "sleep $((RANDOM%600)) && /usr/bin/puppet agent --onetime --no-daemonize --logdest syslog > /dev/null 2>&1",
                    user    => "root",
                    hour    => "*",
                    minute  => "*/30",
            }
            file {
                "/etc/puppet/puppet.conf":
                    ensure  => present,
                    mode    => 0755,
                    owner   => "root",
                    group   => "root",
                    content => template("puppet/puppet.conf.erb")
            }
        }
    }
}
