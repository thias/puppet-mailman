# Class: mailman::params
#
class mailman::params {
  if $::osfamily == 'Debian' {
    $cfg_path  = '/etc/mailman/mm_cfg.py'
    $user      = 'list'
    $group     = 'list'
    $hasstatus = false
  } elsif $::osfamily == 'RedHat' {
    $cfg_path  = '/usr/lib/mailman/Mailman/mm_cfg.py'
    $user      = 'mailman'
    $group     = 'mailman'
    $hasstatus = true # RedHat's mailmanctl supports 'status'
  } else {
    $cfg_path  = '/usr/lib/mailman/Mailman/mm_cfg.py'
    $user      = 'mailman'
    $group     = 'mailman'
    $hasstatus = false
  }
}
