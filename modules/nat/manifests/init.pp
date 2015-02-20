# a simple class to configure a NAT instance for AWS
class nat {
    include sysctl::base
    include firewall
    sysctl {
        'net.ipv4.ip_forward':
            value => '1';
        'net.ipv4.conf.all.send_redirects':
            value => '0';
    }
    firewall {
        '001 Outbound NAT':
            ensure   => present,
            chain    => 'POSTROUTING',
            jump     => 'MASQUERADE',
            table    => 'nat',
            outiface => 'eth0'
    }
}
