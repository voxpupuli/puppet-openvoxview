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

  $download_source = "https://github.com/voxpupuli/openvoxview/releases/download/v${openvoxview::version}/openvoxview_${openvoxview::version}_linux_amd64.tar.gz"
  $install_dir = "/opt/openvoxview-${openvoxview::version}"
  $archive_bin_path = "${install_dir}/openvoxview"

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

  file { '/usr/local/bin/openvoxview':
    ensure  => link,
    notify  => $notify_service_maybe,
    target  => "${install_dir}/openvoxview",
    require => File[$archive_bin_path],
  }
}
