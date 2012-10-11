l#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;

sub getSocket {
    my $host = $_[0];
    my $sock = IO::Socket::INET->new(PeerAddr => $host,
    Proto => 'tcp');
    return $sock;
}

sub getStatus {
    my ($sock) = @_;
    
    my (%items, $maxid);

    print $sock "stats slabs\r\n";
    while (<$sock>) {
	last if /^END/;
	if (/^STAT (\d+):(\w+) (\d+)/) {
	    $items{$1}{$2} = $3;
	    $maxid = $1;
	}
    }
    my @status = (%items, $maxid);
    return @status;
}

sub commSet {
    my ($sock, $key, $byte, $expire) = @_;
    my $value = 'a' x $byte;

    print $sock "set $key 0 $expire $byte\r\n$value\r\n";
    while (<$sock>) {
        last if (/^STORED/);
    }
    return 1;
}

sub commDel {
    my ($sock, $clsid, $items) = @_;

    my @keys;
    print $sock "stats cachedump $clsid $items\r\n";
    my $i = 0;
    while (<$sock>) {
        last if /^END/;
        if (/^ITEM (\S+)/) {
            $keys[$i] = $1;
        }
        $i++;
    }
    
    foreach my $key (@keys) {
        print $sock "delete $key\r\n";
        while (<$sock>) {
            last if /^DELETED/;
        }
    }
    return 1;
}

sub commFlushAll {
    my ($sock) = @_;
    print $sock 'flush_all\r\n';
    return 1;
}

# sub comm_rand {
#     my $sock = $_[0];
#     my $
# }
