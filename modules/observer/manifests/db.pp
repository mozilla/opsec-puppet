# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class observer::db {
    case $::operatingsystem {
        'Ubuntu': {
            include observer::package
            package{
                ['openjdk-7-jre', 'curl']:
                    ensure => latest,
                    before => Class['elasticsearch']
            }
            class {
                'elasticsearch':
                    ensure       => 'present',
                    autoupgrade  => true,
                    manage_repo  => true,
                    repo_version => '1.4',
                    status       => 'enabled'
            }
            elasticsearch::instance {
                'tlsobserver':
                    datadir       => '/mnt/esdata/tlsobserver',
                    config        => {'script.groovy.sandbox.enabled'   => 'true' },
                    init_defaults => {'ES_HEAP_SIZE'                    => '15G'}
            }
            exec {
                'push certificates mappings':
                    command     => '/usr/bin/curl -XPUT http://localhost:9200/observer/; /usr/bin/curl -XPUT http://localhost:9200/observer/_mapping/certificate -d @/etc/observer/cert_schema.json; /usr/bin/curl -XPUT http://localhost:9200/observer/_mapping/connection -d @/etc/observer/conn_schema.json',
                    subscribe   => exec['install-mozilla-tls-observer'],
                    refreshonly => true
            }
        }
    }
}
