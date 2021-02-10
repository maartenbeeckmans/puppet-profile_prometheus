#
#
#
class profile_prometheus::alertmanager (
  Boolean $manage_sd_service,
  Boolean $manage_firewall_entry,
  String  $sd_service_name,
  Array   $sd_service_tags,
  String  $version,
  Hash    $route,
  Array   $receivers,
) {
  class { 'prometheus::alertmanager':
    version   => $version,
    route     => $route,
    receivers => $receivers,
  }
  if $manage_firewall_entry {
    firewall { '09093 allow prometheus server':
      dport  => 9093,
      action => 'accept',
    }
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9093',
          interval => '10s'
        }
      ],
      port   => 9093,
      tags   => $sd_service_tags,
    }
  }
}
