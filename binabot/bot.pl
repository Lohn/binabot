#!/usr/bin/perl -w

###
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
###
#   Jabber Perl Bot
#   Copyright (C) 2001 Kahless
#                         jid: tehkahless@jabber.org
#                       email: kahless@users.sourceforge.net
#                       email: kahless@st-ac.de
#                         ICQ: 50647169
###


use diagnostics;
use IPC::ShareLite;
use Net::Jabber qw(Client);
use strict;
use Carp;
use Data::Dumper;
use vars qw($server $username $pass $Debug $Con $owner $contacts $i $shareipc $ipctimeout $savefile $save $debug $filename $IPCcom $IRCbot $eventlooptimeout $stdIRCnick $localaddr $ircBot $VERSION %flags $jabberbot $IPCkey);
$VERSION = 0.4;
$i = 0;
$main::ircBot = undef;
use lib qw('.');
use modulehandler;
main::initdebug(1);
my $modules = modulehandler->new();
$Debug = Net::Jabber::Debug->new(level => 2,
                                 );
eval `cat config.pl` || die @!;
if($IPCcom == 1) { if($IRCbot == 1) { $eventlooptimeout = -1; }
		   $eventlooptimeout = 1;
	       }
if($IRCbot == 1)    { $eventlooptimeout = -1; }
elsif($IPCcom == 1) { $eventlooptimeout = 1; }
else                { $eventlooptimeout = 0; }
if($username eq "EditTheConfigFile")
{ die "You haven't edit your config file!"; }
pd("success");
$modules->modulesloaded($savefile);
main::initdebug(1);
print "$pass - $username .. \n";		 
my %roster;

$SIG{HUP} = \&Stop;$SIG{KILL} = \&Stop;$SIG{TERM} = \&Stop;$SIG{INT} = \&Stop;

$Debug = Net::Jabber::Debug->new(level => 2,
				 );
if($jabberbot) {
    $Con = new Net::Jabber::Client();
    
    $Con->SetCallBacks("message" => \&InMessage,
		       "presence" => \&InPresence,
		       "iq" => \&InIQ
		       );
    $Con->Connect(hostname => $server);

    if($Con->Connected()) {
	print "We are connected to the server...\n";
    } else {
        print "Couldn't connect to the server... Please check your server configuration\n";
    }

my @result = $Con->AuthSend(username => $username,
			 password => $pass,
			 resource => "Bot"
			 );
main::pd("AuthSend",\@result);
if($result[0] eq "401") { tryregister(); }

%roster = $Con->RosterGet();
main::pd("roster..... ", \%roster);
        $modules->got_msg( type => 'intern',
                           body => 'RosterGet',
                           from => 'IPC',
                           jid  => 'IPC',
                           resource => 'IPC',
                           tag      => 'IPC',
			   other    => { roster => \%roster }
                           );
    $Con->PresenceSend();
}
$shareipc = IPC::ShareLite->new( -key => $IPCkey,
				 -create => 'yes',
				 -destroy => 'yes') || die $!;
$shareipc->store("ready");
my $start = time();
while(!($jabberbot) || defined($Con->Process($eventlooptimeout))) {
    my $str = $shareipc->fetch();
    my $ustr = $str;
    if($str =~ /^Q:.*?/) {
	$str =~ s/Q: //g;
	$modules->got_msg( type => 'IPC',
			   body => $str,
			   from => 'IPC',
			   jid  => 'IPC',
			   resource => 'IPC',
			   tag      => 'IPC',
			   );
    }
    if($str eq "ready") { $start = time(); }
    else { if(time() > $start + $ipctimeout) { $start = time(); $shareipc->store("ready"); }
	 main::pd("IPC: $str (" . ($ipctimeout - (time() - $start)) . ")");
       }
    if(defined $ircBot) { eval { $ircBot->do_one_loop(); }; warn $@ if $@; }
}

$shareipc->store("NOTready");
print "ERROR: The connection was killed...\n"; exit(0);


sub tryregister {
    my @result = $Con->RegisterSend(username => $username,
				    resource => "Bot",
				    password => $pass,
				    email    => "kahless\@st-ac.de",
				    key      => "blah"
				 );
    $Debug->Log2("RegisterSend", \@result);
}

