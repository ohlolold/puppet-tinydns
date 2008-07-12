define tinydns::master($directory, $slaves, $zones, $ensure = "present") {
	$tinydns_dir = $directory
	$tinydns_root = "$tinydns_dir/root"
	$makefile = "$tinydns_root/Makefile"
	$warning_file = "DATA_FILE_AUTO_GENERATED"

	case $ensure {
		"present": {
			file {
				$makefile:
					owner => root,
					group => root,
					mode => 644,
					content => template("tinydns/Makefile.erb"),
					ensure => present,
					require => Exec["tinydns-conf-$name"];

				"$tinydns_root/$warning_file":
					owner => root,
					group => root,
					mode => 644,
					content => "\n",
					ensure => present,
					require => Exec["tinydns-conf-$name"];

				"$tinydns_root/zones":
					owner => root,
					group => root,
					mode => 755,
					ensure => directory,
					require => Exec["tinydns-conf-$name"]
			}
		}
	}
}
