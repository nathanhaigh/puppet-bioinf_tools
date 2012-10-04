class bioinf_tools::bowtie2 (
	$version  = '2.0.0-beta7',
  $toolname = "bowtie2" ) inherits bioinf_tools
{
  # Tool URL.
  $url = "http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${version}/bowtie2-${version}-linux-x86_64.zip"
  
  # Pull down tool.
  get { "${toolname}-${version}-get":
    source => $url,
    target => "bowtie2-${version}-linux-x86_64.zip",
  }

  # Extract the tool into staging directory.
  extract { "${toolname}-${version}-extract":
    source  => "bowtie2-${version}-linux-x86_64.zip",
    creates => "bowtie2-${version}",
    require => Get["${toolname}-${version}-get"],
  }

  # Tool target directory.
  file { "$bioinf_tools::target_dir/$toolname":
    ensure => directory,
  }

  # Move extracted files into target directory.
  exec { "${toolname}-${version}-move":
    command => "mv $bioinf_tools::staging_dir/bowtie2-${version} $bioinf_tools::target_dir/$toolname/${toolname}-${version}",
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
