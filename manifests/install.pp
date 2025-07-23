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

  $download_source = "https://github.com/voxpupuli/openvoxview/releases/download/v${openvoxview::version}/openvoxview_${openvoxview::version}_linux_amd64"

  file { $openvoxview::install_path:
    ensure => file,
    source => $download_source,
    mode   => '0700',
    owner  => $openvoxview::openvoxview_user,
    group  => $openvoxview::openvoxview_group,
    notify => $notify_service_maybe,
  }
}
