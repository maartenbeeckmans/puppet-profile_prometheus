#
#
#
class profile_prometheus::consul_exporter (
  String  $consul_server,
  String  $version,
  Boolean $manage_firewall_entry,
  String  $sd_service_name,
  Array   $sd_service_tags,
  Boolean $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
) {
  class { 'prometheus::consul_exporter':
    version => $version,
  }

  if $manage_firewall_entry {
    firewall { '09107 allow consul_exporter':
      dport  => 9107,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9107',
          interval => '10s'
        }
      ],
      port   => 9107,
      tags   => $sd_service_tags,
    }
  }
}
