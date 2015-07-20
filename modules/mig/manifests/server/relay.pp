# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class mig::server::relay (
    $secretsrepourl
) {
    package {
        'rabbitmq-server':
            ensure  => latest,
            before  => [ File['/etc/rabbitmq/rabbitmq.config'] ];
    }
    file {
        '/etc/rabbitmq':
            ensure => directory;
    }

    # Increase the number of file descriptors rabbitmq can hold
    include ulimit
    ulimit::rule {
        'rabbitmq_nofile_soft':
            ulimit_domain => 'rabbitmq',
            ulimit_type   => 'soft',
            ulimit_item   => 'nofile',
            ulimit_value  => '131072';
        'rabbitmq_nofile_hard':
            ulimit_domain => 'rabbitmq',
            ulimit_type   => 'hard',
            ulimit_item   => 'nofile',
            ulimit_value  => '131072';
        'root_nofile_soft':
            ulimit_domain => 'root',
            ulimit_type   => 'soft',
            ulimit_item   => 'nofile',
            ulimit_value  => '131072';
        'root_nofile_hard':
            ulimit_domain => 'root',
            ulimit_type   => 'hard',
            ulimit_item   => 'nofile',
            ulimit_value  => '131072';
    }
    # on debian/ubuntu, strangely, the rabbitmq package insists in
    # ignoring ulimit and runs ulimit -n from /etc/default/rabbitmq-server instead
    case $::operatingsystem {
        'Ubuntu', 'Debian': {
            file {
                '/etc/default/rabbitmq-server':
                    content => 'ulimit -n 131072';
            }
        }
    }

    wget::fetch {
        'rabbitmq-creds':
            source      => "${secretsrepourl}rabbitmq-creds",
            destination => "/etc/rabbitmq/creds",
            timeout     => 0,
            mode        => 600,
            cache_dir   => '/var/tmp/',
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'erlang-cookie':
            source      => "${secretsrepourl}erlang-cookie",
            destination => "/var/lib/rabbitmq/.erlang.cookie",
            timeout     => 0,
            mode        => 600,
            cache_dir   => '/var/tmp/',
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'relay-key':
            source      => "${secretsrepourl}relay.key",
            destination => "/etc/rabbitmq/relay.key",
            timeout     => 0,
            mode        => 600,
            cache_dir   => '/var/tmp/',
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'relay-cert':
            source      => "${secretsrepourl}relay.crt",
            destination => "/etc/rabbitmq/relay.crt",
            timeout     => 0,
            mode        => 600,
            cache_dir   => '/var/tmp/',
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'ca-cert-relay':
            source      => "${secretsrepourl}ca.crt",
            destination => "/etc/rabbitmq/ca.crt",
            timeout     => 0,
            mode        => 600,
            cache_dir   => '/var/tmp/',
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
    }
    file {
        '/etc/rabbitmq/enabled_plugins':
            before  => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            content => "[rabbitmq_management].";
        '/etc/rabbitmq/rabbitmq.config':
            content => template('mig/rabbitmq.config.erb');

    }
    exec {
        'set-rabbitmq-permissions':
            command     => 'chown rabbitmq /var/lib/rabbitmq/.erlang.cookie;
                            chmod 600 /var/lib/rabbitmq/.erlang.cookie;
                            chown rabbitmq /etc/rabbitmq/ -R;
                            chmod 640 /etc/rabbitmq/* -R',
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            require     => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            before      => [ Exec['restart-rabbitmq'] ];

        'restart-rabbitmq':
            command     => "service rabbitmq-server restart",
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            refreshonly => true,
            subscribe   => [ File['/etc/rabbitmq/rabbitmq.config'], ulimit::rule['root_nofile_hard'] ];

        'create-rabbitmq-env':
            command     => 'sudo rabbitmqctl add_user admin $(grep ^admin /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl set_user_tags admin administrator;
                            sudo rabbitmqctl add_user scheduler $(grep ^scheduler /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-generic $(grep ^agent-generic: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-it $(grep ^agent-it: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-it-nubis $(grep ^agent-it-nubis: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-releng $(grep ^agent-releng: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-foundation $(grep ^agent-foundation: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-fxos-automation $(grep ^agent-fxos-automation: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-opsec $(grep ^agent-opsec: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-moz-opsec $(grep ^agent-moz-opsec: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent-services $(grep ^agent-services: /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user worker $(grep ^worker /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_vhost mig;
                            sudo rabbitmqctl set_permissions -p mig scheduler "^mig(|(event|\.agt)(|\..*))$" "^mig(|event(|\..*)|\.(agt\.(heartbeats|results)))$" "^mig(|event(|\..*)|\.(agt\.(heartbeats|results)))$";
                            sudo rabbitmqctl set_permissions -p mig agent-generic "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-it "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-it-nubis "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-releng "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-foundation "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-fxos-automation "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-opsec "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-moz-opsec "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig agent-services "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig worker "^migevent\..*$" "^migevent(|\..*)$" "^migevent(|\..*)$";',
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            subscribe   => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ Exec['set-rabbitmq-permissions'] ];

        'mirror-all-queues':
            command     => 'sudo rabbitmqctl -p mig set_policy mig-mirror-all "^mig(|event)\." \'{"ha-mode":"all"}\'',
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            require     => [ Exec['create-rabbitmq-env'] ];
    }
    service {
        'rabbitmq-server':
            ensure => running
    }
}
