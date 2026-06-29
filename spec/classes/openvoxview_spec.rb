# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'openvoxview' do
  let(:config_data) do
    x = catalogue.resource('file', '/etc/openvox/openvox.yml').send(:parameters)
    YAML.safe_load(x[:content])
  end

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
      it { is_expected.to contain_archive('/tmp/openvoxview-1.5.0.tar.gz') }
      it { is_expected.to contain_file('/etc/openvox').with_ensure('directory') }
      it { is_expected.to contain_file('/opt/openvoxview-1.5.0').with_ensure('directory') }
      it { is_expected.to contain_file('/opt/openvoxview-1.5.0/openvoxview') }
      it { is_expected.to contain_file('/usr/local/bin/openvoxview').with_target('/opt/openvoxview-1.5.0/openvoxview') }
      it { is_expected.to contain_systemd__unit_file('openvoxview.service') }
      it { is_expected.to contain_service('openvoxview') }

      it do
        is_expected.to contain_file('/etc/openvox/openvox.yml')
          .without_content(%r{^log_level:})
          .without_content(%r{^log_format:})
      end
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
            version: 'latest',
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

    context 'with log_level' do
      let(:params) { { log_level: 'warn' } }

      it { expect(config_data['log_level']).to eq('warn') }
    end

    context 'with log_format' do
      let(:params) { { log_format: 'json' } }

      it { expect(config_data['log_format']).to eq('json') }
    end
  end
end
