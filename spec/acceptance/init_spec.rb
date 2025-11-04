# frozen_string_literal: true

require 'spec_helper_acceptance'

latest_release = '0.1.18'

describe 'class openvoxview:' do
  context 'with default settings' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          class { 'openvoxview':
          }
        PUPPET
      end
    end

    describe service('openvoxview.service') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe command('/usr/local/bin/openvoxview -version') do
      its(:stdout) { is_expected.to start_with latest_release }
    end
  end
end
