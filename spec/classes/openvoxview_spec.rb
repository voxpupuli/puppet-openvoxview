# frozen_string_literal: true

require 'spec_helper'

describe 'openvoxview' do
  on_supported_os.each do |os, facts|
    context "on #{os} with default settings" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('openvoxview::install') }
      it { is_expected.to contain_class('openvoxview::config') }
      it { is_expected.to contain_class('openvoxview::service') }
      it { is_expected.to contain_group('openvoxview') }
      it { is_expected.to contain_user('openvoxview').with_gid('openvoxview') }
      it { is_expected.to contain_archive('/tmp/openvoxview-0.1.18.tar.gz') }
      it { is_expected.to contain_file('/etc/openvox').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/openvox/openvox.yml') }
      it { is_expected.to contain_file('/opt/openvoxview-0.1.18').with_ensure('directory') }
      it { is_expected.to contain_file('/opt/openvoxview-0.1.18/openvoxview') }
      it { is_expected.to contain_file('/usr/local/bin/openvoxview').with_target('/opt/openvoxview-0.1.18/openvoxview') }
      it { is_expected.to contain_systemd__unit_file('openvoxview.service') }
      it { is_expected.to contain_service('openvoxview') }
    end

    context "on #{os} with custom settings" do
      let(:facts) do
        facts
      end

      let(:params) do
        case facts[:os]['family']
        when 'Archlinux'
          {
            install_method: 'package',
            version: 'latest'
          }
        else
          {
            install_method: 'package',
          }
        end
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('openvoxview::install') }
      it { is_expected.to contain_package('openvoxview') }
    end
  end
end
