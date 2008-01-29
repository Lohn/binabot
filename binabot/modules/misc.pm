package modules::misc;

use module;
use vars '@ISA';
@ISA = ("module");

sub save {
    my ($pkg,$writer) = @_;
    $writer->emptyTag("blah",yo => 'hehe');
}


sub get_time {
    my ($pkg,%args) = @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
	localtime(time());
    $min += 1;
    $year += 1900;
    main::SendMessage( to   => $args{from},
		       body => "it's $hour:$min (CET)"
		       );
}

sub get_help {
    my ($pkg,%args) = @_;

    my $msg = qq~
Esta é  a ajuda.
Nada de novo ainda.
Sugestões para josemarlohn\@gmail.com
    ~;
 main::SendMessage( to => $args{from}, body => $msg );

}

sub got_invitation {
    my ($pkg,%args) = @_;

    if($args{other}->{jid} ne "") {
      main::pd("Got invitation for $args{other}->{jid}");
      main::SendPresence(to => $args{other}->{jid} . "/$main::username",
			 status => "online");
    }
    else { main::pd("HELP !!! $args{other}->{jid}"); }
}

sub got_groupchat_time {
    my ($pkg,%args) = @_;

  main::SendMessage(to => $args{from}, type => 'groupchat', body => "JOJO");
}

main::pd("................\n\n\n");
1;
