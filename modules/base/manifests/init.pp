class base {
    # basic tools
    package {
        ['ntp', 'htop']:
            ensure => latest
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
}
