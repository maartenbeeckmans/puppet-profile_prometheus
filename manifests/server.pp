#
#
#
class profile_prometheus::server (
  String              $version,
  Boolean             $manage_firewall_entry,
  String              $sd_service_name,
  Array               $sd_service_tags,
  Array               $scrape_configs,
  Variant[Array,Hash] $alerts,
  Array               $alertmanagers_config,
  Boolean             $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
)
{
  class { 'prometheus::server':
    version              => $version,
    scrape_configs       => $scrape_configs,
    alertmanagers_config => $alertmanagers_config,
    alerts               => $alerts,
  }
  if $manage_firewall_entry {
    firewall { '09090 allow prometheus server':
      dport  => 9090,
      action => 'accept',
    }
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9090',
          interval => '10s'
        }
      ],
      port   => 9090,
      tags   => $sd_service_tags,
    }
  }
}
