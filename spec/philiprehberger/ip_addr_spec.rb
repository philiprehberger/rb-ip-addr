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

    describe '#link_local?' do
      it 'detects IPv4 link-local' do
        addr = described_class.new('169.254.1.1')
        expect(addr.link_local?).to be true
      end

      it 'rejects non-link-local IPv4' do
        addr = described_class.new('192.168.1.1')
        expect(addr.link_local?).to be false
      end

      it 'detects IPv6 link-local' do
        addr = described_class.new('fe80::1')
        expect(addr.link_local?).to be true
      end

      it 'rejects non-link-local IPv6' do
        addr = described_class.new('2001:db8::1')
        expect(addr.link_local?).to be false
      end
    end

    describe '#reserved?' do
      it 'returns true for private addresses' do
        expect(described_class.new('10.0.0.1').reserved?).to be true
      end

      it 'returns true for loopback' do
        expect(described_class.new('127.0.0.1').reserved?).to be true
      end

      it 'returns true for multicast' do
        expect(described_class.new('224.0.0.1').reserved?).to be true
      end

      it 'returns true for link-local' do
        expect(described_class.new('169.254.0.1').reserved?).to be true
      end

      it 'returns false for public addresses' do
        expect(described_class.new('8.8.8.8').reserved?).to be false
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

    describe '#<=>' do
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

      it 'sorts addresses by numeric value' do
        addrs = ['10.0.0.3', '10.0.0.1', '10.0.0.2'].map { |ip| described_class.new(ip) }
        sorted = addrs.sort.map(&:to_s)
        expect(sorted).to eq(['10.0.0.1', '10.0.0.2', '10.0.0.3'])
      end

      it 'supports comparison operators' do
        a = described_class.new('10.0.0.1')
        b = described_class.new('10.0.0.2')
        expect(a).to be < b
        expect(b).to be > a
      end

      it 'returns nil for non-Address' do
        a = described_class.new('10.0.0.1')
        expect(a <=> 'not an address').to be_nil
      end
    end

    describe '#succ' do
      it 'returns the next IPv4 address' do
        addr = described_class.new('10.0.0.1')
        expect(addr.succ.to_s).to eq('10.0.0.2')
      end

      it 'crosses octet boundaries' do
        addr = described_class.new('10.0.0.255')
        expect(addr.succ.to_s).to eq('10.0.1.0')
      end

      it 'returns the next IPv6 address' do
        addr = described_class.new('::1')
        expect(addr.succ.to_s).to eq('::2')
      end
    end

    describe '#pred' do
      it 'returns the previous IPv4 address' do
        addr = described_class.new('10.0.0.2')
        expect(addr.pred.to_s).to eq('10.0.0.1')
      end

      it 'crosses octet boundaries' do
        addr = described_class.new('10.0.1.0')
        expect(addr.pred.to_s).to eq('10.0.0.255')
      end

      it 'raises for 0.0.0.0' do
        addr = described_class.new('0.0.0.0')
        expect { addr.pred }.to raise_error(Philiprehberger::IpAddr::Error)
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

    describe '#network' do
      it 'returns the network address' do
        range = described_class.range('192.168.1.0/24')
        expect(range.network.to_s).to eq('192.168.1.0')
      end

      it 'returns the network address for a non-aligned CIDR' do
        range = described_class.range('10.0.0.5/30')
        expect(range.network.to_s).to eq('10.0.0.4')
      end
    end

    describe '#broadcast' do
      it 'returns the broadcast address for /24' do
        range = described_class.range('192.168.1.0/24')
        expect(range.broadcast.to_s).to eq('192.168.1.255')
      end

      it 'returns the last address for /30' do
        range = described_class.range('10.0.0.0/30')
        expect(range.broadcast.to_s).to eq('10.0.0.3')
      end
    end

    describe '#prefix' do
      it 'returns the prefix length' do
        expect(described_class.range('10.0.0.0/24').prefix).to eq(24)
      end

      it 'returns 30 for /30' do
        expect(described_class.range('10.0.0.0/30').prefix).to eq(30)
      end
    end

    describe '#netmask' do
      it 'returns dotted-decimal for IPv4 /24' do
        expect(described_class.range('10.0.0.0/24').netmask).to eq('255.255.255.0')
      end

      it 'returns dotted-decimal for IPv4 /16' do
        expect(described_class.range('172.16.0.0/16').netmask).to eq('255.255.0.0')
      end

      it 'returns prefix notation for IPv6' do
        expect(described_class.range('fe80::/10').netmask).to eq('/10')
      end
    end

    describe '#overlap?' do
      it 'detects overlapping ranges' do
        a = described_class.range('10.0.0.0/24')
        b = described_class.range('10.0.0.128/25')
        expect(a.overlap?(b)).to be true
      end

      it 'detects non-overlapping ranges' do
        a = described_class.range('10.0.0.0/24')
        b = described_class.range('10.0.1.0/24')
        expect(a.overlap?(b)).to be false
      end

      it 'detects overlap when other contains self' do
        a = described_class.range('10.0.0.0/25')
        b = described_class.range('10.0.0.0/24')
        expect(a.overlap?(b)).to be true
      end

      it 'raises for non-Range argument' do
        a = described_class.range('10.0.0.0/24')
        expect { a.overlap?('10.0.0.0/24') }.to raise_error(Philiprehberger::IpAddr::Error)
      end
    end

    describe '#subnets' do
      it 'splits an IPv4 /24 into four /26 subnets' do
        range = described_class.range('10.0.0.0/24')
        subnets = range.subnets(prefix: 26).to_a
        expect(subnets.map(&:to_s)).to eq(
          ['10.0.0.0/26', '10.0.0.64/26', '10.0.0.128/26', '10.0.0.192/26']
        )
        expect(subnets.map(&:size)).to eq([64, 64, 64, 64])
      end

      it 'splits an IPv4 /24 into two /25 subnets' do
        range = described_class.range('10.0.0.0/24')
        subnets = range.subnets(prefix: 25).to_a
        expect(subnets.length).to eq(2)
        expect(subnets.map(&:to_s)).to eq(['10.0.0.0/25', '10.0.0.128/25'])
      end

      it 'raises ArgumentError when prefix equals current prefix' do
        range = described_class.range('10.0.0.0/24')
        expect { range.subnets(prefix: 24) }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError when prefix exceeds IPv4 max' do
        range = described_class.range('10.0.0.0/24')
        expect { range.subnets(prefix: 33) }.to raise_error(ArgumentError)
      end

      it 'splits an IPv6 /32 into four /34 subnets' do
        range = described_class.range('2001:db8::/32')
        subnets = range.subnets(prefix: 34).to_a
        expect(subnets.length).to eq(4)
        expect(subnets.map(&:prefix)).to eq([34, 34, 34, 34])
      end

      it 'returns an Enumerator when no block given' do
        range = described_class.range('10.0.0.0/24')
        expect(range.subnets(prefix: 26)).to be_a(Enumerator)
      end
    end
  end
end
