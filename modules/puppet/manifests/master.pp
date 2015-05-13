class puppet::master(
    $server = 'puppetmaster.example.net',
    $ismaster = true,
    $autosign = '*.example.net'
) {
    case $::kernel {
        linux: {
            file {
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
                '/etc/puppet/update_from_upstream.sh':
                    ensure  => present,
                    mode    => 0755,
                    owner   => 'root',
                    group   => 'root',
                    source => "puppet:///modules/puppet/update_from_upstream.sh";
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
            cron {
                'update puppetmaster from upstream':
                    ensure  => present,
                    command => '/etc/puppet/update_from_upstream.sh > /dev/null 2>&1',
                    user    => 'root',
                    hour    => '*',
                    minute  => '*/5',
            }
        }
    }
    class {
        'puppet::agent':
            ismaster => true
    }
    include puppet::cron
}
