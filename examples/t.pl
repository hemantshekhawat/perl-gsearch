#!/usr/bin/perl
#

use lib qw(../lib);
use strict;
use warnings;
use gsearch;

@ARGV == 3 or die;
my ($query, $lang, $num) = @ARGV;
my $ret = search($query, $lang, $num);
for my $rank (keys %{$ret}) {
    print "$rank title: ", $ret->{$rank}->{'title'},"\n";
    print "$rank url: ", $ret->{$rank}->{'url'},"\n";
    print "$rank brief: ", $ret->{$rank}->{'brief'},"\n\n";
}

