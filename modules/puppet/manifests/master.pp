class puppet::master(
    $server = 'puppetmaster.example.net',
    $ismaster = true,
    $autosign = '*.example.net'
) {
    case $::kernel {
        linux: {
            file {
                '/etc/puppet/puppet.conf':
                    ensure  => present,
                    mode    => 0755,
                    owner   => 'root',
                    group   => 'root',
                    content => template('puppet/puppet.conf.erb');
                '/etc/puppet/hiera.yaml':
                    ensure  => present,
                    mode    => 0755,
                    owner   => 'root',
                    group   => 'root',
                    content => template('puppet/hiera.yaml.erb');
                '/etc/puppet/autosign.conf':
                    ensure  => present,
                    mode    => 0755,
                    owner   => 'root',
                    group   => 'root',
                    content => template('puppet/autosign.conf.erb');
                '/etc/puppet/environments/production':
                    ensure  => directory,
                    mode    => 0755,
                    owner   => 'root',
                    group   => 'root';
            }
            package {
                'librarian-puppet':
                    ensure   => 'installed',
                    provider => 'gem',
            }
        }
    }
    include puppet::cron
}
