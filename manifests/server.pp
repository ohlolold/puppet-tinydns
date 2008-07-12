class tinydns::server::base {
	file {
		"ssh_dir":
			path => "/root/.ssh",
			owner => root,
			group => root,
			mode => 700,
			ensure => directory;

		"tinydns_key":
			path => "/root/.ssh/tinydns_dsa",
			owner => root,
			group => root,
			mode => 600,
			source => "puppet://$servername/tinydns/root/.ssh/tinydns_dsa",
			ensure => present,
			require => File["ssh_dir"];

		"tinydns_authorized_keys":
			path => "/root/.ssh/authorized_keys",
			owner => root,
			group => root,
			mode => 600,
			source => "puppet://$servername/tinydns/root/.ssh/tinydns_dsa.pub",
			ensure => present,
			require => File["ssh_dir"];

		"dnsroots.global":
			path => "/etc/dnsroots.global",
			owner => root,
			group => root,
			mode => 644,
			source => "puppet://$servername/tinydns/etc/dnsroots.global"
	}
}

define tinydns::server(
		$directory,
		$listen_address,
		$ensure = "present") {

	$svc_dir = "/service/$name"
	$tinydns_dir = $directory
	$tinydns_root = "$tinydns_dir/root"

	$dns_scripts = [
		"$tinydns_root/add-alias",
		"$tinydns_root/add-childns",
		"$tinydns_root/add-host",
		"$tinydns_root/add-mx",
		"$tinydns_root/add-ns"
	]

	User <| tag == "tinydns" |>
	Group <| tag == "tinydns" |>
	Package <| tag == "tinydns" |>

	case $ensure {
		"present": {
			exec {
				"tinydns-conf-$name":
					command => "tinydns-conf $u_tinydns $u_dnslog \
						$tinydns_dir $listen_address",
					unless => "test -d $tinydns_dir",
					path => "/usr/bin:/usr/local/bin",
					require => [ User["$u_tinydns"], User["$u_dnslog"],
						Package["djbdns"] ];

				"tinydns-servicedir-$name":
					command => "ln -sf $tinydns_dir $svc_dir",
					unless => "test -d $svc_dir",
					path => "/bin:/usr/bin",
					require => Exec["tinydns-conf-$name"]
			}

			service { $name:
				start => "/usr/local/bin/svc -u $svc_dir",
				stop => "/usr/local/bin/svc -d $svc_dir",
				restart => "/usr/local/bin/svc -t $svc_dir",
				status => "/usr/local/bin/svstat $svc_dir",
				hasstatus => true,
				ensure => running,
				require => [ Package["daemontools"],
					Exec["tinydns-servicedir-$name"] ]
			}

			file { $dns_scripts:
				owner => root,
				group => root,
				mode => 644,
				ensure => present,
				require => Exec["tinydns-conf-$name"]
			}
		}

		"absent": {
			exec { "remove-tinydns-service-$name":
					command => "(cd $svc_dir; rm $svc_dir && svc -dx . log)",
					onlyif => "test -L $svc_dir",
					path => "/bin:/usr/bin:/usr/local/bin",
					notify => Exec["delete-tinydns-dir-$name"];

				"delete-tinydns-dir-$name":
					command => "rm -rf $tinydns_dir",
					onlyif => "test -d $tinydns_dir",
					path => "/bin:/usr/bin"
			}
		}
	}
}

define tinydns::axfr_server(
		$directory,
		$tinydns_dir,
		$listen_address,
		$ensure = "present") {

	$svc_dir = "/service/$name"
	$axfrdns_dir = $directory
	$axfrdns_root = "$axfrdns_dir/root"

	User <| tag == "tinydns" |>
	Group <| tag == "tinydns" |>
	Package <| tag == "tinydns" |>

	case $ensure {
		"present": {
			exec {
				"axfrdns-conf-$name":
					command => "axfrdns-conf $u_axfrdns $u_dnslog \
						$axfrdns_dir $tinydns_dir $listen_address",
					unless => "test -d $axfrdns_dir",
					path => "/usr/bin:/usr/local/bin",
					require => [ User["$u_axfrdns"], User["$u_dnslog"],
						Package["djbdns"] ];

				"axfrdns-servicedir-$name":
					command => "ln -sf $axfrdns_dir $svc_dir",
					unless => "test -d $svc_dir",
					path => "/bin:/usr/bin",
					require => Exec["axfrdns-conf-$name"]
			}

			service { $name:
				start => "/usr/local/bin/svc -u $svc_dir",
				stop => "/usr/local/bin/svc -d $svc_dir",
				restart => "/usr/local/bin/svc -t $svc_dir",
				status => "/usr/local/bin/svstat $svc_dir",
				hasstatus => true,
				ensure => running,
				require => [ Package["daemontools"],
					Exec["axfrdns-servicedir-$name"] ]
			}
		}

		"absent": {
			exec {
				"remove-axfrdns-service-$name":
					command => "(cd $svc_dir; rm $svc_dir && svc -dx . log)",
					onlyif => "test -L $svc_dir",
					path => "/bin:/usr/bin:/usr/local/bin";

				"delete-axfrdns-dir-$name":
					command => "rm -rf $axfrdns_dir",
					onlyif => "test -d $axfrdns_dir",
					path => "/bin:/usr/bin",
					notify => Exec["remove-axfrdns-service-$name"]
			}
		}
	}
}
