# frozen_string_literal: true

require 'ipaddr'
require_relative 'ip_addr/version'

module Philiprehberger
  module IpAddr
    class Error < StandardError; end

    # Parsed IP address wrapper
    class Address
      include Comparable

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

      # @return [Boolean] true if this is a link-local address
      def link_local?
        if v4?
          ::IPAddr.new('169.254.0.0/16').include?(@addr)
        elsif v6?
          ::IPAddr.new('fe80::/10').include?(@addr)
        else
          false
        end
      end

      # @return [Boolean] true if this is any special-purpose address
      def reserved?
        private? || loopback? || multicast? || link_local?
      end

      # @return [Integer] numeric representation of the address
      def to_i
        @addr.to_i
      end

      # @return [String] string representation of the address
      def to_s
        @addr.to_s
      end

      # @return [Integer, nil] comparison result
      def <=>(other)
        return nil unless other.is_a?(Address)

        to_i <=> other.to_i
      end

      # @return [Address] next IP address
      def succ
        Address.new(@addr.ipv4? ? int_to_v4(to_i + 1) : int_to_v6(to_i + 1))
      end

      # @return [Address] previous IP address
      def pred
        raise Error, 'Cannot decrement below 0.0.0.0' if to_i.zero?

        Address.new(@addr.ipv4? ? int_to_v4(to_i - 1) : int_to_v6(to_i - 1))
      end

      private

      def int_to_v4(int)
        [24, 16, 8, 0].map { |shift| (int >> shift) & 0xFF }.join('.')
      end

      def int_to_v6(int)
        groups = (0..7).map { |i| (int >> (112 - (16 * i))) & 0xFFFF }
        groups.map { |g| format('%x', g) }.join(':')
      end

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
          2**(32 - prefix)
        else
          2**(128 - prefix)
        end
      end

      # @return [Address] network address (first address in the block)
      def network
        Address.new(@network.to_range.first.to_s)
      end

      # @return [Address] broadcast address (last address in the block)
      def broadcast
        Address.new(@network.to_range.last.to_s)
      end

      # @return [Integer] CIDR prefix length
      def prefix
        @network.prefix
      end

      # @return [String] subnet mask
      def netmask
        if @network.ipv4?
          mask_int = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF
          [24, 16, 8, 0].map { |shift| (mask_int >> shift) & 0xFF }.join('.')
        else
          "/#{prefix}"
        end
      end

      # @param other [Range] another CIDR range
      # @return [Boolean] true if the two ranges share any addresses
      def overlap?(other)
        raise Error, 'Argument must be a Range' unless other.is_a?(Range)

        @network.include?(other.network.to_s) || other.include?(network.to_s)
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

      # @return [Boolean] true if this is an IPv4 range
      def ipv4?
        @network.ipv4?
      end

      # @return [Boolean] true if this is an IPv6 range
      def ipv6?
        @network.ipv6?
      end

      # Split the range into equal-size child subnets at the given prefix length
      # @param prefix [Integer] the child subnet prefix length
      # @yield [Range] each child subnet
      # @return [Enumerator<Range>] if no block given
      # @raise [ArgumentError] if prefix is not larger than the current prefix or exceeds the address family max
      def subnets(prefix:)
        max_prefix = ipv6? ? 128 : 32
        unless prefix.is_a?(Integer) && prefix > @network.prefix && prefix <= max_prefix
          raise ArgumentError,
                "prefix must be an Integer greater than #{@network.prefix} and <= #{max_prefix}, got #{prefix.inspect}"
        end

        return enum_for(:subnets, prefix: prefix) unless block_given?

        step = 2**(max_prefix - prefix)
        start_int = @network.to_range.first.to_i
        end_int = @network.to_range.last.to_i
        int = start_int
        while int <= end_int
          addr = ipv4? ? int_to_v4(int) : int_to_v6(int)
          yield Range.new("#{addr}/#{prefix}")
          int += step
        end
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
        groups = (0..7).map { |i| (int >> (112 - (16 * i))) & 0xFFFF }
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
