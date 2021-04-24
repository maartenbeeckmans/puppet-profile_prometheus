#
#
#
class profile_prometheus::alertmanager (
  Boolean $manage_firewall_entry,
  String  $sd_service_name,
  Array   $sd_service_tags,
  String  $version,
  Hash    $route,
  Array   $receivers,
  Boolean $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
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
          http     => "http://${facts[networking][ip]}:9093",
          interval => '10s'
        }
      ],
      port   => 9093,
      tags   => $sd_service_tags,
    }
  }
}
