define tinydns::cache(
		$directory,
		$listen_address,
		$lookup_test = "www.google.com",
		$ensure = "present") {

	$svc_dir = "/service/$name"
	$dnscache_dir = $directory
	$dnscache_root = "$dnscache_dir/root"

	User <| tag == "tinydns" |>
	Group <| tag == "tinydns" |>
	Package <| tag == "tinydns" |>

	case $ensure {
		"present": {
			exec {
				"dnscache-conf-$name":
					command => "dnscache-conf $u_dnscache $u_dnslog \
						$dnscache_dir $listen_address",
					unless => "test -d $dnscache_dir",
					path => "/usr/bin:/usr/local/bin",
					require => [ User["$u_dnscache"], User["$u_dnslog"],
						Package["djbdns"] ];

				"dnscache-servicedir-$name":
					command => "ln -sf $dnscache_dir $svc_dir",
					unless => "test -d $svc_dir",
					path => "/bin:/usr/bin",
					require => Exec["dnscache-conf-$name"]
			}

			service { $name:
				start => "/usr/local/bin/svc -u $svc_dir",
				stop => "/usr/local/bin/svc -d $svc_dir",
				restart => "/usr/local/bin/svc -t $svc_dir",
				status => "/usr/local/bin/svstat $svc_dir",
				hasstatus => true,
				ensure => running,
				require => [ Package["daemontools"],
					Exec["dnscache-servicedir-$name"] ]
			}

			file { "$dnscache_root/servers/@":
				owner => root,
				group => root,
				source => "/etc/dnsroots.global",
				ensure => present,
				require => File["dnsroots.global"]
			}
		}

		"absent": {
			exec {
				"remove-dnscache-service-$name":
					command => "(cd $svc_dir; rm $svc_dir && svc -dx . log)",
					onlyif => "test -L $svc_dir",
					path => "/bin:/usr/bin:/usr/local/bin";

				"delete-dnscache-dir-$name":
					command => "rm -rf $dnscache_dir",
					onlyif => "test -d $dnscache_dir",
					path => "/bin:/usr/bin",
					require => Exec["remove-dnscache-service-$name"]
			}
		}
	}
}

define tinydns::cacheallow($service) {
	file { $name:
		owner => root,
		group => root,
		mode => 644,
		ensure => present,
		require => Exec["dnscache-servicedir-$service"],
		notify => Service[$service]
	}
}

define tinydns::forwardzone($service, $data) {
	file { $name:
		owner => root,
		group => root,
		mode => 644,
		content => $data,
		ensure => present,
		require => Exec["dnscache-servicedir-$service"],
		notify => Service[$service]
	}
}
