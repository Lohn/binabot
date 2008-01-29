#-*-cperl-*-
package modules::IPCadmin::irc;

use strict;
use vars '@ISA';
@ISA = ("module");

sub ircstatus {
  my $server = main::sendNewMsg('getconnectionswithchans', { });
  main::IPCreply($server);
}

sub privmsg {
  my ($pkg, %args) = @_;

  my (@cmd) = split(/ /, $args{body});
  if(!defined $cmd[1]) { main::IPCreply("Not enaugh parameter."); return 0; }
  if(main::privmsg(join(' ', @cmd[1..$#cmd])) == 0) {
    main::IPCreply("Unknown error.");
    return;
  }
  main::IPCreply("Sent.");
  return 1;
}

sub ircconnect {
  my ($pkg, %args) = @_;

  my (@cmd) = split(/ /, $args{body});
  if(!defined $cmd[1]) { main::IPCreply("Not enaugh parameter."); return 0; }
  main::pd("Calling IRCconnect...");
  main::sendNewMsg("IRCconnect",
		   { server => $cmd[1],
		     nick   => $cmd[2] || $main::stdIRCnick
		   }
		  );
  main::IPCreply("The Bot should connect any second now.");
}

sub ircjoin {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  if(!(defined $arg[2])) {
    main::IPCreply("usage: ircjoin <channel> <ircnet>");
    return;
  }
  my $tmp = main::sendNewMsg("IRCjoin",
                             { channel => $arg[1],
			       net     => $arg[2],
                             }
                            );
  main::IPCreply("Joined $arg[1] ($args{body}) ... (rc: $tmp)");
}

sub ircpart {
  my ($pkg,%args) = @_;
  my @arg = split(/ /,$args{body});
  if(!(defined $arg[2])) {
    main::IPCreply("usage: ircpart <channel> <ircnet>");
    return;
  }
  my $tmp = main::sendNewMsg("IRCpart",
                             { channel => $arg[1],
                               net     => $arg[2],
                             }
                            );
  main::IPCreply("Left $arg[1] ... (rc: $tmp)");
}



