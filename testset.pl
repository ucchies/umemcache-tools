#!/usr/bin/perl

use strict;
use warnings;

require './util.pl';

sub testThreeClassSet {
    my ($sock) = @_;
    my $byte = int(rand(200)) + 50;
    my $leftitems = 10;

    my $keyprefix = 'k';
    my $keynum = 0;
    my $freeitems = -1;

    &commFlushAll($sock);

    do {
	&commSet($sock, $keyprefix.$keynum, $byte, 0);
	if ($keynum % 10) {
	    my @status = &getStatus($sock);
	    $freeitems = $items{$status[1]}{free_chunks};
	}
	$keynum++;
    } until ($freeitems eq $leftitems);

    do {
	&commSet($sock, $keyprefix.$keynum, int($byte / 1.25), 0);
	if ($keynum % 10) {
	    my @status = &getStatus($sock);
	    $freeitems = $items{$status[1]}{free_chunks};
	}
	$keynum++;
    } until ($freeitems eq $leftitems);

    do {
	&commSet($sock, $keyprefix.$keynum, int($byte * 1.25), 0);
	if ($keynum % 10) {
	    my @status = &getStatus($sock);
	    $freeitems = $items{$status[1]}{free_chunks};
	}
	$keynum++;
    } until ($freeitems eq $leftitems);

    for my $n (0..1000) {
	$class = int(rand(3)) + 1;
	if ($class == 1) {
	    &commSet($sock, $keyprefix.$keynum, int($byte / 1.25), 0);
	}
	elsif ($class == 2) {
	    &commSet($sock, $keyprefix.$keynum, $byte, 0);
	}
	elsif ($class == 3) {
	    &commSet($sock, $keyprefix.$keynum, int($byte * 1.25), 0);
	}
	$keynum++;
    }
}
