#!/usr/bin/perl

use vars qw($filename $directory $url %icons);

$filename  = "jabbercontacts.txt";
$url       = 0;
my $dir    = "images/";
%icons     = ( online       => 'online.png',
	       chat         => 'chat.png',
	       away         => 'away.png',
	       xa           => 'xa.png',
	       dnd          => 'dnd.png',
	       offline      => 'offline.png',
	       disconnected => 'offline.png'
	       );

use constant BUFFER_SIZE => 4_096;
use strict;
use CGI;
my $q = CGI->new();
my $jid = $q->param('jid');
my $status = getstatus($jid);
if($q->param('meth') eq 'printall') { printall(); exit; }
if($q->param('meth') eq 'text') { print $q->header(); print $status; exit;}
if($url) {
    print $q->redirect(-url => $dir . $icons{$status}); exit;
}
my $buffer = "";
my $image = $dir . $icons{lc($status)};
my ($type) = $image =~ /\.(\w+)$/;
$type eq "jpg" and $type = "jpeg";
print $q->header(-type => "image/$type", -expires => "-1d" );
binmode STDOUT;

local *IMAGE;
open (IMAGE, $image) || die "Cannot open file $image: $!";
while (read(IMAGE,$buffer,BUFFER_SIZE)) {
    print $buffer;
}
close(IMAGE);



sub getstatus {
    open(FILE,"$filename");
    foreach my $l (<FILE>) {
	my ($jid, $status) = split('<#>',$l);
	return $status if $jid =~ /^$_[0]$/i;
    }
    close(FILE);
}

sub printall {
    print $q->header();
    open(FILE,"$filename");
    foreach my $l (sort <FILE>) {
        my ($jid, $status) = split('<#>',$l);
        print "$jid: $status<br>\n";
    }
    close(FILE);
}

