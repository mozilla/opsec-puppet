# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::server::api(
    $enableauth,
    $tokenduration,
    $ip,
    $port,
    $host,
    $baseroute,
    $clientpublicip,
    $apireqsignatures,
    $dbhost,
    $dbport,
    $dbname,
    $dbuser,
    $dbsslmode,
    $dbmaxconn,
    $maxmind,
    $secretsrepourl
) {
    case $::operatingsystem {
        'Ubuntu': {
            include mig::server::base

            file {
                '/etc/mig/api.cfg':
                    content     => template('mig/api.cfg.erb'),
                    show_diff   => false,
                    owner       => 'mig',
                    mode        => 600,
                    require     => [ Class['mig::server::base'] ];
            }

            wget::fetch {
                'mig-api-db-password':
                    source      => "${secretsrepourl}api-db-password",
                    destination => "/etc/mig/api-db-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ Exec['set-api-password'] ],
                    verbose     => false;
                'mig-api-geoip':
                    source      => "${secretsrepourl}GeoIP2-City.mmdb",
                    destination => "/etc/mig/GeoIP2-City.mmdb",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ Service['mig-api'] ],
                    verbose     => false;
            }

            exec {
                'set-api-password':
                    command     => 'sed -i "s|REPLACEDBPASSWORD|$(cat /etc/mig/api-db-password)|" /etc/mig/api.cfg; rm /etc/mig/api-db-password',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/api.cfg'] ],
                    before      => [ Service['mig-api'] ];
                'set-api-permissions':
                    command     => 'chown mig /etc/mig -R; chmod 640 /etc/mig/* -R',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/api.cfg'] ],
                    before      => [ Service['mig-api'] ];
            }

            service {
                'mig-api':
                    enable => true,
                    ensure => running,
                    require => [ File['/etc/mig/api.cfg'] ];
            }
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }
}
