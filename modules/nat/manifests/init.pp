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
        '001 Outbound NAT TCP':
            ensure   => present,
            chain    => 'POSTROUTING',
            jump     => 'MASQUERADE',
            table    => 'nat',
            proto     => 'tcp',
            outiface => 'eth0'
        '002 Outbound NAT UDP':
            ensure   => present,
            chain    => 'POSTROUTING',
            jump     => 'MASQUERADE',
            table    => 'nat',
            proto     => 'udp',
            outiface => 'eth0'
   }
}
