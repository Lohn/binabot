package modules::owner;
use strict;

use module;
use vars '@ISA';
@ISA = ("module");

sub pls {
    my ($pkg,%args) = @_;
    if($main::owner ne $args{jid}) { main::pd("$args{jid} is not my owner."); return 1; }
    my @args = split(/ /,$args{body});
    splice(@args,0,1);
#    my ($cpkg, $file, $line) = caller();
    my %words = ( reload => \&reloadall,
		  rosteradd => \&rosteradd,
		  rosterremove => \&rosterremove,
		  unsubscribe  => \&unsubscribe,
		  remove       => \&remove,
		  add          => \&add,
		  subscribe    => \&subscribe,
		  save         => \&saveall,
		  load         => \&loadall,
		  exit         => \&exit,
		  IRCconnect   => \&IRCconnect,
		  IRCquit      => \&IRCquit,
		  IRCjoin      => \&IRCjoin,
		  IRCpart      => \&IRCpart,
		  setflags     => \&setflags,
		  Dumpflags    => \&Dumpflags,
		  getvcard     => \&getvcard,
		  setrealname  => \&setrealname,
		  );
    $words{$args[0]}->($pkg,%args) if defined $words{$args[0]};
  main::pd("jojojo hahahaha");
}

sub setrealname {
  my ($pkg,%vars) = @_;
  my @arg = split(/ /,$vars{body});
  if(!$arg[3]) {
    main::SendMessage(to => $vars{jid},
		      body => "usage: pls setrealname <jid> <name>");
    return 0;
  }
  main::sendNewMsg("setrealname " . join(' ',@arg[2..$#arg]),{});
  main::SendMessage(to => $vars{jid},
		    body => "Changed Realname of $arg[2].");
}

sub getvcard {
  my ($pkg,%vars) = @_;
  my @arg = split(/ /,$vars{body});
  main::getVcard(to => $arg[2]);
#  main::SendIQ(to   => 'tehkahless@jabber.org',
#	       type => 'get',
#	       query => 'vcard');
}

sub Dumpflags {
  main::pd(\%main::flags);
}


sub reloadall {
    my ($pkg,%args) = @_;

    main::pd("Reload... ");
    main::reload();
    main::MessageSend(to => $args{from}, body => "Reloaded.");
}

sub add {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
  main::pd("Testing if you entered enough params ", %args);
    if(!$arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $args{body} <jid>" ); return 1; }
    if(main::IsInList($arg[2])) {
      main::MessageSend( to => $args{from}, body => "$arg[2] allready in roster");
    } else {
	$pkg->rosteradd(%args);
	$pkg->subscribe(%args);
    }
}

sub remove {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
  main::pd("Testing if you entered enough params ", %args);
    if(!$arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $args{body} <jid>" ); return 1; }
    if(main::IsInList($arg[2])) {
	$pkg->unsubscribe(%args);
	$pkg->rosterremove(%args);
	main::sendNewMsg("updatecontactfile",{ });
    } else {
      main::MessageSend( to => $args{from}, body => "$arg[2] is not in my roster!");
    }
}


sub rosteradd {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
    main::pd("Testing if you entered enough params ", %args);
    if(!$arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $args{body} <jid>" ); return 1; }
    if(main::IsInList($arg[2])) {
      main::MessageSend( to => $args{from}, body => "$arg[2] allready in roster");
    } else {
      main::RosterAdd( jid => $arg[2], name => $arg[2] );
	$pkg->addcontact( body => $args{body} );
      main::MessageSend( to => $args{from}, body => "$arg[2] added." );
    }
}

sub addcontact {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
  main::pd("Calling AddContact with $arg[2]");
  main::AddContact(jid => $arg[2]);
}

sub subscribe {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
    if(!defined $arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $arg[0] $arg[1] <jid>"); return 1;}
    main::SendPresence(to => $arg[2],type => 'subscribe');
    main::MessageSend( to => $args{from}, body => "Send subscribe to $arg[2].");
}

sub unsubscribe {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
    if(!$arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $args{body} <jid>"); return 1;}
    main::SendPresence(to => $arg[2],type => 'unsubscribe');
  main::MessageSend(to => $args{from}, body => "Sent unsubscribe to $arg[2]");
}



sub rosterremove {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
  main::pd("Testing if you entered enough params ", %args);
    if(!$arg[2]) { main::MessageSend( to => $args{from}, body => "Usage: $args{body} <jid>"); return 1;}
    if(main::IsInList($arg[2])) {
      main::RosterRemove(jid => $arg[2]);
	main::RemContact(jid => $arg[2]);
      main::MessageSend(to => $args{from}, body => "$arg[2] removed from roster.");
    } else {
      main::MessageSend(to => $args{from}, body => "$arg[2] not in my roster");
    }
}

sub IRCconnect {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  if(!(defined $arg[2])) {
    main::MessageSend(to => $args{from}, body => "usage: $arg[0] $arg[1] <IRCserver> [<nick>]");
    return;
  }
  main::pd("Calling IRCconnect...");
  my $tmp = main::sendNewMsg("IRCconnect",
			     { server => $arg[2],
			       nick   => $arg[3] || $main::stdIRCnick
			     }
			    );
  main::pd("Done... (rc: $tmp)");
}

sub IRCjoin {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  if(!(defined $arg[2])) {
    main::MessageSend(to => $args{from}, body => "usage: $arg[0] $arg[1] <channel>");
    return;
  }
  my $tmp = main::sendNewMsg("IRCjoin",
			     { channel => $arg[2]
			     }
			    );
  main::pd("Done... (rc: $tmp)");
}

sub IRCpart {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  if(!(defined $arg[2])) {
    main::MessageSend(to => $args{from}, body => "usage: $arg[0] $arg[1] <chann\el>");
    return;
  }
  my $tmp = main::sendNewMsg("IRCpart",
                             { channel => $arg[2]
                             }
                            );
  main::pd("Done... (rc: $tmp)");
}

sub setflags {
    my ($pkg,%args) = @_;
    my @arg = split(/ /,$args{body});
    if(!(defined $arg[3])) {
      main::MessageSend(to => $args{from}, body => "usage: $arg[0] $arg[1] <jid> <flags>");
	return;
    }
  my $tmp = main::sendNewMsg("setflags",
                             { jid   => $arg[2],
			       flags => $arg[3]
			       }
			     );
  main::MessageSend(to => $args{from}, body => "Flags of $arg[2] changed.");
  main::pd("Done... (rc: $tmp)", \%main::flags);
}


sub IRCquit {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  my $tmp = main::sendNewMsg("IRCquit",
                             { server => $arg[2]
                             }
                            );
  main::pd("Done... (rc: $tmp)");
}

sub exit {
  main::Exit();
}

sub saveall {
  main::saveall();
}

sub loadall {
  main::loadall();
}

main::pd("loaded ......... aaaaaaa");

1;
