node default {
    include puppet::agent
    include base
}

node 'puppetmaster1.use1.opsec.mozilla.com' {
    include base
    include puppet::master
}

node /gw\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include nat
}

# MIG
node /mig-api\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include mig::server::api
}
node /mig-scheduler\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include mig::server::scheduler
}
node /mig-relay\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include mig::server::relay
}

# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
        allow_virtual => $allow_virtual_packages,
    }
}
