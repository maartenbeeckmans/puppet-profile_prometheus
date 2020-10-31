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
  String         $version                = '1.0.1',
  Boolean        $manage_firewall_entry  = true,
  Arrays[String] $collectors_enable      = [],
  Arrays[String] $collectors_disable     = ['buddyinfo', 'interrupts', 'logind', 'mountstats', 'ntp', 'processes', 'systemd', 'tcpstat',],
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
}
