# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::base(
    $isimmortal,
    $installservice,
    $discoverpublicip,
    $checkin,
    $moduletimeout,
    $apiurl,
    $repourl,
    $rhelpkg,
    $debpkg,
    $secretsrepourl
) {
    include mig::common
    include wget
    # package installation is done via a simple wget of the package file,
    # followed by the appropriate rpm/dpkg command. Installation does not
    # start a new agent. This is done in mig::agent::daemon only.
    case $::operatingsystem {
        'CentOS', 'RedHat': {
            $pkgname = $rhelpkg
            $installer = "rpm -Uvh"
        }
        'Ubuntu', 'Debian': {
            $pkgname = $debpkg
            $installer = "dpkg -i"
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }

    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Darwin': {
            wget::fetch {
                'mig-agent-key':
                    source      => "${secretsrepourl}agent.key",
                    destination => "/etc/mig/agent.key",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    require     => [ Class['mig::common'] ],
                    verbose     => false;
                'mig-agent-cert':
                    source      => "${secretsrepourl}agent.crt",
                    destination => "/etc/mig/agent.crt",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    require     => [ Class['mig::common'] ],
                    verbose     => false;
                'mig_agent_relay_uri':
                    source      => "${secretsrepourl}mig_agent_relay_uri",
                    destination => "/etc/mig/mig_agent_relay_uri",
                    timeout     => 0,
                    mode        => 600,
                    cache_dir   => '/var/tmp/',
                    before      => [ Exec['set-relay-uri'] ],
                    require     => [ Class['mig::common'] ],
                    verbose     => false;
            }
            file {
                '/etc/mig/mig-agent.cfg':
                    content => template('mig/mig-agent.cfg.erb'),
                    show_diff => false,
                    owner => 'root',
                    mode => 600,
                    before => [ Wget::Fetch['mig-agent'] ];
            }
            exec {
                'set-relay-uri':
                    command     => 'sed -i "s|RELAYURITOREPLACE|$(cat /etc/mig/mig_agent_relay_uri)|" /etc/mig/mig-agent.cfg',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    subscribe   => [ File['/etc/mig/mig-agent.cfg'] ],
                    before      => [ Wget::Fetch['mig-agent'] ],
                    refreshonly => true;
            }
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }

    wget::fetch { 'mig-agent':
        source      => "${repourl}${pkgname}",
        destination => "/tmp/${pkgname}",
        timeout     => 0,
        verbose     => false,
    }
    exec {
        'install-mig-agent':
            command     => "${installer} /tmp/${pkgname}",
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            subscribe   => Wget::Fetch['mig-agent'],
            refreshonly => true
    }
}
