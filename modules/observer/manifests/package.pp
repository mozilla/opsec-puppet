# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class observer::package (
    $url,
    $version
) {
    case $::operatingsystem {
        'Ubuntu': {
            include wget
            wget::fetch { 'mozilla-tls-observer':
                source      => $url,
                destination => "/tmp/mozilla-tls-observer-$version.deb",
                timeout     => 0,
                verbose     => false,
            }
            exec {
                'install-mozilla-tls-observer':
                    command => "/usr/sbin/service tlsobserver-analyzer stop; /usr/sbin/service tlsobserver-retriever stop; /usr/bin/dpkg -i /tmp/mozilla-tls-observer-$version.deb",
                    subscribe => wget::fetch['mozilla-tls-observer'],
                    refreshonly => true
            }
        }
    }
}
