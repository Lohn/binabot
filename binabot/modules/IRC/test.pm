#-*-cperl-*-

package modules::IRC::test;

use vars '@ISA';
@ISA = ("module");


sub mytest {
    my ($pkg, %vars) = @_;

#    my %other = $vars{other};
    $vars{other}->{conn}->privmsg($vars{other}->{event}->to,"JAJA ES FUNKT !");
  main::pd("blah.." . $vars{other}->{conn}->server);
}

sub bindtest {
  my ($pkg, %vars) = @_;
  $vars{other}->{conn}->privmsg($vars{other}->{event}->to,"hmmjo .. bindtest");
}

sub whois {
  my ($pkg, %vars) = @_;
  my (@args) = split(/ /, $vars{body});
  if(!defined $args[1]) {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->to,
				  "usage: $args[0] <nick>");
    return 0;
  }
  if(defined $main::users{$args[1]}) {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->to,
				  "$args[1] is " .
				  $main::users{$args[1]});
  } else {
    $vars{other}->{conn}->privmsg($vars{other}->{event}->to,
                                  $vars{other}->{event}->nick . ", good " .
				  "question ...");
  }
  return 1;
}

sub msgtest {
    my ($pkg, %vars) = @_;

  main::pd("msgtest ... " . $vars{other}->{event}->nick);
    $vars{other}->{conn}->privmsg($vars{other}->{event}->nick,"JAJA ES FUNKT !");
}

sub fu {
    my ($pkg, %vars) = @_;

    $vars{other}->{conn}->privmsg($vars{other}->{event}->to,"\002SHUT UP\002 " . $vars{other}->{event}->nick . " !!! Or I will f\002u\002 !!");
}

1;