sub InMessage {
    shift;
    my $message = shift; #Net::Jabber::Message->new(@_);
  main::pd("Got: " . $message->GetXML());
    my $type = $message->GetType();
    my $from = $message->GetFrom();
    my $resource = "";#$message->GetResource();
    ($from,$resource) = split('/',$from);
    my $subject = $message->GetSubject();
    my $body = $message->GetBody();
    my @delay = $message->GetX("jabber:x:delay");
    return if($#delay > -1);
    my @confX = $message->GetX("jabber:x:conference");
    my $xjid = ""; my $xconf = "";
    if($#confX > -1) {
      $xjid = $confX[0]->GetJID() if $confX[0]->DefinedJID();
      eval {
	$xconf = $confX[0]->GetConference();
      };
      warn $! if $!;
    }
    $modules->got_msg( type => $type,
		       body => $body,
		       from => $from,
		       jid  => $from,
		       resource => $resource,
		       tag      => 'message',
                       other    => {
                           jid        => $xjid,
                           conference => $xconf
                           }
		       );
}

sub InIQ {
  main::pd(\@_);
    shift;
    my $iq = shift; #new Net::Jabber::IQ(@_);
    my $from = $iq->GetFrom();
    my $type = $iq->GetType();
    my $query = $iq->GetQuery();
    return unless defined $query;
    my $xmlns = $query->GetXMLNS();
    main::pd("IQ: ",$iq,"\nQuery:",$query);
    my $resource = "";#$message->GetResource();
    ($from,$resource) = split('/',$from);
    if($xmlns eq "jabber:iq:version") {
	my $reply = $iq->Reply(type => "result");
	my $pftquery = $reply->NewQuery("jabber:iq:version");
	$pftquery->SetName('JabberBot');
	$pftquery->SetOS("wos was i");
	$pftquery->SetVer("0.01");
	$Con->Send($reply);
	print $reply->GetXML() . "\n";
    } elsif ($xmlns eq "jabber:iq:last") {
	my $reply = $iq->Reply(type => "result");
        my $pftquery = $reply->NewQuery("jabber:iq:last");
	$pftquery->SetMessage("blah?");
	$pftquery->SetSeconds(257);
	$Con->Send($reply);
        print $reply->GetXML() . "\n";
    } elsif ($xmlns eq "jabber:iq:time") {
	my $reply = $iq->Reply(type => "result");
        my $pftquery = $reply->NewQuery("jabber:iq:time");
	$pftquery->SetDisplay(time());
	$Con->Send($reply);
        print $reply->GetXML() . "\n";
    }
    print "===\n";
    print "IQ\n";
    print "  From $from\n";
    print "  Type: $type\n";
    print "  XMLNS: $xmlns";
    print "===\n";
    print $iq->GetXML(),"\n";
    print "===\n";
  print $query->GetXML(),"\n" . "===\n";
}

sub InPresence {
    shift;
    $Debug->Log2("InPresence .. got: ", @_);
    my $presence = shift; #new Net::Jabber::Presence(@_);
    return unless defined $presence;
    return unless $presence->GetFrom("jid");
    $Con->PresenceDBParse($presence);
    my $from = $presence->GetFrom() || "";
    my $type = $presence->GetType() || "";
    my $status = $presence->GetStatus() || "";
    my $show = $presence->GetShow() || "";
    my $resource;
    ($from,$resource) = split('/',$from);
    $modules->got_msg( type     => $type,
                       body     => "",
                       from     => $from,
                       resource => $resource,
		       tag      => 'presence',
		       other    => {
			   show   => $show,
			   status => $status
			   }
                       );
    print "===\n";
    print "Presence\n";
    print "  From $from\n";
    print "  Type: $type\n";
    print "  Status: $status ($show)\n";
    print "===\n";
}

sub Stop {
    $shareipc->store("NOTready");
    print "Exiting...\n";
    $Con->Disconnect() if $jabberbot;
    exit(0);
}

sub main::Exit {
  $modules->saveall($savefile);
  $modules->exiting();
  if(defined $ircBot) {
    for(my $n = 0; $n < 100 ; $n++) { $ircBot->do_one_loop(); }
  }
  Stop();
}

{
    my $debug = 0;

    sub main::pd {
	my $string;
	my @args = @_;
	my ($pkg, $file, $line) = caller();
	my $arg;
	foreach $arg (@args) {
	    if(ref($arg) eq '') { $string .= $arg; }
	    else { $string .= Dumper($arg); }
	}
	print " ### $pkg - $line : $string ###\n" if $debug != 0;
    }

    sub main::initdebug {
	$debug = $_[0] || 0;
    }
}

sub bindm    { main::pd("aufgerufen $_[1] - $_[3] " . $i++); $modules->registermodule(@_); }
sub sbind { bindm(name => shift, method => shift, pattern => shift, 
		  type => shift || 'chat', flags => shift || ''); }
sub ipcbind { bindm(name => shift, method => shift, pattern => shift,
		    type => 'IPC', flags => shift || '', tag => 'IPC'); }
#sub RosterAdd { my(%args) = @_; return 0 if IsInList($args{jid}); $Con->RosterAdd( jid => $args{jid}, name => $args{name}); $conlist->add( jid => $args{jid}, name => $args{name}); }
sub RosterAdd { my(%args) = @_; return 0 if IsInList($args{jid}); $Con->RosterAdd( jid => $args{jid}, name => $args{name}); }

sub reload {
  main::pd("reload .. test ..");
    $modules->reloads();
}

sub user {
    my (%args) = @_;
    $username = $args{username};
    $pass     = $args{pass};
    pd("drin..");
}

sub MessageSend {
    my (%args) = @_;
  main::pd("Sending message ... ");
    $Con->MessageSend( to => $args{to}, type => $args{type} || 'chat', body => $args{body});
}
sub SendMessage { MessageSend(@_); }

sub RosterRemove {
    my (%args) = @_;
    $Con->RosterRemove( jid => $args{jid} );
#    $conlist->remove($args{jid});
}

sub SendPresence {
    my (%args) = @_;

    my $subscr = Net::Jabber::Presence->new();
    $subscr->SetPresence(%args);
    $Con->Send($subscr);
    main::pd($subscr);
}

sub main::reloadmods {
    eval `cat config.pl` || main::pd("ERROR cat config.pl :  $@");
}

sub main::IPCreply {
    $shareipc->store("A: " . join(' ',@_[0..$#_]));
}

sub main::sendNewMsg {
    my ($body, $other) = @_;
    $modules->got_msg( type => $other->{type} || 'intern',
		       body => $body || $other->{body},
		       from => $other->{from} || 'IPC',
		       jid  => 'IPC',
		       resource => $other->{resource} || 'IPC',
		       tag      => $other->{tag} || 'IPC',
		       other    => $other
		       );
}
sub main::AddContact { my (%args) = @_;
		       main::sendNewMsg('AddContact',
					{ body => 'AddContact', %args }); }
sub main::RemContact { my (%args) = @_;
		       main::sendNewMsg('RemContact',
					{ body => 'RemContact', %args }); }
sub main::IsInList { return defined $main::flags{$_[0]}; }
sub main::saveall { $modules->saveall($savefile); }
sub main::loadall { $modules->loadall($savefile); }
sub main::gethelp {
    my ($filename) = @_;
    open(FILE,"help/$filename") || return -1;
    my $rc;
    while (<FILE>) { $_ =~ s/%B/\\002/g; $rc .= $_; }
    close(FILE);
    return $rc;
}
sub main::privmsg { main::sendNewMsg("privmsg " . $_[0], { body => $_[0] }); }
sub main::getVcard {
#  my $iq = new Net::Jabber::IQ;
  my (%vars) = @_;
#  $Con->Send(qq~<iq id="1002" to="$vars{to}" type="get"><vCard xmlns="vcard-temp"/></iq>~);
  $Con->Send(qq~<iq id='A23' to='jarvatharpo\@jabber.org' type='get'><vCard prodid='-//HandGen//NONSGML vGen v1.0//EN' version='2.0' xmlns='vcard-temp'/></iq>~);
#	     <iq
#	       type="get"
#	       to="$vars{to}"
#	       id="101">
#	       <vCard  prodid='-//HandGen//NONSGML vGen v1.0//EN' version='2.0' xmlns="vcard-temp"/>
#	     </iq>~);
}





