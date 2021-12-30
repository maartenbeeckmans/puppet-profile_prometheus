#
#
#
class profile_prometheus::process_exporter (
  String  $version,
  Hash    $hash_watched_processes,
  Boolean $manage_firewall_entry,
  String  $sd_service_name,
  Array   $sd_service_tags,
  Array[String] $prometheus_servers     = lookup('prometheus_servers', Array, first, ['127.0.0.1']),
  Boolean $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
) {
  class { 'prometheus::process_exporter':
    hash_watched_processes => $hash_watched_processes,
    version                => $version,
  }

  if $manage_firewall_entry {
    ensure_resource( 'nftables::set', 'prometheus_servers', {
      type     => 'ipv4_addr',
      flags    => ['interval'],
      elements => $prometheus_servers,
    })

    profile_base::firewall::rule { 'allow_process_exporter':
      dport => 9256,
      saddr => '@prometheus_servers',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${facts[networking][ip]}:9256",
          interval => '10s'
        }
      ],
      port   => 9256,
      tags   => $sd_service_tags,
    }
  }
}
