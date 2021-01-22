#
#
#
class profile_prometheus::postgres_exporter (
  String        $version,
  Boolean       $manage_firewall_entry,
  Boolean       $manage_sd_service,
  String        $sd_service_name,
  Array         $sd_service_tags,
) {
  class { 'prometheus::postgres_exporter':
    version              => $version,
    user                 => 'postgres',
    group                => 'postgres',
    postgres_auth_method => 'custom',
    data_source_custom   => {
      'DATA_SOURCE_NAME' => 'user=postgres host=/var/run/postgresql/ sslmode=disable',
    },
  }

  if $manage_firewall_entry {
    firewall { '09187 allow postgres_exporter':
      dport  => 9187,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9187',
          interval => '10s'
        }
      ],
      port   => 9187,
      tags   => $sd_service_tags,
    }
  }
}
