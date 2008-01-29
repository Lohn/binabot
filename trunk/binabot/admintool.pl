#!/usr/bin/perl -w

use IPC::ShareLite;
sub bindm { } sub sbind { }
use lib qw('.');
use strict;
use vars qw($IPCkey $curircNet $curircChan %cmds);
$curircNet = ""; $curircChan = "";
open(FILE,"config.pl");
while (<FILE>) { next unless /^\$IPCkey/; eval; last; }
close(FILE);
my $share = IPC::ShareLite->new( -key => $IPCkey, -create => 'no',
                                 -destroy => 'no') || die $!;

main();

sub main {
  out("Trying to connect to the bot..");
  if(!wait4ready()) {
    out("ERROR: Can't get a ready message, may the bot is not started ?");
  }
  out("Connected...");
  () while(make());
}

sub make {
  my $cmd = prompt();
  my (@cmd) = split(/ /,$cmd);
  %cmds = (exit       => "return",
	   ircstatus  => \&ircstatus,
	   setircnet  => \&setircnet,
	   setircchan => \&setircchan,
	   say        => \&say,
	   help       => \&help,
	   ircconnect => \&ircconnect,
	   ircjoin    => \&ircjoin,
	   ircpart    => \&ircpart,
	  );
  if(!defined $cmds{$cmd[0]}) { out("Unknown command ?"); return 1; }
  if($cmd[0] eq 'exit') { return 0; }
  $cmds{$cmd[0]}->(@cmd);
  return 1;
}

sub prompt {
  out("JPB> ",1);
  my $rc = <STDIN>;
  $rc =~ s/\n//g;
  return $rc;
}

sub help {
  my (@cmd) = @_;
  out("Sorry, there is no real help yet, but here is a list of commands:");
  foreach my $command (keys %cmds) {
    out("           $command");
  }
  out("Hope that help ! If you have questions, look to http://jpb.sourceforge.net and visit the forums or write me an email");
}

sub out {
  my ($string, $test) = @_;
  print $string; print "\n" unless $test;
}

sub wait4ready {
  my $i = 0;
  $i++ while($share->fetch() ne "ready" && $i < 100);
  return 0 if $i > 99;
  return 1;
}

sub wait4answer {
  my $start = time();
  my $od = -1;
  until(($share->fetch()) =~ /^A:/) {
    my $d = time() - $start;
    if($d > 5 && $d != $od) {
      out("Waited for $d seconds.");
      $od = $d;
    }
    if($d > 10) { out("Timeout !"); return 0 }
  }
  return 1;
}

sub request {
  wait4ready();
  $share->store($_[0]);
  wait4answer();
  my $rc = $share->fetch();
  $rc =~ s/^A: //g;
  $share->store("ready");
  return $rc;
}

sub ircstatus {
  my (@cmd) = @_;
  my $a = request("Q: ircstatus server");
  if($a eq 'noserver') {
    out("I'm currently not connected to any IRC server.");
  } else {
    foreach my $l (split(/\n/,$a)) {
      my @infos = split(/\t/,$l);
      if($curircNet eq '') { $curircNet = $infos[0]; }
      out(sprintf("%3s %-50s" . ($curircNet eq $infos[0] ? "   <-- selected server" : "" ),($curircNet eq $infos[0] ? "-->" : ""),$infos[0]));
      foreach my $i (@infos[1..$#infos]) {
	if($curircChan eq '') { $curircChan = $i; }
	out(sprintf("%3s      %-45s" . ($curircChan eq $i ? "   <-- selected channel" : ""),($curircChan eq $i ? "-->" : ""),$i));
      }
    }
    out("   Current selected server : $curircNet");
    out("   Current selected channel: $curircChan");
  }
}

sub setircnet {
  my (@cmd) = @_;
  if(!defined($cmd[1])) { out("Usage: setircnet <network>"); return; }
  $curircNet = $cmd[1];
  out("Current selected server is now $cmd[1]");
}

sub setircchan {
  my (@cmd) = @_;
  if(!defined($cmd[1])) { out("Usage: setircchan <network>"); return; }
  $curircChan = $cmd[1];
  out("Current selected server is now $cmd[1]");
}

sub say {
  my (@cmd) = @_;
  if(!defined $cmd[1]) { out("Usage: say <message>"); return; }
  if(!defined $curircNet)  { out("You have to use setircnet first.");  }
  if(!defined $curircChan) { out("You have to use setircchan first."); }
  out(request("Q: privmsg $curircNet $curircChan " . join(' ', @cmd[1..$#cmd])));
}

sub ircconnect {
  my (@cmd) = @_;
  if(!defined $cmd[1]) { out("Usage: ircconnect <server> [<nick>]"); return; }
  out(request("Q: ircconnect " . join(' ',@cmd[1..$#cmd])));
  if(!$curircNet) { $curircNet = $cmd[1];
		    out("selected IRC server is now $cmd[1]"); }
}

sub ircjoin {
  my (@cmd) = @_;
  if(!defined $cmd[1]) { out("Usage: ircjoin <channel>"); return; }
  if(!$curircNet)  { out("You have to use setircnet first."); return; }
  out(request("Q: ircjoin $cmd[1] $curircNet"));
}

sub ircpart {
  my (@cmd) = @_;
  if(!defined $cmd[1]) { out("Usage: ircpart <channel>"); return; }
  if(!defined $curircNet)  { out("You have to use setircnet first.");  }
  out(request("Q: ircpart $cmd[1] $curircNet"));
}
