#-*-cperl-*-
package modules::IRC::useridents;


sub new { bless { _users => undef }; }

sub adduser {
  my ($pkg, %vars) = @_;
  my $p = main::sendNewMsg("getpass", { jid => $vars{jid} });
  if(!($p)) { return -1; }
  if($vars{password} ne $p) { return 0; }
  $pkg->{_users}->{$vars{nick}} = $vars{jid};
  return 1;
}

sub getjid {
  my ($pkg, $hostmask) = @_;
  return "" unless defined $pkg->{_users}->{$hostmask};
  return $pkg->{_users}->{$hostmask};
}



1;
