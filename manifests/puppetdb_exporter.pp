#
#
#
class profile_prometheus::puppetdb_exporter (
  String        $version,
  String        $extra_options,
  Boolean       $manage_firewall_entry,
  Boolean       $manage_sd_service,
  String        $sd_service_name,
  Array         $sd_service_tags,
) {
  class { 'prometheus::puppetdb_exporter':
    version       => $version,
    extra_options => $extra_options,
  }

  if $manage_firewall_entry {
    firewall { '09635 allow puppetdb_exporter':
      dport  => 9635,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9635',
          interval => '10s'
        }
      ],
      port   => 9635,
      tags   => $sd_service_tags,
    }
  }
}
