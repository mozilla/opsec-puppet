node 'puppetmaster1.use1.opsec.mozilla.com' {
    include base
    include puppet::master
}
node 'gw1.use1.opsec.mozilla.com' {
    include base
}

# TLS Observatory
node /observer-web\d+.use1.opsec.mozilla.com/ {
    include base
}
node /observer-retriever\d+.use1.opsec.mozilla.com/ {
    include base
    include observer::retriever
}
node 'observer-analyzer1.use1.opsec.mozilla.com' {
    include base
    include observer::analyzer
    include observer::mq
}
node /observer-analyzer[2-9].use1.opsec.mozilla.com/ {
    include base
    include observer::analyzer
}
node /observer-db\d+.use1.opsec.mozilla.com/ {
    include base
    include observer::db
}

# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
        allow_virtual => $allow_virtual_packages,
    }
}
