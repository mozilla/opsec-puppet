class base {
    # basic tools
    package {
        ['ntp', 'htop']:
            ensure => latest
    }
    service {
        'ntp':
            ensure => running,
            enable => true,
            require => [ Package['ntp'] ];
    }
    # centos and redhat specific packages
    case $::operatingsystem {
        'CentOS', 'RedHat': {
            package {
                ['epel-release', 'vim-enhanced']:
                    ensure => latest
            }
        }
    }

    # create user accounts
    $accounts = hiera_hash('opsec_members')
    create_resources('account::user', $accounts)

    # delete user accounts
    $deleted_accounts = hiera_hash('disabled_users')
    create_resources('account::user', $deleted_accounts)

    include mig::agent::daemon
}
