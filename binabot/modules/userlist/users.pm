package modules::userlist::users;

use module;
use vars '@ISA';
use modules::userlist::contacts;
@ISA = ("module");

sub new {
    bless {
	_conlist => modules::userlist::contacts->new(
						  debug => $main::debug,
						  save  => $main::save,
						  filename => $main::filename
						     )
    };
}

sub save {
    my ($pkg, $writer) = @_;

    $pkg->{_conlist}->save($writer);
}

sub load {
    my ($pkg,$data) = @_;
    $pkg->{_conlist}->load($data);
}

sub reload {
    my ($pkg) = @_;
    delete $INC{'modules/userlist/contacts.pm'};
}

sub getroster {
    my ($pkg) = @_;
    $pkg->{_conlist}->getroster();
}

sub got_subscribe {
    my ($pkg,%args) = @_;

  main::pd("Got subscribe ..");
    if($pkg->{_conlist}->IsInList($args{from})) {
      main::pd("is in list .. so send a subscribed");
      main::SendPresence( to => $args{from}, type => 'subscribed' );
      main::SendMessage( to => $args{from}, body => "Hi $args{from} !\nI'm JabberBot, programmed by tehkahless\@jabber.org\n(please send bugs and ideas)");
    } else {
      main::pd("Nao esta na lista entao vamos incluir");
      main::AddContact( body => $args{from});
      main::SendPresence( to => $args{from}, type => 'subscribed' );
      main::SendMessage( to => $args{from}, body => "Hi $args{from} !\nI'm JabberBot, programmed by tehkahless\@jabber.org\n(please send bugs and ideas)");
#      main::SendMessage( to => $args{from}, body => "Sorry, but i only allow subscriptions from jid's i know. Please contact $main::owner . He may add you to my list.");
#      main::pd("is not in list ..");
    }
}

sub statuschanged {
    my ($pkg,%args) = @_;

    my $test = $pkg->{_conlist};
    $test->chstatus($args{from},$args{other}->{status} || $args{other}->{show},$args{other}->{show} || $args{other}->{status});
}

sub updatecontactfile {
    my ($pkg) = @_; $pkg->{_conlist}->savestatus();
}

sub initroster {
    my ($pkg,%args) = @_;

#  main::pd("Roster :  ", $args{other}->{roster});
    my $test = $pkg->{_conlist};
    $test->initroster(%{$args{other}->{roster}});
#  main::pd("Roster :  ", $args{other}->{roster});
}

sub chpass {
  my ($pkg,%args) = @_;
  my @args = split(/ /,$args{body});
  if(!(defined $args[1])) { main::MessageSend( to => $args{from},
					       body => 'usage: $args[0] <pass>'
					     );
			  }
  $pkg->{_conlist}->chpass($args{from},$args[1]);
  main::MessageSend(to => $args{from},
		    body => 'Password changed.');
}

sub getpass {
  my ($pkg, %args) = @_;

  my $rc = $pkg->{_conlist}->getpass($args{other}->{jid});
  main::pd("im getpass", $rc);
  return $rc;
}

sub AddContact {
    my ($pkg, %args) = @_;

    $pkg->{_conlist}->add(jid => $args{other}->{jid});
}

sub RemContact {
    my ($pkg, %args) = @_;

    $pkg->{_conlist}->remove($args{other}->{jid});
}

sub SetRealname {
  my ($pkg, %args) = @_;
  my $name = $args{body};
  $name =~ s/^(.*?) //;
  $pkg->{_conlist}->setrealname($args{jid},$name);
  main::SendMessage(to => $args{jid},
		    body => "Changed your Realname to $name");
  main::sendNewMsg("updatecontactfile",{ });
}

sub OwnerSetRealname {
  my ($pkg, %args) = @_;
  my $name = $args{body};
  $name =~ s/^(.*?) (.*?) //;
  my $jid = $2;
  $pkg->{_conlist}->setrealname($jid,$name);
  main::sendNewMsg("updatecontactfile",{ });
}

sub setflags {
  my ($pkg, %args) = @_;

  $main::flags{$args{other}->{jid}} = $args{other}->{flags};
  main::pd("im setflags..");
  return 1;
}

1;
