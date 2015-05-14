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
sudo hostnamectl set-hostname myhost
echo "$(ip a show eth0 |grep inet|grep -Po "([0-9]{1,3}\.){3}[0-9]{1,3}"|head -1) myhost.mydomain myhost" | sudo tee -a /etc/hosts
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
    class {
        'puppet::agent':
            pinned_env => 'dev'
    }
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

### Secrets

To deploy secrets (passwords, keys, ...), upload a copy of the secret in the S3
bucket named `mozopsecsecrets1`. Access to the bucket is limited to hosts in the
`production` VPC.

In puppet, you can retrieve your secret using `wget::fetch` as follow:
```puppet
wget::fetch {
    'mysecret':
        source      => "${secretsrepourl}mysecret",
        destination => "/etc/mysecret",
        timeout     => 0,
        mode        => 600,
        cache_dir   => '/var/tmp/',
        verbose     => false;
```

Templating a secret requires a bit of a hack, since the secret is in a file and
now a puppet variable. You can get creative and execute a `sed -i` of the secret
on the configuration file. Check out the `mig` module for ideas.
