# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::server::base(
    $repourl,
    $version
) {
    include mig::common
    user {
        'mig':
            ensure  =>  'present',
            system  =>  true;
    }
    case $::operatingsystem {
        'CentOS', 'RedHat': {
            $pkgname = "mig-server-${version}-1.${::architecture}.rpm"
            $installer = "rpm -Uvh"
        }
        'Ubuntu', 'Debian': {
            $pkgname = "mig-server_${version}_${::architecture}.deb"
            $installer = "dpkg -i"
        }
        default: {
            fail("mig server is not supported on ${::operatingsystem}")
        }
    }
    include wget
    wget::fetch {
        'serverpkg':
            source      => "${repourl}${pkgname}",
            destination => "/tmp/${pkgname}",
            timeout     => 0,
            verbose     => false;
    }
    exec {
        'install-mig-server':
            command     => "${installer} /tmp/${pkgname}",
            path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            subscribe   => wget::fetch['serverpkg'],
            refreshonly => true
    }
}
