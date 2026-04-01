# frozen_string_literal: true

require_relative 'lib/philiprehberger/ip_addr/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-ip_addr'
  spec.version = Philiprehberger::IpAddr::VERSION
  spec.authors = ['philiprehberger']
  spec.email = ['philiprehberger@users.noreply.github.com']

  spec.summary = 'Enhanced IP address library with CIDR, classification, and range operations'
  spec.description = 'Parse and classify IPv4/IPv6 addresses with private, loopback, and multicast ' \
                     'detection. Supports CIDR range operations including size calculation, membership ' \
                     'testing, and enumeration. Built on Ruby stdlib ipaddr.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-ip_addr'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-ip-addr'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-ip-addr/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-ip-addr/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
