#
#
#
class profile_prometheus::node_exporter (
  String        $version,
  Array[String] $collectors_enable,
  Array[String] $collectors_disable,
  Boolean       $manage_firewall_entry,
  Boolean       $manage_sd_service,
  String        $sd_service_name,
  Array         $sd_service_tags,
) {
  class { 'prometheus::node_exporter':
    version            => $version,
    collectors_enable  => $collectors_enable,
    collectors_disable => $collectors_disable,
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
