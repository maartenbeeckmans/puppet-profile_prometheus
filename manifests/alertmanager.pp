#
class profile_prometheus::alertmanager (
  Boolean $manage_sd_service     = false,
  Boolean $manage_firewall_entry = true,
  String  $sd_service_name       = 'alertmanager',
  Array   $sd_service_tags       = ['metrics'],
  String  $version               = '0.21.0',
  Hash    $route                 = {},
  Array   $receivers             = [],
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
