#-*-cperl-*-
package modules::IRC::jpbIRC;

use vars '@ISA';
@ISA = ("module");

use Net::IRC;
use modules::IRC::useridents;
use modules::IRC::channels;

sub new {
  $main::users = modules::IRC::useridents->new();
  bless {
	 _connections => undef,
	 _channels    => undef,
	 _irc         => undef,
	 _curnet      => undef,
	 _users       => $main::users
	};
}

sub save {
  my ($pkg,$writer) = @_;
  foreach my $conn (keys %{$pkg->{_connections}}) {
    $writer->startTag("server",
		      "host"   => $conn,
		      "port"   => $pkg->{_connections}->{$conn}->port,
		      "nick"   => $pkg->{_connections}->{$conn}->nick
		     );
    $pkg->{_channels}->{$conn}->save($writer);
    $writer->endTag("server");
  }
}

sub load {
  my ($pkg, $data) = @_;
  main::pd("Im load ... ", $data);
  my $i = 1;
  while ($i < $#$data) {
    if($$data[$i] eq 'server') {
      my $server = $$data[$i+1];
      my %infos = %{$$server[0]};
      my $j = 1;
      if(!defined $pkg->{_connections}->{$infos{host}}) {
	main::pd("Server: $infos{host} as $infos{nick}");
	  my $tmp = main::sendNewMsg("IRCconnect",
				     { server => $infos{host},
				   nick   => $infos{nick} || $main::stdIRCnick,
				   port   => $infos{port}
				   }
				     );
      }
      elsif(defined $pkg->{_channels}->{$other{server}}) {
	  $i += 2; next;
      }
      else {
	  $pkg->{_channels}->{$other{server}} = modules::IRC::channels->new();
      }
      while ($j < $#$server) {
	  if($$server[$j] eq 'channel') {
	      my %chaninfo = %{$$server[$j+1]->[0]};
	    main::pd("    Channel: $chaninfo{name}");
	      $pkg->{_channels}->{$infos{host}}->addchannel($chaninfo{name});
	}
	$j += 2;
      }
      $i += 2;
    }
  }
}

sub identify {
  my ($pkg, %vars) = @_;
  my @args = split(/ /, $vars{body});
  my $rc;
  if(($rc = $pkg->{_users}->adduser(jid => $args[1], password => $args[2],
			     nick => $vars{other}->{event}->from))>0) {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->nick,
				   "Successfully identified");
  } elsif($rc == 0) {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->nick,
				   "Wrong jid/password");
  } elsif($rc < 0) {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->nick,
				   "You have no password set.");
  }
}

sub reload { my ($pkg) = @_;
	     delete $INC{'modules/IRC/useridents.pm'};
	     my $rc = { connections => $pkg->{_connections},
			irc         => $pkg->{_irc},
			curnet      => $pkg->{_curnet}
		      };
	     return $rc;
	   }

sub afterreload { my ($pkg, $tmp) = @_;
		  $pkg->{_connections} = $tmp->{connections};
		  $pkg->{_irc}         = $tmp->{irc};
		  $pkg->{_curnet}      = $tmp->{curnet};
		}

sub init { my $pkg = shift;
#	   my $irc = new Net::IRC;
#	  $irc->add_global_handler(376,\&on_connect); return;# unless $main::IRCbot;
	   $pkg->{_irc} = new Net::IRC;
	   $main::ircBot = $pkg->{_irc};
       }

sub join {
  my ($pkg, %vars) = @_;

  my $net = $vars{other}->{net} || $pkg->{_curnet};
  main::pd("join .. ", $pkg);
  return -2 unless $net;
  return -1 unless defined $pkg->{_connections}->{$net};
  $pkg->{_connections}->{$net}->join($vars{other}->{'channel'});
  $pkg->{_channels}->{$net}->addchannel($vars{other}->{'channel'});
}

sub part {
  my ($pkg, %vars) = @_;

  return -2 unless $pkg->{_curnet};
  $pkg->{_connections}->{$pkg->{_curnet}}->part($vars{other}->{channel});
  $pkg->{_channels}->{$pkg->{_curnet}}->remchannel($vars{other}->{'channel'});
}

sub exiting {
  my ($pkg) = @_;
  foreach my $key (keys %{$pkg->{_connections}}) {
    $pkg->{_connections}->{$key}->quit("Jabber Perl Bot V$main::VERSION quits. http://jpb.sourceforge.net (C) Copyright by Kahless 2001");
  }
}

