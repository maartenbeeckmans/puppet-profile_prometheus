#
#
#
class profile_prometheus::node_exporter (
  String        $version,
  Array[String] $collectors_enable,
  Array[String] $collectors_disable,
  Boolean       $manage_firewall_entry,
  String        $sd_service_name,
  Array         $sd_service_tags,
  String        $extra_options,
  Boolean       $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
) {
  class { 'prometheus::node_exporter':
    version            => $version,
    collectors_enable  => $collectors_enable,
    collectors_disable => $collectors_disable,
    extra_options      => $extra_options,
  }

  # Make sure parent directores exist
  exec { '/var/lib/node_exporter/textfile':
    path    => $::path,
    command => 'mkdir -p /var/lib/node_exporter/textfile',
    unless  => 'test -d /var/lib/node_exporter/textfile',
  }
  -> file { '/var/lib/node_exporter/textfile':
    ensure  => directory,
  }

  if $manage_firewall_entry {
    firewall { '09100 allow node_exporter':
      dport  => 9100,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9100',
          interval => '10s'
        }
      ],
      port   => 9100,
      tags   => $sd_service_tags,
    }
  }
}
