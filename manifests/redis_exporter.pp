#
#
#
class profile_prometheus::redis_exporter (
  Array[Integer] $ports,
  String         $version,
  Boolean        $manage_firewall_entry,
  String         $sd_service_name,
  Array          $sd_service_tags,
  Boolean        $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
) {

  $_addr = $ports.map |$items| { "redis://localhost:${items}" }

  class { 'prometheus::redis_exporter':
    addr    => $_addr,
    version => $version,
  }

  if $manage_firewall_entry {
    firewall { '09121 allow redis_exporter':
      dport  => 9121,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9121',
          interval => '10s'
        }
      ],
      port   => 9121,
      tags   => $sd_service_tags,
    }
  }
}
