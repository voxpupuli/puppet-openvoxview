# @summary Return a GitHub release artifact URL for specified version
# @param version
#   Release version.
# @param download_type
#   Whether to make archive or checksum download URL.
# @param extension
#   Archive extension (when download_type is 'archive').
# @return String
#   Returns GitHub artifact download URL
function openvoxview::github_download_url(
  String[1] $version,
  Enum['archive', 'checksum'] $download_type,
  Optional[String[1]] $extension = undef,
) >> String {
  $download_name = case $download_type {
    'archive': {
      $arch = $facts['os']['hardware'] ? {
        'x86_64' => 'amd64',
        'aarch64' => 'arm64',
        default  => $facts['os']['hardware'],
      }
      $os = $facts['kernel'].downcase

      "openvoxview_${version}_${os}_${arch}${extension}"
    }
    'checksum': {
      'checksums.txt'
    }
    default: {}
  }

  "https://github.com/voxpupuli/openvoxview/releases/download/v${version}/${download_name}"
}
