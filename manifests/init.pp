$u_tinydns = "tinydns"
$u_dnslog = "dnslog"
$u_dnscache = "dnscache"
$u_axfrdns = "axfrdns"
$g_tinydns = "tinydns"

class tinydns {
	@package { [ daemontools, ucspi-tcp, djbdns ]:
		tag => "tinydns",
		ensure => installed
	}

	@group { $g_tinydns:
		gid => 53,
		tag => "tinydns",
		ensure => present
	}

	@user {
		$u_tinydns:
			uid => 53,
			gid => $g_tinydns,
			comment => "Tinydns user",
			home => "/",
			shell => "/sbin/nologin",
			tag => "tinydns",
			ensure => present,
			allowdupe => false,
			require => Group["$g_tinydns"];

		$u_dnslog:
			uid => 54,
			gid => $g_tinydns,
			comment => "Dnslog user",
			home => "/",
			shell => "/sbin/nologin",
			tag => "tinydns",
			ensure => present,
			allowdupe => false,
			require => Group["$g_tinydns"];

		$u_dnscache:
			uid => 55,
			gid => $g_tinydns,
			comment => "Dnscache user",
			home => "/",
			shell => "/sbin/nologin",
			tag => "tinydns",
			ensure => present,
			allowdupe => false,
			require => Group["$g_tinydns"];

		$u_axfrdns:
			uid => 56,
			gid => $g_tinydns,
			comment => "Axfrdns user",
			home => "/",
			shell => "/sbin/nologin",
			tag => "tinydns",
			ensure => present,
			allowdupe => false,
			require => Group["$g_tinydns"];
	}
}

import '*'
