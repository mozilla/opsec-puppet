# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::server::agent_intel_worker(

){
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Debian': {
            include mig::server::base
            include mig::server::baseworker
            file {
                '/etc/mig/agent-intel-worker.cfg':
                    content     => template('mig/agent-intel-worker.cfg.erb'),
                    show_diff   => false,
                    owner       => 'mig',
                    mode        => 600,
                    require     => [ Class['mig::server::base'], Class['mig::server::baseworker'] ];
            }
            exec {
                'set-aiworker-db-password':
                    command     => 'sed -i "s|REPLACEMOZDEFPASSWORD|$(cat /etc/mig/worker-mozdef-password)|" /etc/mig/agent-intel-worker.cfg',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/agent-intel-worker.cfg']];
                'set-aiworker-mq-password':
                    command     => 'sed -i "s|REPLACEMQPASSWORD|$(cat /etc/mig/worker-mq-password)|" /etc/mig/agent-intel-worker.cfg',
                    path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    require     => [ File['/etc/mig/agent-intel-worker.cfg']];
            }
            service {
                'mig-agent-intel-worker':
                    enable => true,
                    require => [ File['/etc/mig/agent-intel-worker.cfg'] ];
            }
        }
    }
}
