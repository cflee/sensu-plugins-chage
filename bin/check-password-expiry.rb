#! /usr/bin/env ruby
#
#   check-password-expiry.rb
#
# DESCRIPTION: Checks Linux accounts for password expiry dates.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   commands: chage, grep, cut, sudo
#
# USAGE:
#   check-password-expiry.rb -w warn_days -c critical_days
#
# NOTES:
#
# LICENSE:
#   Copyright 2017 Chiang Fong Lee <myself@cflee.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
require 'etc'
require 'open3'
require 'sensu-plugin/check/cli'
require 'sensu-plugins-chage/util'

class CheckPasswordExpiry < Sensu::Plugin::Check::CLI
  include SensuPluginsChage::Util

  # Sensu::Plugin::CLI includes Mixlib::CLI
  option :warning,
         short: '-w WARNING',
         long: '--warning',
         description: 'Number of days to password expiry',
         proc: proc(&:to_i),
         default: 7

  option :critical,
         short: '-c CRITICAL',
         long: '--critical',
         description: 'Number of days to password expiry',
         proc: proc(&:to_i),
         default: 3

  def run
    # accumulators
    crit_users = []
    warn_users = []

    # Sanity check
    raise 'Critical level must be smaller than warning level!' if config[:critical] >= config[:warning]

    # Iterate over all users, using the getpwent() POSIX function via Etc
    Etc.passwd do |u|
      # don't rely on the Passwd Struct having the change attribute, use chage.
      chage_out, status = Open3.capture2('sudo', 'chage', '-l', u.name)

      # bail early if there was some error, whether from sudo or chage
      unknown 'sudo/chage did not execute successfully' unless status.success?

      # parse output, skip if password doesn't expire or has expired
      days = days_to_password_expiry(Date.today, chage_out)
      next if days == 'never' || days < 0

      # determine which category based on config
      if days <= config[:warning] && days > config[:critical]
        warn_users << { username: u.name, days: days }
      elsif days <= config[:critical]
        crit_users << { username: u.name, days: days }
      end
    end

    # Prepare output message based on config
    all_users = crit_users + warn_users
    msg = all_users.map { |u| "#{u[:username]} (#{u[:days]} days)" }.join(', ')

    # Determine overall check result
    if !crit_users.empty?
      critical msg
    elsif !warn_users.empty?
      warning msg
    else
      ok "no accounts expiring within #{config[:critical]} or #{config[:warning]} days"
    end
  end
end
