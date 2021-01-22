#
#
#
class profile_prometheus::postfix_exporter (
  String        $version,
  Boolean       $manage_firewall_entry,
  Boolean       $manage_sd_service,
  String        $sd_service_name,
  Array         $sd_service_tags,
) {
  class { 'prometheus::postfix_exporter':
    version => $version,
  }

  if $manage_firewall_entry {
    firewall { '09154 allow postfix_exporter':
      dport  => 9154,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9154',
          interval => '10s'
        }
      ],
      port   => 9154,
      tags   => $sd_service_tags,
    }
  }
}
