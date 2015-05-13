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
    wget::fetch {
        'rabbitmq-creds':
            source      => "${secretsrepourl}rabbitmq-creds",
            destination => "/etc/rabbitmq/creds",
            timeout     => 0,
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'erlang-cookie':
            source      => "${secretsrepourl}erlang-cookie",
            destination => "/var/lib/rabbitmq/.erlang.cookie",
            timeout     => 0,
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'relay-key':
            source      => "${secretsrepourl}relay.key",
            destination => "/etc/rabbitmq/relay.key",
            timeout     => 0,
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'relay-cert':
            source      => "${secretsrepourl}relay.crt",
            destination => "/etc/rabbitmq/relay.crt",
            timeout     => 0,
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
        'ca-cert-relay':
            source      => "${secretsrepourl}ca.crt",
            destination => "/etc/rabbitmq/ca.crt",
            timeout     => 0,
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            require     => [ File['/etc/rabbitmq'] ],
            verbose     => false;
    }
    file {
        '/etc/rabbitmq/enabled_plugins':
            before      => [ File['/etc/rabbitmq/rabbitmq.config'] ],
            content => "[rabbitmq_management].";
        '/etc/rabbitmq/rabbitmq.config':
            content => template('mig/rabbitmq.config.erb');
    }
    exec {
        'restart-rabbitmq':
            command     => "service rabbitmq-server restart",
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            subscribe   => [ File['/etc/rabbitmq/rabbitmq.config'] ];
        'create-rabbitmq-env':
            command     => 'sudo rabbitmqctl add_user admin $(grep ^admin /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl set_user_tags admin administrator;
                            sudo rabbitmqctl add_user scheduler $(grep ^scheduler /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user agent $(grep ^agent /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_user worker $(grep ^worker /etc/rabbitmq/creds|cut -d ":" -f2);
                            sudo rabbitmqctl add_vhost mig;
                            sudo rabbitmqctl set_permissions -p mig scheduler "^mig(|(event|\.agt)(|\..*))$" "^mig(|event(|\..*)|\.(agt\.(heartbeats|results)))$" "^mig(|event(|\..*)|\.(agt\.(heartbeats|results)))$";
                            sudo rabbitmqctl set_permissions -p mig agent "^mig\.agt\.(linux|windows|darwin)\..*$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$" "^mig(|\.agt\.(linux|windows|darwin)\..*)$";
                            sudo rabbitmqctl set_permissions -p mig worker "^migevent\..*$" "^migevent(|\..*)$" "^migevent(|\..*)$";',
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            subscribe   => [ File['/etc/rabbitmq/rabbitmq.config'] ];
        'mirror-all-queues':
            command     => 'sudo rabbitmqctl -p mig set_policy mig-mirror-all "^mig\." \'{"ha-mode":"all"}\'',
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            require     => [ Exec['create-rabbitmq-env'] ];
    }
}
