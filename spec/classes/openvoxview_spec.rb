# frozen_string_literal: true

require 'spec_helper'

OPENVOXVIEW_VERSION = '1.5.0'

describe 'openvoxview' do
  on_supported_os.each do |os, facts|
    context "on #{os} with Facter #{facts[:facterversion]} and Puppet #{facts[:puppetversion]}" do
      let(:facts) { facts }

      context 'with default settings' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('openvoxview::install') }
        it { is_expected.to contain_class('openvoxview::config') }
        it { is_expected.to contain_class('openvoxview::service') }
        it { is_expected.to contain_group('openvoxview') }
        it { is_expected.to contain_user('openvoxview').with_gid('openvoxview') }
        it { is_expected.to contain_file("/opt/openvoxview-#{OPENVOXVIEW_VERSION}").with_ensure('directory') }

        it do
          is_expected.to contain_archive("/tmp/openvoxview-#{OPENVOXVIEW_VERSION}.tar.gz")
            .with_source("https://github.com/voxpupuli/openvoxview/releases/download/v#{OPENVOXVIEW_VERSION}/openvoxview_#{OPENVOXVIEW_VERSION}_linux_amd64.tar.gz")
            .with_extract_path("/opt/openvoxview-#{OPENVOXVIEW_VERSION}")
            .with_creates("/opt/openvoxview-#{OPENVOXVIEW_VERSION}/openvoxview")
        end

        it { is_expected.to contain_file("/opt/openvoxview-#{OPENVOXVIEW_VERSION}/openvoxview") }

        it do
          is_expected.to contain_file('/usr/local/bin/openvoxview')
            .with_ensure('link')
            .with_target("/opt/openvoxview-#{OPENVOXVIEW_VERSION}/openvoxview")
            .that_notifies('Service[openvoxview]')
        end

        it { is_expected.not_to contain_package('openvoxview') }

        it do
          is_expected.to contain_systemd__unit_file('openvoxview.service')
            .with_content(%r{^User=openvoxview})
            .with_content(%r{^Group=openvoxview})
            .with_content(%r{^ExecStart=/usr/local/bin/openvoxview -config /etc/openvox/openvox.yml$})
            .that_notifies('Service[openvoxview]')
        end

        it { is_expected.to contain_service('openvoxview').with_ensure(true).with_enable(true) }

        it do
          is_expected.to contain_file('/etc/openvox')
            .with_ensure('directory')
            .with_owner('openvoxview')
            .with_group('openvoxview')
        end

        it do
          is_expected.to contain_file('/etc/openvox/openvox.yml')
            .with_owner('openvoxview')
            .with_group('openvoxview')
            .that_notifies('Service[openvoxview]')
        end
      end

      context 'with install_method => package' do
        let(:params) { { install_method: 'package' } }

        if facts[:os]['family'] == 'Archlinux'
          it { is_expected.to compile.and_raise_error(%r{Provider pacman must have features 'versionable'}) }
        else
          it { is_expected.to compile.with_all_deps }
        end
        it { is_expected.to contain_package('openvoxview').with_ensure(OPENVOXVIEW_VERSION).that_notifies('Service[openvoxview]') }

        it do
          is_expected.to contain_systemd__unit_file('openvoxview.service')
            .with_content(%r{^ExecStart=/usr/bin/openvoxview -config /etc/openvox/openvox.yml$})
        end

        context 'with package_name specified' do
          let(:params) { super().merge(package_name: 'test') }

          if facts[:os]['family'] == 'Archlinux'
            it { is_expected.to compile.and_raise_error(%r{Provider pacman must have features 'versionable'}) }
          else
            it { is_expected.to compile.with_all_deps }
          end
          it { is_expected.to contain_package('openvoxview').with_name('test') }
        end

        context 'with version specified' do
          let(:version) do
            { 'archlinux' => 'latest' }.fetch(facts[:os]['family'].downcase, '1.2.3')
          end
          let(:params) { super().merge(version: version) }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('openvoxview').with_ensure(version) }
        end

        context 'with manage_service => false' do
          let(:params) { super().merge(manage_service: false) }

          if facts[:os]['family'] == 'Archlinux'
            it { is_expected.to compile.and_raise_error(%r{Provider pacman must have features 'versionable'}) }
          else
            it { is_expected.to compile.with_all_deps }
          end
          it { is_expected.to contain_package('openvoxview').that_notifies([]) }
        end
      end

      context 'with download_url specified' do
        let(:params) { { download_url: 'https://example.com/foo/bar.tgz' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive("/tmp/openvoxview-#{OPENVOXVIEW_VERSION}.tar.gz").with_source('https://example.com/foo/bar.tgz') }
      end

      context 'with manage_config_dir => false' do
        let(:params) { { manage_config_dir: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_file('/etc/openvox') }
      end

      context 'with config_dir specified' do
        let(:params) { { config_dir: '/opt/openvoxview/etc' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/opt/openvoxview/etc').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/openvoxview/etc/openvox.yml').with_ensure('file') }

        it do
          is_expected.to contain_systemd__unit_file('openvoxview.service')
            .with_content(%r{^ExecStart=/usr/local/bin/openvoxview -config /opt/openvoxview/etc/openvox.yml$})
        end
      end

      context 'with config_file specified' do
        let(:params) { { config_file: 'configuration.yaml' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/openvox/configuration.yaml').with_ensure('file') }

        it do
          is_expected.to contain_systemd__unit_file('openvoxview.service')
            .with_content(%r{^ExecStart=/usr/local/bin/openvoxview -config /etc/openvox/configuration.yaml$})
        end
      end

      context 'with manage_user => false' do
        let(:params) { { manage_user: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_user('openvoxview') }
      end

      context 'with openvoxview_user specified' do
        let(:params) { { openvoxview_user: 'test' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_user('test').with_gid('openvoxview') }
        it { is_expected.to contain_systemd__unit_file('openvoxview.service').with_content(%r{^User=test}) }
        it { is_expected.to contain_file('/etc/openvox').with_owner('test') }
        it { is_expected.to contain_file('/etc/openvox/openvox.yml').with_owner('test') }
      end

      context 'with manage_group => false' do
        let(:params) { { manage_group: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_group('openvoxview') }
      end

      context 'with openvoxview_group specified' do
        let(:params) { { openvoxview_group: 'test' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_group('test') }
        it { is_expected.to contain_user('openvoxview').with_gid('test') }
        it { is_expected.to contain_systemd__unit_file('openvoxview.service').with_content(%r{^Group=test}) }
        it { is_expected.to contain_file('/etc/openvox').with_group('test') }
        it { is_expected.to contain_file('/etc/openvox/openvox.yml').with_group('test') }
      end

      context 'with manage_service => false' do
        let(:params) { { manage_service: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/usr/local/bin/openvoxview').that_notifies([]) }
        it { is_expected.to contain_systemd__unit_file('openvoxview.service').that_notifies([]) }
        it { is_expected.not_to contain_service('openvoxview') }
        it { is_expected.to contain_file('/etc/openvox/openvox.yml').that_notifies([]) }
      end

      context 'with service_name specified' do
        let(:params) { { service_name: 'test' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_systemd__unit_file('test.service') }
        it { is_expected.to contain_service('test') }
      end

      context 'with manage_systemd_unit => false' do
        let(:params) { { manage_systemd_unit: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_systemd__unit_file('openvoxview.service') }
      end

      context 'with service_ensure => false' do
        let(:params) { { service_ensure: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('openvoxview').with_ensure(false) }
      end

      context 'with service_enable => false' do
        let(:params) { { service_enable: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('openvoxview').with_enable(false) }
      end

      describe 'configuration file' do
        let(:config_data) do
          x = catalogue.resource('file', '/etc/openvox/openvox.yml').send(:parameters)
          YAML.safe_load(x[:content])
        end

        context 'with default config settings' do
          let(:default_config) do
            {
              'listen' => '127.0.0.1',
              'port' => 5000,
              'puppetdb' => {
                'host' => 'localhost',
                'port' => 8080,
                'tls' => false,
                'tls_ignore' => true,
                'tls_ca' => nil,
                'tls_key' => nil,
                'tls_cert' => nil,
              },
              'views' => [],
              'queries' => [],
              'log_level' => nil,
              'log_format' => nil,
              'puppetca' => {
                'host' => nil,
                'port' => 8140,
                'tls' => true,
                'tls_ignore' => false,
                'tls_ca' => nil,
                'tls_key' => nil,
                'tls_cert' => nil,
                'readonly' => true,
                'deactivate_nodes' => false,
              },
            }
          end

          it { is_expected.to contain_file('/etc/openvox/openvox.yml').with_content(YAML.dump(default_config)) }
        end

        checks = {
          listen_address: {
            v: '1.2.3.4',
            path: %w[listen],
          },
          listen_port: {
            v: 1234,
            path: %w[port],
          },
          puppetdb_host: {
            v: '1.2.3.4',
            path: %w[puppetdb host],
          },
          puppetdb_port: {
            v: 1234,
            path: %w[puppetdb port],
          },
          puppetdb_tls: {
            v: true,
            path: %w[puppetdb tls],
          },
          puppetdb_tls_ignore: {
            v: false,
            path: %w[puppetdb tls_ignore],
          },
          puppetdb_tls_ca_path: {
            v: '/etc/ssl/ca.pem',
            path: %w[puppetdb tls_ca],
          },
          puppetdb_tls_key_path: {
            v: '/etc/ssl/key.pem',
            path: %w[puppetdb tls_key],
          },
          puppetdb_tls_cert_path: {
            v: '/etc/ssl/cert.pem',
            path: %w[puppetdb tls_cert],
          },
          predefined_views: {
            v: [{
              'name' => 'test',
              'facts' => [{
                'name' => 'ip',
                'fact' => 'networking.ip',
              }],
              'default_rows_per_page' => 100,
            }],
            path: %w[views],
          },
          predefined_pql_queries: {
            v: [{
              'description' => 'test',
              'query' => 'foo',
            }],
            path: %w[queries],
          },
          log_level: { v: 'warn' },
          log_format: { v: 'json' },
          puppetca_host: {
            v: 'example.com',
            path: %w[puppetca host],
          },
          puppetca_port: {
            v: 1234,
            path: %w[puppetca port],
          },
          puppetca_tls: {
            v: true,
            path: %w[puppetca tls],
          },
          puppetca_tls_ignore: {
            v: false,
            path: %w[puppetca tls_ignore],
          },
          puppetca_tls_ca_path: {
            v: '/etc/ssl/ca.pem',
            path: %w[puppetca tls_ca],
          },
          puppetca_tls_key_path: {
            v: '/etc/ssl/key.pem',
            path: %w[puppetca tls_key],
          },
          puppetca_tls_cert_path: {
            v: '/etc/ssl/cert.pem',
            path: %w[puppetca tls_cert],
          },
          puppetca_readonly: {
            v: false,
            path: %w[puppetca readonly],
          },
          puppetca_deactivate_nodes: {
            v: true,
            path: %w[puppetca deactivate_nodes],
          },
        }

        checks.each do |param, opts|
          context "with #{param} specified" do
            let(:params) { { param => opts[:v] } }

            it 'expects value to be set' do
              cfg_path = opts[:path] || [param.to_s]
              expect(config_data.dig(*cfg_path)).to eq(opts[:v])
            end
          end
        end
      end
    end
  end
end
