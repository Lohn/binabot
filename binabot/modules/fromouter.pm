package modules::fromouter;

use module;
use vars '@ISA';
@ISA = ("module");

sub getstatus {
  main::IPCreply("Don't know yet.. sorry");
  main::pd("getstatus ....");
}

sub sendmessage {
    my ($pkg, %args) = @_;
    $args{body} =~ s/<br>/\n/gms;
    my (@words) = split(/ /,$args{body});

    if($words[1] ne '' && $words[2] ne '') {
      main::SendMessage(to => $words[1],body => join(' ', @words[2..$#words]));
    }
  main::IPCreply("sent message to $words[1].");# :  " . join(' ', @words[2..$#words]));
}

1;
