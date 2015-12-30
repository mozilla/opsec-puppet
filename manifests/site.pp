node default {
    include puppet::agent
    include base
}

node 'puppetmaster1.use1.opsec.mozilla.com' {
    include base
    include puppet::master
}

node /nat\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include nat
}

# TLS Observatory
node /observer-web\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
}
node /observer-retriever\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include observer::certretriever
    include observer::tlsretriever
}
node 'observer-analyzer1.use1.opsec.mozilla.com' {
    include base
    include puppet::agent
    include observer::certanalyzer
    include observer::tlsanalyzer
    include observer::mq
}
node /observer-analyzer[2-9].use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include observer::certanalyzer
    include observer::tlsanalyzer
}
node /observer-trigger\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include observer::trigger
}
node /observer-db\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include observer::db
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
node /mig-worker\d+.use1.opsec.mozilla.com/ {
    include base
    include puppet::agent
    include mig::server::agent_intel_worker
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
