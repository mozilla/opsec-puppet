OpSec Puppet
============

Because OpSec systems need love too...

Bootstrap
---------

To puppetize a new EC2 instance, run the following commands:

Puppet installation on Centos:
```bash
$ sudo yum -y install epel-release && sudo yum -y install puppet
```

First puppet run:
```bash
$ sudo puppet agent --server internal-puppetmaster-lb-1774667821.us-east-1.elb.amazonaws.com --onetime --no-daemonize --verbose
```

A cronjob that runs puppet every 30 minutes will be created in
`/var/spool/cron/root`.
