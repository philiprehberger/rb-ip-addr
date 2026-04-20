# philiprehberger-ip_addr

[![Tests](https://github.com/philiprehberger/rb-ip-addr/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-ip-addr/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-ip_addr.svg)](https://rubygems.org/gems/philiprehberger-ip_addr)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-ip-addr)](https://github.com/philiprehberger/rb-ip-addr/commits/main)

Enhanced IP address library with CIDR, classification, and range operations

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-ip_addr"
```

Or install directly:

```bash
gem install philiprehberger-ip_addr
```

## Usage

```ruby
require "philiprehberger/ip_addr"

ip = Philiprehberger::IpAddr.parse('192.168.1.1')
ip.v4?      # => true
ip.private? # => true
ip.to_i     # => 3232235777
ip.to_s     # => "192.168.1.1"
```

### Classification

```ruby
ip = Philiprehberger::IpAddr.parse('127.0.0.1')
ip.loopback?  # => true

ip = Philiprehberger::IpAddr.parse('224.0.0.1')
ip.multicast? # => true

ip = Philiprehberger::IpAddr.parse('::1')
ip.v6?      # => true
ip.loopback? # => true

ip = Philiprehberger::IpAddr.parse('169.254.1.1')
ip.link_local? # => true

ip = Philiprehberger::IpAddr.parse('10.0.0.1')
ip.reserved?   # => true (private, loopback, multicast, or link-local)

ip = Philiprehberger::IpAddr.parse('8.8.8.8')
ip.reserved?   # => false
```

### Comparison and Arithmetic

```ruby
a = Philiprehberger::IpAddr.parse('10.0.0.1')
b = Philiprehberger::IpAddr.parse('10.0.0.5')
a < b       # => true
a.succ.to_s # => "10.0.0.2"
b.pred.to_s # => "10.0.0.4"

[b, a].sort.map(&:to_s) # => ["10.0.0.1", "10.0.0.5"]
```

### CIDR Ranges

```ruby
range = Philiprehberger::IpAddr.range('10.0.0.0/24')
range.size                    # => 256
range.include?('10.0.0.42')   # => true
range.include?('10.0.1.1')    # => false

range = Philiprehberger::IpAddr.range('10.0.0.0/30')
range.each { |ip| puts ip }
range.to_a.map(&:to_s)  # => ["10.0.0.0", "10.0.0.1", "10.0.0.2", "10.0.0.3"]
```

### Subnet Operations

```ruby
range = Philiprehberger::IpAddr.range('192.168.1.0/24')
range.network.to_s   # => "192.168.1.0"
range.broadcast.to_s # => "192.168.1.255"
range.netmask        # => "255.255.255.0"
range.prefix         # => 24

other = Philiprehberger::IpAddr.range('192.168.1.128/25')
range.overlap?(other) # => true
```

### Subnet splitting

```ruby
range = Philiprehberger::IpAddr.range('10.0.0.0/24')
range.subnets(prefix: 26).map(&:to_s)
# => ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26", "10.0.0.192/26"]

range.subnets(prefix: 26).first.size # => 64

v6 = Philiprehberger::IpAddr.range('2001:db8::/32')
v6.subnets(prefix: 34).count # => 4

range.subnets(prefix: 26) # => #<Enumerator: ...> when called without a block
```

### Bytes

```ruby
addr = Philiprehberger::IpAddr.parse("192.168.0.1")
addr.to_bytes # => [192, 168, 0, 1]
```

## API

| Method | Description |
|--------|-------------|
| `IpAddr.parse(str)` | Parse an IP address string into an Address |
| `IpAddr.range(cidr)` | Create a CIDR range object |
| `Address#v4?` | True if IPv4 |
| `Address#v6?` | True if IPv6 |
| `Address#private?` | True if private/ULA address |
| `Address#loopback?` | True if loopback address |
| `Address#multicast?` | True if multicast address |
| `Address#link_local?` | True if link-local address |
| `Address#reserved?` | True if private, loopback, multicast, or link-local |
| `Address#to_i` | Numeric representation |
| `Address#to_s` | String representation |
| `Address#to_bytes` | Octets (4 for IPv4, 16 for IPv6) |
| `Address#<=>(other)` | Compare addresses for sorting |
| `Address#succ` | Next IP address |
| `Address#pred` | Previous IP address |
| `Range#size` | Number of addresses in range |
| `Range#include?(ip)` | Check if address is in range |
| `Range#each` | Iterate over all addresses |
| `Range#to_a` | Array of all addresses |
| `Range#network` | Network address of the CIDR block |
| `Range#broadcast` | Broadcast/last address of the CIDR block |
| `Range#prefix` | CIDR prefix length |
| `Range#netmask` | Subnet mask (dotted-decimal for IPv4) |
| `Range#overlap?(other)` | Check if two ranges share addresses |
| `Range#subnets(prefix:)` | Yield equal-size child subnets at the given prefix length |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-ip-addr)

🐛 [Report issues](https://github.com/philiprehberger/rb-ip-addr/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-ip-addr/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
