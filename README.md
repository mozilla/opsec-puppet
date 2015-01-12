OpSec Puppet
============

Because OpSec systems need love too...

Bootstrap
---------

To puppetize a new EC2 instance, run the following commands:

Centos packages:
```bash
sudo yum -y install epel-release && sudo yum -y install puppet
```

Ubuntu packages:
```bash
sudo apt-get update && sudo apt-get -y install puppet && sudo puppet agent --enable
```

Bootstrap puppet:
```bash
sudo puppet agent --server internal-puppetmaster-lb-1774667821.us-east-1.elb.amazonaws.com --onetime --no-daemonize --verbose
```

A cronjob that runs puppet every 30 minutes will be created in
`/var/spool/cron/root`.

Developing
----------

Merge your changes into the master branch on github, ssh into the puppetmaster
and pull master into /etc/puppet:

```bash
$ ssh puppetmaster

ppm$ cd /etc/puppet
ppm$ git pull origin
```
