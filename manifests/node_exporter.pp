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
  String $version                 = '1.0.1',
  Boolean $manage_firewall_entry  = true,
)
{
  class { 'prometheus::node_exporter':
    version    => $version,
  }
  if $manage_firewall_entry {
    firewall { '200 allow node_exporter':
      dport  => 9100,
      action => 'accept',
    }
  }
}
