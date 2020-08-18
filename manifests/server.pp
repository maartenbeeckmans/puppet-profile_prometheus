# == class: profile_prometheus::server
#
# === Parameters
#
# $version                      Version of prometheus server
#
# $alerts                       Alert configuration for prometheus server
#
# $scrape_configs               Scrape configs for prometheus server
#
# $manage_firewall_server       Manage firewall for prometheus server
#
class profile_prometheus::server (
  String  $version                = '2.20.1',
  Array   $scrape_configs         = [ {
    'job_name'        => 'prometheus',
    'scrape_interval' => '10s',
    'static_configs'  => [ {
      'targets' => ['localhost:9090'],
      'labels'  => {
        'alias' => 'Prometheus'
      },
    } ],
  } ],
  Variant[Array,Hash] $alerts     = {
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
  Boolean $manage_firewall_entry  = true,
)
{
  class { 'prometheus::server':
    version        => $version,
    scrape_configs => $scrape_configs,
    alerts         => $alerts,
  }
  if $manage_firewall_entry {
    ::profile::base::firewall::entry { '200 allow prometheus server':
      port => 9090,
    }
  }
}
