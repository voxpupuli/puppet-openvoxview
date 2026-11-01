# frozen_string_literal: true

require 'spec_helper'

describe 'openvoxview::github_download_url' do
  context 'with download_type => checksum' do
    it { is_expected.to run.with_params('1.2.3', 'checksum').and_return('https://github.com/voxpupuli/openvoxview/releases/download/v1.2.3/checksums.txt') }
  end

  context 'with download_type => archive' do
    arches = %w[x86_64 amd64 aarch64 arm64].freeze
    kernels = %w[Linux FreeBSD].freeze
    exts = %w[.tar.gz .deb].freeze

    arches.each do |a|
      kernels.each do |k|
        context "with arch => #{a} and kernel => #{k}" do
          let(:facts) do
            {
              'os' => { 'hardware' => a },
              'kernel' => k,
            }
          end

          exts.each do |ext|
            context "with extension => #{ext}" do
              let(:arch) do
                h = facts['os']['hardware']
                {
                  'x86_64' => 'amd64',
                  'aarch64' => 'arm64',
                }.fetch(h, h)
              end
              let(:kernel) do
                facts['kernel'].downcase
              end

              it { is_expected.to run.with_params('1.2.3', 'archive', ext).and_return("https://github.com/voxpupuli/openvoxview/releases/download/v1.2.3/openvoxview_1.2.3_#{kernel}_#{arch}#{ext}") }
            end
          end
        end
      end
    end
  end
end
