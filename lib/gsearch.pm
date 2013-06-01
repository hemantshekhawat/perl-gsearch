#!/usr/bin/perl
#
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Escape;
use Mojo::DOM;
use Mojo::DOM::CSS;
use JSON;
use Encode;


my $base_url = "https://www.google.com.hk";

my @user_agents = ('Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0', 
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0', 
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)', 
        'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14', 
        'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36', 
        'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; TheWorld)');

sub parse{    
    my %rets = ();
    return %rets if (@_ == 0);
    my ($html) = @_;
    my $dom = Mojo::DOM->new($html); 
    my @test = $dom->find('li.g')->each;
    my $cnt = @test;
    print STDERR "cnt=$cnt\n";
    #my $title_arr_ref = $dom->find('ol[id="rso"] > li[class="g"] > div > h3 > a');
    #my $brief_arr_ref = $dom->find('ol[id="rso"] > li[class="g"] > div > div > div > span[class="st"]');
    my $rank = 1;
    for(my $i = 0; $i < $cnt; ++$i) {
        next if ($test[$i] =~ m/id=\"newsbox\"/ or $test[$i] =~ m/id=\"imagebox_bigimages\"/);
        my $part_dom = Mojo::DOM->new($test[$i]);
        print STDERR "$i\n";
        eval {
            $rets{$rank}{'title'} = $part_dom->find('div h3 a')->[0]->all_text;
            $rets{$rank}{'url'} = $part_dom->find('div h3 a')->[0]{href};
            $rets{$rank}{'brief'} = $part_dom->find('div div div span[class="st"]')->[0]->all_text;
            ++$rank;
        };
        if ($@) {
            print STDERR "********************ERROR**********************\n";
            print STDERR "$@\n$test[$i]\n";
            print STDERR "********************ERROR**********************\n";
        }
    }
    #print $brief_arr_ref, "\n";
    #my $arr_ref = $dom->find('div ol li[class="g"]');
    #my $rank = 1;
    #$arr_ref->each(sub {
    #        eval {
    #            my $part_dom = Mojo::DOM->new(shift);
    #            #print $part_dom->find('div h3 a')->[0]{href}, "\n"; 
    #            #print $part_dom->find('div h3 a')->[0]->all_text, "\n"; 
    #            #print $part_dom->find('div div div span[class="st"]')->[0]->all_text, "\n";
    #            $rets{$rank}{'title'} = $part_dom->find('div h3 a')->[0]->all_text;
    #            $rets{$rank}{'url'} = $part_dom->find('div h3 a')->[0]{href};
    #            $rets{$rank}{'brief'} = $part_dom->find('div div div span[class="st"]')->[0]->all_text;
    #            ++$rank;
    #        };
    #        if ($@) {
    #            print "$@\n";
    #        }
    #    }); 
    #print $rank, "\n";
    return %rets;
}

sub search {
    my ($query, $lang, $num) = @_;
    $query = uri_escape($query); 
    my $url = "$base_url/search?hl=$lang&num=$num&q=$query";
    print STDERR "$url\n";
    my $try_num = 3; 
    my %rets = ();
    while ($try_num > 0) {
        eval {
            my $ua = LWP::UserAgent->new(timeout=>540);
            my $req = HTTP::Request->new('GET'=>"$url");
            srand;
            my $index = int(rand($#user_agents + 1));
            print STDERR "$user_agents[$index]\n";
            $req->header('User-agent', $user_agents[$index]);
            $req->header('connection', 'keep-alive');
            my $res = $ua->request($req);
            print STDERR $res->status_line, "\n";
            if ($res->is_success) {
                print $res->content_type,"\n";
                print $res->content_charset,"\n";
                %rets = parse($res->decoded_content); 
                #for my $rank (keys %rets) {
                #    print "title=$rets{$rank}{'title'}\n";
                #}
                last; 
            } 
        };
        if ($@) {
            --$try_num; 
        } else {
            last;
        }
    }
    return \%rets;
}

sub search_json {
    my $charset = pop @_;
    my $hash_ref = search(@_);
    return encode($charset, to_json($hash_ref));
}
#search(@ARGV);
1;
