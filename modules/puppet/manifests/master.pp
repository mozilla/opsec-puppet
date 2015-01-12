class puppet::master(
    $server = "puppetmaster.example.net",
    $ismaster = true
) {
    case $::kernel {
        linux: {
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
    include puppet::cron
}
