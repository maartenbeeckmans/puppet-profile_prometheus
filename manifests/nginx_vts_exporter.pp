#
#
#
class profile_prometheus::nginx_vts_exporter (
  String  $version,
  Boolean $manage_firewall_entry,
  Boolean $manage_sd_service,
  String  $sd_service_name,
  Array   $sd_service_tags,
) {
  class { 'prometheus::nginx_vts_exporter':
    version => $version,
  }

  if $manage_firewall_entry {
    firewall { '09913 allow nginx_vts_exporter':
      dport  => 9913,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9913',
          interval => '10s'
        }
      ],
      port   => 9913,
      tags   => $sd_service_tags,
    }
  }
}
