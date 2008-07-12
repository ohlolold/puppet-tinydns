define tinydns::slave($directory, $ensure = "present") {
	$tinydns_dir = $directory
	$tinydns_root = "$tinydns_dir/root"
	$makefile = "$tinydns_root/Makefile"
	$warning_file = "DO_NOT_MODIFY_HERE"

	case $ensure {
		"present": {
			file {
				$makefile:
					owner => root,
					group => root,
					mode => 644,
					source =>
						"puppet://$servername/tinydns/misc/Makefile.slave",
					ensure => present,
					require => Exec["tinydns-conf-$name"];

				"$tinydns_root/$warning_file":
					owner => root,
					group => root,
					mode => 644,
					content => "\n",
					ensure => present,
					require => Exec["tinydns-conf-$name"]
			}
		}
	}
}
