# == Class: profile_prometheus::node_exporter
#
# Manages prometheus node_exporter
#
# === Parameters
#
# $version                Version of prometheus node_exporter
#
# $collectors             Collectors to export
#
# $manage_firewall_entry  Manage firewall entry
#
class profile_prometheus::node_exporter (
  String        $version               = '1.0.1',
  Boolean       $manage_firewall_entry = true,
  Array[String] $collectors_enable     = [],
  Array[String] $collectors_disable    = ['buddyinfo', 'interrupts', 'logind', 'mountstats', 'ntp', 'processes', 'systemd', 'tcpstat',],
  Boolean       $manage_sd_service     = false,
  String        $sd_service_name       = 'node_exporter',
  Array         $sd_service_tags       = ['metrics'],
)
{
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
