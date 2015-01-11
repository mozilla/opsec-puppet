OpSec Puppet
============

Because OpSec systems need love too...

Bootstrap
---------

Centos:
```bash
$ sudo yum -y install epel-release
$ sudo yum -y puppet
```

Invoke puppet manually on the host:
```bash
$ sudo puppet agent --server
internal-puppetmaster-lb-1774667821.us-east-1.elb.amazonaws.com --onetime --no-daemonize --verbose
```

On the puppetmaster, sign the agent's certificate:
```bash
$ sudo puppet cert list
  "ip-172-19-254-253.use1.opsec.mozilla.com" (SHA256) 79:E8:9B:D1:DC:77:B4:9D:05:4F:A3:0A:78:D3:24:5A:05:12:5A:26:1F:2A:E7:D6:47:7F:53:59:3F:CF:C0:92

$ sudo puppet cert --sign ip-172-19-254-253.use1.opsec.mozilla.com

Notice: Signed certificate request for ip-172-19-254-253.use1.opsec.mozilla.com
Notice: Removing file Puppet::SSL::CertificateRequest ip-172-19-254-253.use1.opsec.mozilla.com at '/var/lib/puppet/ssl/ca/requests/ip-172-19-254-253.use1.opsec.mozilla.com.pem'
```

Back on the agent, run puppet again:
```bash
$ sudo puppet agent --server internal-puppetmaster-lb-1774667821.us-east-1.elb.amazonaws.com --onetime --no-daemonize --verbose
```

This will ensure that the base module is deployed on the host, which includes
running puppet in the background.
