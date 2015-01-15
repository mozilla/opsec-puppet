# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor: Julien Vehent jvehent@mozilla.com [:ulfr]
class observer::package (
    $url,
    $version
) {
    include wget
    wget::fetch { 'mozilla-tls-observer':
        source      => $url,
        destination => "/tmp/mozilla-tls-observer-$version.deb",
        timeout     => 0,
        verbose     => false,
    }
    package { 'mozilla-tls-observer':
        source  => "/tmp/mozilla-tls-observer-$version.deb",
        provider => dpkg,
        require => Wget::Fetch['mozilla-tls-observer']
    }
}
