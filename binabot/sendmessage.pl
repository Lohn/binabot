#!/usr/bin/perl

###
# With this script you can send message in the commandline.
# Usage: sendmessage.pl <jid> <message>
#        e.g. ./sendmessage.pl tehkahless@jabber.org Hi !!
#
#
# Copyright (C) by Kahless 2001
###

use IPC::ShareLite;
use strict;

if($#ARGV < 0) { print "Usage: $0 <jid> [<message (or STDIN)>]\n"; exit; }
my $share = IPC::ShareLite->new( -key => 3824, -create => 'no',
				 -destroy => 'no') || die $!;

my $i = 0;
print "Trying to connect to bot ...\n";
my $msg = "";
if($#ARGV < 1) {
  while(<STDIN>) {
    s/\r?\n/<br>/g;
    $msg .= $_;
  }
} else {
  $msg = join(' ',@ARGV[1..$#ARGV]);
}
while($share->fetch() ne "ready") { $i++; if($i > 100) {
    die "Can't connect via IPC to jabberbot (key: 3824)";
} }
print "Connected... Sending Message \n";
$share->store("Q: sendmessage $ARGV[0] $msg");
waitforstring();
print "Message Sent.\n";
$share->store("ready");



sub waitforstring {
    my $str = "";
    while (!($str =~ /^A:.*?$/)) {
	$str = $share->fetch();
    }
}
