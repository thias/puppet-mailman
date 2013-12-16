# Simple Mailman module. It's standalone, but requires at least an MTA and
# usually an apache httpd server to be useful.
#
# See /usr/lib/mailman/Mailman/Defaults.py for all of the available options
# to be passed using mm_cfg_settings. Note that all parameters are python
# code, so final quoting is required for strings.
#
# Sample Usage :
#     class { 'mailman':
#       default_url_host    => 'lists.example.com',
#       default_email_host  => 'example.com',
#       default_url_pattern => 'https://%s/mailman/',
#       mailman_site_list   => 'mailman-list',
#       mm_cfg_settings     => {
#         'ALLOW_SITE_ADMIN_COOKIES' => 'Yes',
#         'PUBLIC_ARCHIVE_URL' => "'https://%(hostname)s/pipermail/%(listname)s'",
#         'MTA' => "'Postfix'",
#         'POSTFIX_STYLE_VIRTUAL_DOMAINS' => "'False'",
#         'DEFAULT_SUBJECT_PREFIX' => "''",
#         'DEFAULT_REPLY_GOES_TO_LIST' => '1',
#       },
#     }
#
class mailman (
  $default_url_host    = $::fqdn,
  $default_email_host  = $::fqdn,
  $default_url_pattern = 'http://%s/mailman/',
  $mailman_site_list   = 'mailman',
  $add_virtualhost     = {},
  $mm_cfg_settings     = {},
  $mm_cfg_path         = $::mailman::params::cfg_path,
  $mm_user             = $::mailman::params::user,
  $mm_group            = $::mailman::params::group,
) inherits mailman::params {

  # Main package and service it provides
  package { 'mailman': ensure => installed }
  service { 'mailman':
    require   => Exec['create_mailman_site_list'],
    enable    => true,
    ensure    => running,
    hasstatus => true,
  }

  # Main Mailman configuration file (well, python script)
  file { $mm_cfg_path :
    content => template('mailman/mm_cfg.py.erb'),
    owner   => 'root',
    group   => $mm_group,
    mode    => '0640',
    notify  => Service['mailman'],
  }

  # Create the mandatory site list.
  # The password is immediately changed, and appears in the puppet logs,
  # so make sure unprivileged users can't read them, or change it again.
  exec { 'create_mailman_site_list':
    require   => File[$mm_cfg_path],
    command   => "/usr/lib/mailman/bin/newlist -q ${mailman_site_list} ${mailman_site_list}@${default_email_host} ${uniqueid} && /usr/lib/mailman/bin/change_pw -l ${mailman_site_list}",
    creates   => "/var/lib/mailman/lists/${mailman_site_list}/config.pck",
    logoutput => true,
  }

}

