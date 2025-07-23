# @summary
#   Main class, includes all other classes
#
# @param version
#   Which version should be installed
#
# @param install_path
#   Installation path of the binary_path
#
# @param manage_config_dir
#   Should this module manage the config dir
#
# @param config_dir
#   Path to the config dir
#
# @param config_file
#   Config File name
#
# @param manage_user
#   Whether or not the module should create the user.
#
# @param openvoxview_user
#   The user used by the OpenVox View process.
#
# @param manage_group
#    Whether or not the module should create the group.
#
# @param openvoxview_group
#   The group used by the OpenVox View process.
#
# @param manage_service
#   Should the module manage the service
#
# @param manage_systemd_unit
#   Whether or not the module should create the systemd unit file.
#
# @param service_name
#   Name of the service (if manage_service is true)
#
# @param service_ensure
#   Whether the service should be running or stopped.
#
# @param service_enable
#   Whether the service should be enabled or disabled.
#
# @param listen_address
#   Listen address
#
# @param listen_port
#   Port for service
#
# @param puppetdb_host
#   Address to the puppetdb host
#
# @param puppetdb_port
#   PuppetDB port
#
# @param puppetdb_tls
#   Is the connection to PuppetDB ssl encrypted
#
# @param puppetdb_tls_ignore
#   Should a insecure connection to PuppetDB be allowed
#
# @param predefined_pql_queries
#   Array of predefined queries
#
# @param predefined_view
#   Array of predefined views
#
# @param puppetdb_tls_ca_path
#   Path to the CA file
#
# @param puppetdb_tls_key_path
#   Path to the PuppetDB key file
#
# @param puppetdb_tls_cert_path
#   Path to the PuppetDB cert file
class openvoxview (
  String $version = '0.1.12',
  Stdlib::Absolutepath $install_path = '/usr/local/bin',
  Boolean $manage_config_dir = true,
  Stdlib::Absolutepath $config_dir = '/etc/openvox',
  String $config_file = 'openvox.yml',
  Boolean $manage_user = true,
  String $openvoxview_user = 'openvoxview',
  Boolean $manage_group = true,
  String $openvoxview_group = 'openvoxview',
  Boolean $manage_service = true,
  String $service_name = 'openvoxview',
  Boolean $manage_systemd_unit = true,
  Boolean $service_ensure = true,
  Boolean $service_enable = true,
  String $listen_address = '127.0.0.1',
  Integer[1024, 65535] $listen_port = 5000,
  String $puppetdb_host = 'localhost',
  Integer $puppetdb_port = 8080,
  Boolean $puppetdb_tls = false,
  Boolean $puppetdb_tls_ignore = true,
  Array[Hash] $predefined_pql_queries = [],
  Array[Hash] $predefined_views = [],
  String $puppetdb_tls_ca_path = undef,
  String $puppetdb_tls_key_path = undef,
  String $puppetdb_tls_cert_path = undef,
) {
  if ($manage_group) {
    group { $openvoxview_group:
      ensure => present,
    }
  }

  if ($manage_user) {
    user { $openvoxview_user:
      gid    => $openvoxview_group,
      system => true,
    }
  }

  contain openvoxview::install
  contain openvoxview::config
  contain openvoxview::service

  Class['openvoxview::install']
  -> Class['openvoxview::config']
  ~> Class['openvoxview::service']
}
