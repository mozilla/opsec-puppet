# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::server::scheduler(
    $agttimeout,
    $agtheartbeatfreq,
    $agtwhitelist,
    $detectmultiagents,
    $killdupagents,
    $collectorfreq,
    $periodicfreq,
    $deleteafter,
    $qcleanupfreq,
    $dirspool,
    $dirtmp,
    $dbhost,
    $dbport,
    $dbname,
    $dbuser,
    $dbsslmode,
    $dbmaxconn,
    $mqhost,
    $mqport,
    $mquser,
    $mqvhost,
    $mqtls,
    $mqcacert,
    $mqclicert,
    $mqclikey,
    $secretsrepourl
) {
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Debian': {
            include mig::server::base
            file {
                '/etc/mig/scheduler.cfg':
                    content => template('mig/scheduler.cfg.erb'),
                    show_diff => false,
                    owner => 'mig',
                    mode => 600,
                    require => [ Class['mig::server::base'] ];
            }
            wget::fetch {
                'mig-scheduler-db-password':
                    source      => "${secretsrepourl}scheduler-db-password",
                    destination => "/etc/mig/scheduler-db-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ Exec['set-scheduler-db-password'] ],
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'mig-scheduler-mq-password':
                    source      => "${secretsrepourl}scheduler-mq-password",
                    destination => "/etc/mig/scheduler-mq-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ Exec['set-scheduler-mq-password'] ],
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'scheduler-key':
                    source      => "${secretsrepourl}scheduler.key",
                    destination => "/etc/mig/scheduler.key",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ File['/etc/mig/scheduler.cfg'] ],
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'scheduler-cert':
                    source      => "${secretsrepourl}scheduler.crt",
                    destination => "/etc/mig/scheduler.crt",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ File['/etc/mig/scheduler.cfg'] ],
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
            }
            exec {
                'set-scheduler-db-password':
                    command     => 'sed -i "s|REPLACEDBPASSWORD|$(cat /etc/mig/scheduler-db-password)|" /etc/mig/scheduler.cfg; rm /etc/mig/scheduler-db-password',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/scheduler.cfg'] ],
                    before      => [ Service['mig-scheduler'] ];
                'set-scheduler-mq-password':
                    command     => 'sed -i "s|REPLACEMQPASSWORD|$(cat /etc/mig/scheduler-mq-password)|" /etc/mig/scheduler.cfg; rm /etc/mig/scheduler-mq-password',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/scheduler.cfg'] ],
                    before      => [ Service['mig-scheduler'] ];
                'set-scheduler-permissions':
                    command     => 'chown mig /etc/mig -R; chmod 640 /etc/mig -R',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/scheduler.cfg'] ],
                    before      => [ Service['mig-scheduler'] ];
            }
            service {
                'mig-scheduler':
                    enable => true,
                    require => [ File['/etc/mig/scheduler.cfg'] ];
            }
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }
}
