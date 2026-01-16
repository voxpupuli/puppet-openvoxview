# @summary
#   This class handles the OpenVox View installation.
#
# @api private
#
class openvoxview::install {
  $notify_service_maybe = $openvoxview::manage_service ? {
    true    => Service[$openvoxview::service_name],
    default => undef,
  }

  case $openvoxview::install_method {
    'archive': {
      $download_source = $openvoxview::download_url
      $install_dir = "/opt/openvoxview-${openvoxview::version}"
      $archive_bin_path = "${install_dir}/openvoxview"
      $executable_path = '/usr/local/bin/openvoxview'

      file { $install_dir:
        ensure => directory,
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0755',
      }
      -> archive { "/tmp/openvoxview-${openvoxview::version}.tar.gz":
        ensure          => present,
        source          => $download_source,
        checksum_verify => false,
        extract         => true,
        extract_path    => $install_dir,
        creates         => $archive_bin_path,
        cleanup         => true,
        before          => File[$archive_bin_path],
      }

      file { $archive_bin_path:
        ensure => file,
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0555',
      }

      file { $executable_path:
        ensure  => link,
        notify  => $notify_service_maybe,
        target  => "${install_dir}/openvoxview",
        require => File[$archive_bin_path],
      }
    }
    'package': {
      $executable_path = '/usr/bin/openvoxview'
      package { 'openvoxview':
        ensure => $openvoxview::version,
        notify => $notify_service_maybe,
      }
    }
    default: {
      fail("Invalid install_method '${openvoxview::install_method}' specified. Valid options are 'archive' and 'package'.")
    }
  }
}
