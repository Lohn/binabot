#-*-cperl-*-
package modules::IRC::admin;

use vars '@ISA';
@ISA = ("module");


sub adduser {
  my ($pkg,%args) = @_;

  my @a = $pkg->getargs($args);
  if(!defined $a[0]) {
    $args{other}->{conn}->privmsg($args{other}->{event}->nick(),
				  "Usage: adduser <jid>");
    return;
  }
  main::AddContact(jid => $a[0]);
  $args{other}->{conn}->privmsg($args{other}->{event}->nick(),
				"$a[0] added.");
}

sub saveall {
  my ($pkg, %args) = @_;
  main::saveall();
  $args{other}->{conn}->privmsg($args{other}->{event}->nick(),
				"Saved.");
}
  
sub reloadall {
  my ($pkg, %args) = @_;
  main::reload();
  $args{other}->{conn}->privmsg($args{other}->{event}->nick(),
                                "Reloaded.");
  main::loadall();
}

sub ownerhelp {
  my ($pkg, %args) = @_;

  if(!open(FILE,"help/IRCadminhelp.txt")) {
    $args{other}->{conn}->privmsg($args{other}->{event}->nick(),
				  "Cannot open file help/IRCadminhelp.txt " .
				  $!);
    return;
  }
  while(<FILE>) {
    $_ =~ s/%B/\002/g;
    $args{other}->{conn}->privmsg($args{other}->{event}->nick(),$_ . " ");
  }
}
