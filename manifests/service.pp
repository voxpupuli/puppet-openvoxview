# @summary
#   This class handles the OpenVox View Service.
#
# @api private
#
class openvoxview::service {
  if $openvoxview::manage_systemd_unit {
    $notify_service_maybe = $openvoxview::manage_service ? {
      true    => Service[$openvoxview::service_name],
      default => undef,
    }

    systemd::unit_file { "${openvoxview::service_name}.service":
      content => epp('openvoxview/openvoxview.service.epp',
        {
          install_path => $openvoxview::install_path,
          config_path  => "${openvoxview::config_dir}/${openvoxview::config_file}",
          user         => $openvoxview::openvoxview_user,
          group        => $openvoxview::openvoxview_group,
        }
      ),
      notify  => $notify_service_maybe,
    }
  }

  if $openvoxview::manage_service {
    service { $openvoxview::service_name:
      ensure => $openvoxview::service_ensure,
      enable => $openvoxview::service_enable,
    }
  }
}
