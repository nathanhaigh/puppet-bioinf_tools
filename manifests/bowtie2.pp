class puppet_bioinf_tools::bowtie2 (
	$version  = '2.0.0-beta7',
  $toolname = "bowtie2" ) inherits puppet_bioinf_tools
{
  # url to get tool from
  $url = "http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${version}/bowtie2-${version}-linux-x86_64.zip"
  
  #only need to run curl if
  get { "${toolname}-${version}-get":
    source => $url,
    target => "bowtie2-${version}-linux-x86_64.zip",
  }
  extract { "${toolname}-${version}-extract":
    source  => "bowtie2-${version}-linux-x86_64.zip",
    creates => "bowtie2-${version}",
    require => Get["${toolname}-${version}-get"],
  }
  file { "$puppet_bioinf_tools::target_dir/$toolname":
    ensure => directory,
  }
  exec { "${toolname}-${version}-move":
    command => "mv $puppet_bioinf_tools::staging_dir/bowtie2-${version} $puppet_bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    creates => "$puppet_bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    require => [ Extract["${toolname}-${version}-extract"], File["$puppet_bioinf_tools::target_dir/$toolname"] ],
  }
  file { "$puppet_bioinf_tools::target_dir/$toolname/$toolname":
    ensure => link,
    target => "${toolname}-${version}",
    require => Exec["${toolname}-${version}-move"],
  }
  # need to add $tools::target_dir/$toolname/$toolname to $PATH
}
