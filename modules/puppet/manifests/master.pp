class puppet::master(
    $server = "puppetmaster.example.net",
    $ismaster = true,
    $autosign = "*.example.net"
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
            file {
		"/etc/puppet/hiera.yaml":
                    ensure  => present,
                    mode    => 0755,
                    owner   => "root",
                    group   => "root",
                    content => template("puppet/hiera.yaml.erb");
            }
            file {
		"/etc/puppet/autosign.conf":
                    ensure  => present,
                    mode    => 0755,
                    owner   => "root",
                    group   => "root",
                    content => template("puppet/autosign.conf.erb");
            }
            file {
		"/etc/puppet/environments/production":
                    ensure  => directory,
                    mode    => 0755,
                    owner   => "root",
                    group   => "root";
            }
        }
    }
    include puppet::cron
}
