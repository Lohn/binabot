package modules::groupchat;

use module;
use vars '@ISA';
@ISA = ("module");


sub part {
    my ($pkg,%args) = @_;

    main::SendPresence(to => $args{from} . "/$main::username", type => 'unavailable');
}

print "BLAH\n\n\n";


1;
