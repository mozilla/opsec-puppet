# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::server::baseworker(
    $secretsrepourl
){
    include mig::common
    include wget
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Debian': {
            include mig::server::base
            wget::fetch {
                'mig-worker-mozdef-password':
                    source      => "${secretsrepourl}worker-mozdef-password",
                    destination => "/etc/mig/worker-mozdef-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'mig-worker-mq-password':
                    source      => "${secretsrepourl}worker-mq-password",
                    destination => "/etc/mig/worker-mq-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'worker-key':
                    source      => "${secretsrepourl}worker.key",
                    destination => "/etc/mig/worker.key",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
                'worker-cert':
                    source      => "${secretsrepourl}worker.crt",
                    destination => "/etc/mig/worker.crt",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    require     => [ Class['mig::server::base'] ],
                    verbose     => false;
            }
            exec {
                'set-worker-permissions':
                    command     => 'chown mig /etc/mig -R; chown 640 /etc/mig/* -R',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ wget::fetch['mig-worker-mozdef-password'],
                                     wget::fetch['mig-worker-mq-password'],
                                     wget::fetch['worker-key'],
                                     wget::fetch['worker-cert'],
                                    ];
            }
        }
    }
}
