#
#
#
class profile_prometheus::node_exporter (
  String        $version,
  Array[String] $collectors_enable,
  Array[String] $collectors_disable,
  Boolean       $manage_firewall_entry,
  String        $sd_service_name,
  Array         $sd_service_tags,
  String        $extra_options,
  Array[String] $prometheus_servers     = lookup('prometheus_servers', Array, first, ['127.0.0.1']),
  Boolean       $manage_sd_service      = lookup('manage_sd_service', Boolean, first, true),
) {
  class { 'prometheus::node_exporter':
    version            => $version,
    collectors_enable  => $collectors_enable,
    collectors_disable => $collectors_disable,
    extra_options      => $extra_options,
  }

  # Make sure parent directores exist
  exec { '/var/lib/node_exporter/textfile':
    path    => $::path,
    command => 'mkdir -p /var/lib/node_exporter/textfile',
    unless  => 'test -d /var/lib/node_exporter/textfile',
  }
  -> file { '/var/lib/node_exporter/textfile':
    ensure  => directory,
  }

  if $manage_firewall_entry {
    ensure_resource( 'nftables::set', 'prometheus_servers', {
      type     => 'ipv4_addr',
      flags    => ['interval'],
      elements => $prometheus_servers,
    })

    profile_base::firewall::rule { 'allow_node_exporter':
      dport => 9100,
      saddr => '@prometheus_servers',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${facts[networking][ip]}:9100",
          interval => '10s'
        }
      ],
      port   => 9100,
      tags   => $sd_service_tags,
    }
  }
}
