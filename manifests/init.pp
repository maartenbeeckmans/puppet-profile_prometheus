# == Class: profile_prometheus
#
# Manages prometheus node_exporter and server configurations
#
# === Dependencies
#
# - puppet-prometheus
#
# === Parameters
#
# $server              Manage prometheus server
#
# $node_exporter       Manage prometheus node_exporter
#
class profile_prometheus (
  Boolean $server        = false,
  Boolean $alertmanager  = false,
  Boolean $node_exporter = true,
) {
  if $server {
    class { '::profile_prometheus::server': }
  }
  if $alertmanager {
    class { '::profile_prometheus::alertmanager': }
  }
  if $node_exporter {
    class { '::profile_prometheus::node_exporter': }
  }
}
