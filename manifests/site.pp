node default {
    include base
    include puppet::agent

    # create user accounts
    $accounts = hiera_hash('opsec_members')
    create_resources('account::user', $accounts)

    # delete disabled users
    # $disabled = hiera_hash('disabled_users')
    # create_resources('account::user', $disabled)
}

node 'ip-172-19-1-46.ec2.internal' {
    include puppet::master
}

node 'ip-172-19-1-83.ec2.internal' {
    include os_hardening
}

# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
        allow_virtual => $allow_virtual_packages,
    }
}
