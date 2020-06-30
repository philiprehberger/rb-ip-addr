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
| `Address#to_i` | Numeric representation |
| `Address#to_s` | String representation |
| `Range#size` | Number of addresses in range |
| `Range#include?(ip)` | Check if address is in range |
| `Range#each` | Iterate over all addresses |
| `Range#to_a` | Array of all addresses |

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