sub quit {
  my ($pkg, %vars) = @_;
  my $server = $vars{other}->{server} || $pkg->{_curnet};
  return -2 unless defined $server;
  return -1 unless defined $pkg->{_connections}->{$server};
  $pkg->{_connections}->{$server}->quit("Jabber Perl Bot V$main::VERSION ended. http://jpb.sourceforge.net (C) Copyright by Kahless 2001");
  delete $pkg->{_connections}->{$server};
  if($server eq $pkg->{_curnet}) {
    if(keys(%{$pkg->{_connections}}) == 0) { $pkg->{_curnet} = undef; }
    else {
      my @k = keys %{$pkg->{_connections}};
      $pkg->{_curnet} = $k[0];
    }
  }
  delete $pkg->{_channels}->{$server};
  return 1;
}

sub on_connect {
  my $pkg = shift;
  main::pd("on_connect: ", $pkg->server);
  main::sendNewMsg("on_connect",
		   { type  => 'IRC',
		     tag   => 'connect',
		     conn  => $pkg
		   }
		  );
}

sub on_public {
  my ($pkg, $event) = @_;
  my @args = $event->args;
  main::pd("on_public - \$event->args :  ", \@args, " ($#args)");
  main::sendNewMsg($args[0],
		   { type  => 'IRC', 
		     tag   => 'public', 
		     event => $event,
		     body  => $args[0],
		     conn  => $pkg,
		     from  => $main::users->getjid($event->from)
		   }
		  );
}

sub on_msg {
  my ($pkg, $event) = @_;
  my @args = $event->args;
  main::pd("on_msg - event->args :  ", $event->args, " ($#args)");
  main::sendNewMsg($args[0],
		   { type  => 'IRC',
		     tag   => 'msg',
		     event => $event,
		     body  => $args[0],
		     conn  => $pkg,
		     from  => $main::users->getjid($event->from)
		   }
		  );
}

sub on_cdcc {
    my ($pkg, $event) = @_;
    my @args = $event->args;
  main::pd("on_cdcc", $event, " -------------------\n", \@args);
  main::sendNewMsg($args[0],
		   { type   => 'IRC',
		     tag    => 'cdcc',
		     event  => $event,
		     body   => $args[0],
		     conn   => $pkg,
		     from   => $main::users->getjid($event->from)
		     }
		   );
}

sub IRCconnect {
  my ($pkg, %vars) = @_;
  
  my %other = %{$vars{other}};
  if(defined $pkg->{_connections}->{$other{server}}) { return -1; }
  $pkg->{_connections}->{$other{server}} = 
    $pkg->{_irc}->newconn(Nick      => $other{nick},
			  Server    => $other{server},
			  Port      => $other{port} || 6667,
			  LocalAddr => $main::localaddr
			 );
  $pkg->{_connections}->{$other{server}}->add_global_handler(376,\&on_connect);
  $pkg->{_connections}->{$other{server}}->add_global_handler('public',\&on_public);
  $pkg->{_connections}->{$other{server}}->add_global_handler('msg',\&on_msg);
  $pkg->{_connections}->{$other{server}}->add_global_handler('cdcc',\&on_cdcc);
  $pkg->{_curnet} = $other{server};
  $pkg->{_channels}->{$other{server}} = modules::IRC::channels->new();
  main::pd("Connecting to $other{server} as $other{nick}");
}

sub got_connected {
  my ($pkg, %vars) = @_;
  main::pd("got_connected");
  foreach my $chan ($pkg->{_channels}->{$vars{other}->{conn}->server}->autojoin()) {
    $vars{other}->{conn}->join($chan);
    main::pd("joining $chan");
  }
}

sub dcc_get {
    my ($pkg, %vars) = @_;

    $pkg->{_irc}->addconn($vars{other}->{args});
  main::pd("dcc_get...",$vars{other});
}

sub getconnections {
  my ($pkg, %vars) = @_;

  my @rc;
  foreach my $server (keys %{$pkg->{_connections}}) {
    push(@rc,$server);
  }
  return \@rc;
}

sub getconnectionswithchans {
  my ($pkg, %vars) = @_;

  my @rc;
  foreach my $server (keys %{$pkg->{_connections}}) {
    my @chans = $pkg->{_channels}->{$server}->getchannels();
    push(@rc,$server . "\t" . join("\t",@chans));
  }
  return join("\n",@rc);
}


sub privmsg {
  my ($pkg, %vars) = @_;

  my (@args) = split(/ /,$vars{body});
  main::pd("Sending to $args[1] (channel: $args[2]): " . join(' ',@args[3..$#args]));
  if(!defined $pkg->{_connections}->{$args[1]} ||
     !defined $args[2] || !defined $args[3]) { return 0; }
  $pkg->{_connections}->{$args[1]}->privmsg($args[2],join(' ',@args[3..$#args]));
  return 1;
}

1;
