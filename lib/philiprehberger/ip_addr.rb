# frozen_string_literal: true

require 'ipaddr'
require_relative 'ip_addr/version'

module Philiprehberger
  module IpAddr
    class Error < StandardError; end

    # Parsed IP address wrapper
    class Address
      # @param ip_string [String] IP address string
      def initialize(ip_string)
        @raw = ip_string.to_s.strip
        @addr = ::IPAddr.new(@raw)
      rescue ::IPAddr::InvalidAddressError => e
        raise Error, "Invalid IP address: #{e.message}"
      end

      # @return [Boolean] true if this is an IPv4 address
      def v4?
        @addr.ipv4?
      end

      # @return [Boolean] true if this is an IPv6 address
      def v6?
        @addr.ipv6?
      end

      # @return [Boolean] true if this is a private address
      def private?
        return private_v4? if v4?
        return private_v6? if v6?

        false
      end

      # @return [Boolean] true if this is a loopback address
      def loopback?
        @addr.loopback?
      end

      # @return [Boolean] true if this is a multicast address
      def multicast?
        if v4?
          ::IPAddr.new('224.0.0.0/4').include?(@addr)
        elsif v6?
          ::IPAddr.new('ff00::/8').include?(@addr)
        else
          false
        end
      end

      # @return [Integer] numeric representation of the address
      def to_i
        @addr.to_i
      end

      # @return [String] string representation of the address
      def to_s
        @addr.to_s
      end

      # @return [Boolean] equality check
      def ==(other)
        return false unless other.is_a?(Address)

        to_i == other.to_i
      end

      private

      def private_v4?
        [
          ::IPAddr.new('10.0.0.0/8'),
          ::IPAddr.new('172.16.0.0/12'),
          ::IPAddr.new('192.168.0.0/16')
        ].any? { |range| range.include?(@addr) }
      end

      def private_v6?
        ::IPAddr.new('fc00::/7').include?(@addr)
      end
    end

    # CIDR range wrapper
    class Range
      include Enumerable

      # @param cidr [String] CIDR notation string
      def initialize(cidr)
        @cidr = cidr.to_s.strip
        @network = ::IPAddr.new(@cidr)
      rescue ::IPAddr::InvalidAddressError => e
        raise Error, "Invalid CIDR range: #{e.message}"
      end

      # @return [Integer] number of addresses in the range
      def size
        if @network.ipv4?
          prefix = @network.prefix
          2**(32 - prefix)
        else
          prefix = @network.prefix
          2**(128 - prefix)
        end
      end

      # @param ip [Address, String] IP address to check
      # @return [Boolean] true if the range includes the given IP
      def include?(ip)
        addr = ip.is_a?(Address) ? ::IPAddr.new(ip.to_s) : ::IPAddr.new(ip.to_s)
        @network.include?(addr)
      rescue ::IPAddr::InvalidAddressError
        false
      end

      # Iterate over all addresses in the range
      # @yield [Address] each address in the range
      # @return [Enumerator] if no block given
      def each(&block)
        return enum_for(:each) unless block

        start_int = @network.to_range.first.to_i
        end_int = @network.to_range.last.to_i

        (start_int..end_int).each do |int|
          addr = @network.ipv4? ? int_to_v4(int) : int_to_v6(int)
          block.call(Address.new(addr))
        end
      end

      # @return [Array<Address>] all addresses in the range
      def to_a
        each.to_a
      end

      # @return [String] string representation
      def to_s
        @cidr
      end

      private

      def int_to_v4(int)
        [24, 16, 8, 0].map { |shift| (int >> shift) & 0xFF }.join('.')
      end

      def int_to_v6(int)
        groups = (0..7).map { |i| (int >> (112 - 16 * i)) & 0xFFFF }
        groups.map { |g| format('%x', g) }.join(':')
      end
    end

    # Parse an IP address string
    #
    # @param str [String] IP address string
    # @return [Address] parsed address
    def self.parse(str)
      Address.new(str)
    end

    # Create a CIDR range
    #
    # @param cidr [String] CIDR notation string
    # @return [Range] the IP range
    def self.range(cidr)
      Range.new(cidr)
    end
  end
end
