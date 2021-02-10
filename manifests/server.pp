#
#
#
class profile_prometheus::server (
  String              $version               = '2.22.0',
  Boolean             $manage_firewall_entry = true,
  Boolean             $manage_sd_service     = false,
  String              $sd_service_name       = 'prometheus',
  Array               $sd_service_tags       = ['metrics'],
  Array               $scrape_configs        = [ {
    'job_name'        => 'prometheus',
    'scrape_interval' => '10s',
    'static_configs'  => [ {
      'targets' => ['localhost:9090'],
      'labels'  => {
        'alias' => 'Prometheus'
      },
    } ],
  } ],
  Variant[Array,Hash] $alerts                = {
    'groups' => [ {
      'name'  => 'alert.rules',
      'rules' => [ {
        'alert'       => 'InstanceDown',
        'expr'        => 'up == 0',
        'for'         => '5m',
        'labels'      => {
          'severity' => 'page',
        },
        'annotations' => {
            'summary'     => 'Instance {{ $labels.instance }} down',
            'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.',
          }
      } ],
    } ],
  },
  Array               $alertmanagers_config   = [
    {
      'static_configs' => [{'targets' => ['localhost:9093']}],
    },
  ],
)
{
  class { 'prometheus::server':
    version              => $version,
    scrape_configs       => $scrape_configs,
    alertmanagers_config => $alertmanagers_config,
    alerts               => $alerts,
  }
  if $manage_firewall_entry {
    firewall { '09090 allow prometheus server':
      dport  => 9090,
      action => 'accept',
    }
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:9090',
          interval => '10s'
        }
      ],
      port   => 9090,
      tags   => $sd_service_tags,
    }
  }
}
