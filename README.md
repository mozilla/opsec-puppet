OpSec Puppet
============

Because OpSec systems need love too...

## Bootstrap a node

To puppetize a new EC2 instance, run the following commands:

Centos packages:
```bash
sudo yum -y install epel-release && sudo yum -y install puppet
```

Ubuntu packages:
```bash
sudo apt-get update && sudo apt-get -y install puppet && sudo puppet agent --enable
```

Set the hostname of the instances:
```bash
sudo echo "myhostname" > /etc/hostname
sudo echo "1.2.3.4 myhostname.mysubdomain myhostname" >> /etc/hosts
sudo hostname -F /etc/hostname
```

Bootstrap puppet:
```bash
sudo puppet agent --server puppet.use1.opsec.mozilla.com --onetime --no-daemonize --verbose
```

A cronjob that runs puppet every 30 minutes will be created in
`/var/spool/cron/root`.

## Developing using the dev branch

Clone this repository and all its submodules with:
```bash
git clone --recursive git@github.com:mozilla/opsec-puppet.git
```

Work in progress must go into the `dev` branch. The puppetmaster pull the `dev`
branch every minute into the `dev` environment. You can then run puppet agent
against the `dev` environment from your node as follow:

```bash
puppet agent --test --environment=dev
```

Once happy with your changes, submit a pull request against the `master` branch.
The master branch is made available as the `production` (default) environment.

### Pin a node to the dev branch

In the node definition in `manifests/site.pp`, set the `$pin_puppet_env` to `dev`:
```puppet
node /observer-retriever\d+.use1.opsec.mozilla.com/ {
    $pin_puppet_env = "dev"
    include observer::retriever
}
```

And run `puppet agent --test --environment=dev` to set the pin.
To reset the environment to production, simply unset the pining in `site.pp`.

### Dependencies

Dependencies are managed in the file named `Puppetfile`, which implements
Librarian Puppet (https://github.com/rodjek/librarian-puppet).

To add a new dependency, simply add the github repository into the Puppetfile.
Make sure to **pin** the dependency to a git commit hash, for security reasons.
