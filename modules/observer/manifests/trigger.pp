# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class observer::trigger(
    $rabbitmq_relay = '127.0.0.1:5672',
    $elasticsearch_db = '127.0.0.1:9200',
    $secretsrepourl = 'https://someplace.example.net/somedir/'
) {
    case $::operatingsystem {
        'Ubuntu': {
            include observer::package
            include wget
            wget::fetch {
                'trigger-ca-cert':
                    source      => "${secretsrepourl}ca.crt",
                    destination => "/etc/observer/ca.crt",
                    timeout     => 0,
                    mode        => 444,
                    cache_dir   => '/var/tmp/',
                    verbose     => false;
                'trigger-mozdef-password':
                    source      => "${secretsrepourl}trigger-mozdef-password",
                    destination => "/etc/observer/trigger-mozdef-password",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    verbose     => false;
            }
            file {
                '/etc/observer/trigger.cfg':
                    content     => template('observer/trigger.cfg.erb'),
                    show_diff   => false,
                    owner       => 'observer',
                    mode        => 600,
                    require     => [ Class['observer::package'] , wget::fetch['trigger-ca-cert'], wget::fetch['trigger-mozdef-password']];
            }
            exec {
                'set-trigger-mozdef-password':
                    command     => 'sed -i "s|REPLACEMOZDEFPASSWORD|$(cat /etc/observer/trigger-mozdef-password)|" /etc/observer/trigger.cfg',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/observer/trigger.cfg']];
            }
            service{
                'tlsobserver-mozillaexpiring7daystrigger':
                    require => File['/etc/observer/trigger.cfg'],
                    ensure  => running;
                'tlsobserver-mozillawildcardtrigger':
                    require => File['/etc/observer/trigger.cfg'],
                    ensure  => running;
            }
        }
    }
}
