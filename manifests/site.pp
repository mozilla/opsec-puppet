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

node 'puppetmaster1.use1.opsec.mozilla.com' {
    include puppet::master
}

# TLS Observatory
node /observer-retriever\d+.use1.opsec.mozilla.com/ {
    include observer::retriever
}
node /observer-analyzer\d+.use1.opsec.mozilla.com/ {
    include observer::analyzer
    include observer::mq
}
node /observer-db\d+.use1.opsec.mozilla.com/ {
    include observer::db
}

# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
        allow_virtual => $allow_virtual_packages,
    }
}
