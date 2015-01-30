# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class observer::analyzer(
    $rabbitmq_relay = "127.0.0.1:5672",
    $elasticsearch_db = "127.0.0.1:9200"
) {
    case $::operatingsystem {
        'Ubuntu': {
            include observer::package
            file {
                '/etc/observer/analyzer.cfg':
                    owner => 'root',
                    mode => 755,
                    content => template('observer/analyzer.cfg.erb')
            }
            service{
                'tlsobserver-analyzer' :
                    require   => Class['observer::package'],
                    ensure    => running
            }
        }
    }
}
