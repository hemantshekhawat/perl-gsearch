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
    print 'title: ', $ret->{$rank}->{'title'},"\n";
    print 'url: ', $ret->{$rank}->{'url'},"\n";
    print 'brief: ', $ret->{$rank}->{'brief'},"\n\n";
}

