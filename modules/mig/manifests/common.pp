# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::common(
    $secretsrepourl
) {
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Darwin': {
            file {
                '/etc/mig/':
                    ensure => directory;
            }
            include wget
            wget::fetch {
                'ca-cert':
                    source      => "${secretsrepourl}ca.crt",
                    destination => "/etc/mig/ca.crt",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    require     => [ File['/etc/mig/'] ],
                    verbose     => false;
            }
        }
    }
}
