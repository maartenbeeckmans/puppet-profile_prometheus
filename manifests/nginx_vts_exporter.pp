#
#
#
class profile_prometheus::nginx_vts_exporter (
  String        $version               = '0.10.3',
  Boolean       $manage_firewall_entry = true,
  Boolean       $manage_sd_service     = false,
  String        $sd_service_name       = 'nginx-vts-exporter',
  Array         $sd_service_tags       = ['metrics'],
)
{
  class { 'prometheus::nginx_vts_exporter':
    version            => $version,
  }
  if $manage_firewall_entry {
    firewall { '09913 allow node_exporter':
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
