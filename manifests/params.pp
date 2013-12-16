# Class: mailman::params
#
class mailman::params {
  if $::osfamily == 'Debian' {
    $cfg_path = '/etc/mailman/mm_cfg.py'
    $user     = 'list'
    $group    = 'list'
  } else {
    $cfg_path = '/usr/lib/mailman/Mailman/mm_cfg.py'
    $user     = 'mailman'
    $group    = 'mailman'
  }
}
