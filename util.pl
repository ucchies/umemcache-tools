#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
#use Data::Dumper;

sub getSocket {
    my $host = $_[0];
    my $sock = IO::Socket::INET->new(PeerAddr => $host,
    Proto => 'tcp');
    return $sock;
}

sub getStatus {
    my ($sock) = @_;
    
    my (%classes, $maxid);

    print $sock "stats slabs\r\n";
    while (<$sock>) {
	last if /^END/;
	if (/^STAT (\d+):(\w+) (\d+)/) {
	    $classes{$1}{$2} = $3;
	    $maxid = $1;
	}
    }
    return ($maxid, %classes);
}

sub getAllStatus {
    my ($sock) = @_;
    
    my (%classes, $maxid);

    print $sock "stats items\r\n";
    while (<$sock>) {
	last if /^END/;
	if (/^STAT items:(\d+):(\w+) (\d+)/) {
	    $classes{$1}{$2} = $3;
	    $maxid = $1;
	}
    }
    print $sock "stats slabs\r\n";
    while (<$sock>) {
	last if /^END/;
	if (/^STAT (\d+):(\w+) (\d+)/) {
	    $classes{$1}{$2} = $3;
	}
    }


    return ($maxid, %classes);
}


sub commSet {
    my ($sock, $key, $byte, $expire) = @_;
    my $value = 'a' x $byte;

    print $sock "set $key 0 $expire $byte\r\n$value\r\n";
    while (<$sock>) {
        last if (/^STORED/);
	if (/^SERVER_ERROR (.+)/) {
	    print "Set error: $1\n";
	    return 0;
	}
    }
    return 1;
}

sub commDelByKey {
    my ($sock, $key) = @_;
    
    print $sock "delete $key\r\n";
    while (<$sock>) {
	last if /^DELETED/;
    }
    return 1;
}

sub commDelByKeys {
    my ($sock, @keys) = @_;
    
    foreach my $key (@keys) {
	print $sock "delete $key\r\n";
	while (<$sock>) {
	    last if /^DELETED/;
	}
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

sub commGet {
    my ($sock, $key) = @_;
    my $ret = 0;
    
    print $sock "get $key\r\n";
    while (<$sock>){
	last if /^END/;
	if (/^VALUE (\S+) (\d+) (\d+)/) {
	    $ret = 1;
	}
    }
    return $ret;
}

sub itemExist {
    my ($sock, $key) = @_;
    my $ret = 0;
    
    print $sock "get $key\r\n";
    while (<$sock>){
	last if /^END/;
	if (/^VALUE (\S+) (\d+) (\d+)/) {
	    $ret = 1;
	}
    }
    return $ret;
}

sub printUmemTime {
    my ($sock) = @_;
    
    print $sock "stats umemtime\r\n";
    while (<$sock>){
	last if /^END/;
	print $_;
    }
}

sub commFlushAll {
    my ($sock) = @_;
    print $sock "flush_all\r\n";
    return 1;
}

# sub comm_rand {
#     my $sock = $_[0];
#     my $
# }

1;
