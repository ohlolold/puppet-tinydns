#!/bin/sh

TOPDIR=/etc/puppet/modules/tinydns
TMPDIR=$TOPDIR/files/tmp
ETCDIR=$TOPDIR/files/etc

[ ! -d $TOPDIR ] && echo ""; echo "ERROR: $TOPDIR doesn't exist!"; \
	echo ""; exit 1
[ ! -d $TMPDIR ] && mkdir $TMPDIR
[ ! -d $ETCDIR ] && mkdir $ETCDIR

cd $TMPDIR

wget -q ftp://ftp.internic.net/domain/named.root -O named.root

egrep -v 'AAAA' named.root | sed -e '/^$/d' -e '/^ *$/d' -e '/^;/d' -e '/^\./d' -e 's/[A-Z]\.ROOT-SERVERS\.NET\. *.*A *//' > $ETCDIR/dnsroots.global
