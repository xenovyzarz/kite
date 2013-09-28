$packages = ["postfix"]

group { "kite":
    ensure => "present"
}

user { "kite":
    require => Group["kite"],
    ensure => present,
    gid => "kite",
    shell => "/bin/true",
    home => "/home/kite",
    managehome => true,
}

file { "/var/kitemail":
    require => User["kite"],
    ensure => "directory",
    owner => "kite",
    group => "kite",
}

package { $packages:
    ensure => present,
}

service {'postfix':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["postfix"]
}

# code comes from : https://bitbucket.org/daks/puppet-postfix/src/2e93e657cab6/manifests/definitions/config.pp
define postfix_config ($ensure = present, $value, $nonstandard = false) {
      exec {"postconf -e ${name}='${value}'":
        path =>  ["/usr/bin/", "/usr/sbin"],
        unless  => $nonstandard ? {
          false => "test \"x$(postconf -h ${name})\" == 'x${value}'",
          true  => "test \"x$(egrep '^${name} ' /etc/postfix/main.cf | cut -d= -f2 | cut -d' ' -f2)\" == 'x${value}'",
        },
        notify  => Service["postfix"],
        require => Package["postfix"]
      }
}

postfix_config { 'home_mailbox':
    value => "Maildir/",
}

