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
    $version,
    $secretsrepourl
) {
    # package installation is done via a simple wget of the package file,
    # followed by the appropriate rpm/dpkg command. Installation does not
    # start a new agent. This is done in mig::agent::daemon only.
    case $::operatingsystem {
        'CentOS', 'RedHat': {
            $pkgname = "mig-agent-${version}-1.${::architecture}.rpm"
            $installer = "rpm -Uvh ${pkgname}"
        }
        'Ubuntu', 'Debian': {
            $pkgname = "mig-agent_${version}_${::architecture}.deb"
            $installer = "dpkg -i ${pkgname}"
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
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    verbose     => false;
                'mig-agent-cert':
                    source      => "${secretsrepourl}agent.crt",
                    destination => "/etc/mig/agent.crt",
                    timeout     => 0,
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    verbose     => false;
                'ca-cert':
                    source      => "${secretsrepourl}ca.crt",
                    destination => "/etc/mig/ca.crt",
                    timeout     => 0,
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    verbose     => false;
                'mig_agent_relay_uri':
                    source      => "${secretsrepourl}mig_agent_relay_uri",
                    destination => "/etc/mig/mig_agent_relay_uri",
                    timeout     => 0,
                    before      => [ File['/etc/mig/mig-agent.cfg'] ],
                    verbose     => false;
            }
            file {
                '/etc/mig/':
                    ensure => 'directory',
                    owner => 'root',
                    mode => 755,
                    before => [ wget::fetch['mig-agent'],
                                wget::fetch['mig-agent-key'],
                                wget::fetch['mig-agent-cert'],
                                wget::fetch['ca-cert']];
                '/etc/mig/mig-agent.cfg':
                    content => template('mig/mig-agent.cfg.erb'),
                    show_diff => false,
                    owner => 'root',
                    mode => 600,
                    before => [ wget::fetch['mig-agent'] ];
            }
            exec {
                'set-relay-uri':
                    command     => 'sed -i "s/RELAYURITOREPLACE/$(cat /etc/mig/mig_agent_relay_uri)/" /etc/mig/mig-agent.cfg',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    subscribe   => [ File['/etc/mig/mig-agent.cfg'] ],
                    before      => [ wget::fetch['mig-agent'] ],
                    refreshonly => true;
            }
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }

    include wget
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
            subscribe   => wget::fetch['mig-agent'],
            refreshonly => true
    }
}
