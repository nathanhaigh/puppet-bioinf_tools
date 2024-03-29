class bioinf_tools::bowtie2 (
	$version  = '2.0.0-beta7',
  $toolname = "bowtie2" )
  {
  include bioinf_tools

  # Tool URL and variables.
  $url = "http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${version}/bowtie2-${version}-linux-x86_64.zip"
  $tool_target = "bowtie2-${version}-linux-x86_64.zip"
  $tool_create = "bowtie2-${version}"

  # Pull down tool.
  bioinf_tools::get { "${toolname}-${version}-get":
    source => $url,
    target => $tool_target,
  }

  # Extract the tool into staging directory.
  bioinf_tools::extract { "${toolname}-${version}-extract":
    source  => $tool_target,
    creates => $tool_create,
    require => Bioinf_tools::Get["${toolname}-${version}-get"],
  }

  # Tool target directory.
  file { "$bioinf_tools::target_dir/$toolname":
    ensure => directory,
  }

  # Move extracted files into target directory.
  exec { "${toolname}-${version}-move":
    command => "mv $bioinf_tools::staging_dir/$tool_create $bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    creates => "$bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    require => [ Extract["${toolname}-${version}-extract"], File["$bioinf_tools::target_dir/$toolname"] ],
  }

  # Create default symlink for tool.
  file { "$bioinf_tools::target_dir/$toolname/$toolname":
    ensure  => link,
    target  => "${toolname}-${version}",
    require => Exec["${toolname}-${version}-move"],
  }

  # Add tool executable into profile.d for all users path.
  file { "/etc/profile.d/$toolname.sh":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => "export PATH=$bioinf_tools::target_dir/$toolname/$toolname:\$PATH",
    require => File["$bioinf_tools::target_dir/$toolname/$toolname"],
  }
}
