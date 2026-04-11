# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-04-10

### Added
- `Address` now includes `Comparable` for sorting and comparison operators
- `Address#succ` returns the next IP address
- `Address#pred` returns the previous IP address
- `Range#network` returns the network address of a CIDR block
- `Range#broadcast` returns the broadcast/last address of a CIDR block
- `Range#prefix` returns the CIDR prefix length
- `Range#netmask` returns the subnet mask (dotted-decimal for IPv4)
- `Range#overlap?` checks if two ranges share addresses

## [0.2.0] - 2026-04-04

### Added
- `link_local?` method for detecting link-local addresses (169.254.0.0/16, fe80::/10)
- `reserved?` method combining private, loopback, multicast, and link-local checks
- GitHub issue template gem version field
- Feature request "Alternatives considered" field

## [0.1.8] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.7] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.6] - 2026-03-26

### Changed

- Add Sponsor badge and fix License link format in README

## [0.1.5] - 2026-03-24

### Fixed
- Align README one-liner with gemspec summary
- Fix stray character in CHANGELOG formatting

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.1] - 2026-03-22

### Fixed

- Remove trailing period from README description
- Add bug_tracker_uri to gemspec

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Parse and classify IPv4 and IPv6 addresses
- Private, loopback, and multicast detection
- CIDR range operations with size, include, and enumeration
- Numeric conversion with to_i
