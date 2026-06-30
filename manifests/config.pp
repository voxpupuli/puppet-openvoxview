# @summary
#   This class handles the OpenVox View config.
#
# @api private
#
class openvoxview::config {
  assert_private()

  $config = {
    listen   => $openvoxview::listen_address,
    port     => $openvoxview::listen_port,
    puppetdb => {
      host       => $openvoxview::puppetdb_host,
      port       => $openvoxview::puppetdb_port,
      tls        => $openvoxview::puppetdb_tls,
      tls_ignore => $openvoxview::puppetdb_tls_ignore,
      tls_ca     => $openvoxview::puppetdb_tls_ca_path,
      tls_key    => $openvoxview::puppetdb_tls_key_path,
      tls_cert   => $openvoxview::puppetdb_tls_cert_path,
    },
    views      => $openvoxview::predefined_views,
    queries    => $openvoxview::predefined_pql_queries,
    log_level  => $openvoxview::log_level,
    log_format => $openvoxview::log_format,
    puppetca   => {
      host             => $openvoxview::puppetca_host,
      port             => $openvoxview::puppetca_port,
      tls              => $openvoxview::puppetca_tls,
      tls_ignore       => $openvoxview::puppetca_tls_ignore,
      tls_ca           => $openvoxview::puppetca_tls_ca,
      tls_key          => $openvoxview::puppetca_tls_key,
      tls_crt          => $openvoxview::puppetca_tls_crt,
      readonly         => $openvoxview::puppetca_readonly,
      deactivate_nodes => $openvoxview::puppetca_deactivate_nodes,
    },
  }

  if $openvoxview::manage_config_dir {
    file { $openvoxview::config_dir:
      ensure => directory,
      owner  => $openvoxview::openvoxview_user,
      group  => $openvoxview::openvoxview_group,
      mode   => '0755',
    }
  }

  $notify_service_maybe = $openvoxview::manage_service ? {
    true    => Service[$openvoxview::service_name],
    default => undef,
  }

  file { "${openvoxview::config_dir}/${openvoxview::config_file}":
    ensure  => file,
    mode    => '0444',
    owner   => $openvoxview::openvoxview_user,
    group   => $openvoxview::openvoxview_group,
    content => stdlib::to_yaml($config),
    notify  => $notify_service_maybe,
  }
}
