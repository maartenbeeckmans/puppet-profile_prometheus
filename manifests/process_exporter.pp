#
#
#
class profile_prometheus::process_exporter (
  String        $version,
  Hash          $hash_watched_processes,
  Boolean       $manage_firewall_entry,
  Boolean       $manage_sd_service,
  String        $sd_service_name,
  Array         $sd_service_tags,
) {
  class { 'prometheus::process_exporter':
    hash_watched_processes => $hash_watched_processes,
    version                => $version,
  }

  if $manage_firewall_entry {
    firewall { '09256 allow process_exporter':
      dport  => 9256,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9256',
          interval => '10s'
        }
      ],
      port   => 9256,
      tags   => $sd_service_tags,
    }
  }
}
