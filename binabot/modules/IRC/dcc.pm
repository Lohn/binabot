#-*-cperl-*-
package modules::IRC::dcc;

use Net::IRC::DCC;
use vars '@ISA';
@ISA = ("module");

sub new { bless { _gets => undef }; }

sub GotAGet {
    my ($pkg,%args) = @_;
  main::pd("I'm in GotAGet...");
    my (@arg) = split(/ /, $args{body});
    my $fh = IO::File->new(">/tmp/$arg[1]");
    my $event = $args{other}->{event};
  main::pd("..." . ref($args{other}->{event}));
    my $argh = $args{other}->{conn}->new_get($event->nick,$arg[1],$arg[2],$arg[3],$arg[4],$fh);
#    $args{other}->{conn}->addconn($argh);
#  main::sendNewMsg('dccget',
#		   { args => [$args{other}->{conn},
#			      $args{other}->{event}->nick,
#			      $arg[2],
#			      $arg[3],
#			      $arg[4],
#			      $arg[1]
#			      ]
#			      }
#		   { args => $args{other}->{conn}->new_get(
#						    $args{other}->{event}
#							   )
#		     }
#		   );
}

sub DCC_closed {
    my ($pkg,$event) = @_;

  main::pd("DCC_closed... ", $pkg, "\n\n", $event);
}
