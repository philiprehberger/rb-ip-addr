# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::IpAddr do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses an IPv4 address' do
      ip = described_class.parse('192.168.1.1')
      expect(ip.to_s).to eq('192.168.1.1')
    end

    it 'parses an IPv6 address' do
      ip = described_class.parse('::1')
      expect(ip.to_s).to eq('::1')
    end

    it 'raises Error for invalid address' do
      expect { described_class.parse('not-an-ip') }.to raise_error(described_class::Error)
    end
  end

  describe Philiprehberger::IpAddr::Address do
    describe '#v4?' do
      it 'returns true for IPv4' do
        expect(described_class.new('10.0.0.1').v4?).to be true
      end

      it 'returns false for IPv6' do
        expect(described_class.new('::1').v4?).to be false
      end
    end

    describe '#v6?' do
      it 'returns true for IPv6' do
        expect(described_class.new('::1').v6?).to be true
      end

      it 'returns false for IPv4' do
        expect(described_class.new('10.0.0.1').v6?).to be false
      end
    end

    describe '#private?' do
      it 'returns true for 10.x.x.x' do
        expect(described_class.new('10.0.0.1').private?).to be true
      end

      it 'returns true for 172.16.x.x' do
        expect(described_class.new('172.16.0.1').private?).to be true
      end

      it 'returns true for 192.168.x.x' do
        expect(described_class.new('192.168.1.1').private?).to be true
      end

      it 'returns false for public address' do
        expect(described_class.new('8.8.8.8').private?).to be false
      end

      it 'returns true for IPv6 ULA' do
        expect(described_class.new('fd00::1').private?).to be true
      end
    end

    describe '#loopback?' do
      it 'returns true for 127.0.0.1' do
        expect(described_class.new('127.0.0.1').loopback?).to be true
      end

      it 'returns true for ::1' do
        expect(described_class.new('::1').loopback?).to be true
      end

      it 'returns false for non-loopback' do
        expect(described_class.new('8.8.8.8').loopback?).to be false
      end
    end

    describe '#multicast?' do
      it 'returns true for IPv4 multicast' do
        expect(described_class.new('224.0.0.1').multicast?).to be true
      end

      it 'returns true for IPv6 multicast' do
        expect(described_class.new('ff02::1').multicast?).to be true
      end

      it 'returns false for non-multicast' do
        expect(described_class.new('192.168.1.1').multicast?).to be false
      end
    end

    describe '#to_i' do
      it 'returns numeric value for IPv4' do
        expect(described_class.new('0.0.0.1').to_i).to eq(1)
      end

      it 'returns numeric value for a known address' do
        expect(described_class.new('0.0.1.0').to_i).to eq(256)
      end
    end

    describe '#to_s' do
      it 'returns the string representation' do
        expect(described_class.new('192.168.1.1').to_s).to eq('192.168.1.1')
      end
    end

    describe '#==' do
      it 'considers equal addresses equal' do
        a = described_class.new('10.0.0.1')
        b = described_class.new('10.0.0.1')
        expect(a).to eq(b)
      end

      it 'considers different addresses not equal' do
        a = described_class.new('10.0.0.1')
        b = described_class.new('10.0.0.2')
        expect(a).not_to eq(b)
      end
    end
  end

  describe '.range' do
    let(:range) { described_class.range('10.0.0.0/30') }

    it 'returns the correct size' do
      expect(range.size).to eq(4)
    end

    it 'includes an address within the range' do
      expect(range.include?('10.0.0.1')).to be true
    end

    it 'excludes an address outside the range' do
      expect(range.include?('10.0.1.1')).to be false
    end

    it 'accepts an Address object for include?' do
      ip = described_class.parse('10.0.0.2')
      expect(range.include?(ip)).to be true
    end

    it 'iterates over all addresses' do
      addresses = range.map(&:to_s)
      expect(addresses).to eq(['10.0.0.0', '10.0.0.1', '10.0.0.2', '10.0.0.3'])
    end

    it 'returns an array with to_a' do
      expect(range.to_a.length).to eq(4)
    end

    it 'returns an enumerator when no block given' do
      expect(range.each).to be_a(Enumerator)
    end

    it 'raises Error for invalid CIDR' do
      expect { described_class.range('invalid') }.to raise_error(described_class::Error)
    end

    describe 'larger range' do
      it 'reports correct size for /24' do
        expect(described_class.range('192.168.1.0/24').size).to eq(256)
      end
    end
  end
end
