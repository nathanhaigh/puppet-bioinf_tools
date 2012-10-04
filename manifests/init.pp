class bioinf_tools (
  $staging_dir = '/usr/local/src',
  $target_dir = '/usr/local/bioinf' )
  {
  Exec {
    path => [
      '/usr/bin',
      '/bin',
    ],
    cwd => $staging_dir,
  }

  # TODO: these file resources do not recursively ensure ALL parent dirs are present,
  # i.e. the immediate parent MUST exist. 
  file { "$staging_dir":
    ensure => directory,
  }

  file { "$target_dir":
    ensure => directory,
  }
}
