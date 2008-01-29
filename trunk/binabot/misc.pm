package misc;

sub new { bless { }; }



sub get_time {
    my ($pkg,%args) = @_;

    main::SendMessage( to   => $args{from},
		       body => "Well.. sorry.. I don't know the time :("
		       );
}

sub get_help {
    my ($pkg,%args) = @_;

    my $msg = qq~
This is the help ..
well .. nothing here now .. but maybe there will be something sometime ?
for now ... cu ;)
tehkahless\@jabber.org
    ~;
 main::SendMessage( to => $args{from}, body => $msg );

}

sub got_invitation {
    my ($pkg,%args) = @_;

    if($args{other}->{jid} ne "") {
      main::pd("Got invitation for $args{other}->{jid}");
      main::SendPresence(to => $args{other}->{jid} . "/Lore",
			 status => "online");
    }
    else { main::pd("HILFE !!! $args{other}->{jid}"); }
}

sub got_groupchat_time {
    my ($pkg,%args) = @_;

  main::SendMessage(to => $args{from}, type => 'groupchat', body => "JOJO");
}


1;
