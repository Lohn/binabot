package modules::userlist::contacts;
use strict;

sub new {
    my ($modul, %args) = @_;
    my $filename = $args{'filename'} || "jabbercontacts.txt";
    my $save = $args{'save'} || 0;
    if($save != 0) { initsave($filename); }
    initdebug($args{'debug'});
    bless {
	_list     => undef,
	_hash     => { },
        _save     => $save,
        _filename => $filename,
	_debug    => $args{'debug'}
	};
}

sub save {
    my ($pkg,$writer) = @_;

#    foreach my $c (@{$pkg->{_list}}) {
#	$c->save($writer);
#    }
  main::pd("save..");
    my %hash = %{$pkg->{_hash}};
    foreach my $c (keys %hash) {
      main::pd("calling hash{$c}->save");
	$hash{$c}->save($writer);
    }
}

sub load {
    my ($pkg,$data) = @_;

    my $i = 1;
    my %hash;
    while ($i < $#$data) {
	if($$data[$i] eq 'contact') {
	    my %infos = %{$$data[$i+1]->[0]};
	    my $groups;
	    if($infos{groups} eq '') { $groups = ([]); }
	    else { my @tmp = split(/\//,$infos{groups}); $groups = \@tmp; }
	    $hash{$infos{jid}} = contact->new(jid          => $infos{jid},
					      name         => $infos{name},
					      realname     => $infos{realname},
					      subscription => 
					      $infos{subscription},
					      ask          => $infos{ask},
					      groups       => $groups,
					      status       => $infos{status},
					      show         => $infos{show},
					      password     => $infos{password},
					      flags        => $infos{flags}
					      );
	}
	$i++;
    }
    $pkg->{_hash} = \%hash;
}

sub getroster {
    my ($pkg) = shift;
  main::pd("roster: ", $pkg->{_hash});
}

{
    my $debug = 0;

    sub pd {
	if($debug != 0) { print " ### contacts debug : $_[0] ###\n"; }
    }
    sub initdebug {
	$debug = $_[0] || 0;
    }
}

sub initsave {
    open(FILE,">$_[0]") || die "Cannot open file $_[0]: $!";
    close(FILE);
}

sub initroster {
  my ($pkg, %roster) = @_;

  my @list;
  pd("initroster ...");
  my %hash = %{$pkg->{_hash}};
  foreach my $k (keys %roster) {
    if(defined $hash{$k}) {
      main::pd("Roster: Allready in list: $k");
    } else {
      $hash{$k} = contact->new(jid          => $k,
			       name         => $roster{$k}->{name},
			       subscription => $roster{$k}->{subscription},
			       ask          => $roster{$k}->{ask},
			       groups       => $roster{$k}->{groups}
			      );
      main::pd("Roster: Adding: $k");
      $main::flags{$_[0]} = "";
    }
  }
  $pkg->{_hash} = \%hash;
}

sub add {
    my ($pkg,%args) = @_;
    if (!defined $args{jid} || $pkg->IsInList($args{jid})) { main::pd("Unknown error: $args{jid}"); return; }
  main::pd("Adding $args{jid} to list ", \%args);
#    push(@{$pkg->{_list}},contact->new(jid => $args{jid}, name => $args{name}));
    my $code = "\$pkg->{_hash}->{'$args{jid}'} = contact->new(jid => '$args{jid}', name => '$args{jid}')";
  main::pd("Code: $code");
  eval $code;
}

sub IsInList {
    my ($pkg, $who) = @_;

#    foreach my $c (@{$pkg->{_list}}) {
#	if($c->getjid() eq $who) { pd("i know $who !"); return 1; }
#    }
#    my %hash = %{$pkg->{_list}};
#    return defined $hash{$who};
#    pd("i don't know $who :(");
    return main::IsInList($who);
}

sub remove {
    my ($pkg, $who) = @_;

    my %hash = %{$pkg->{_hash}};
    if(!defined $hash{$who}) {
      main::pd("There is nobody called $who ?");
    } else {
	delete $hash{$who};
        delete $main::flags{$who};
        main::pd("Delete $who");
    }
    $pkg->{_hash} = \%hash;
}

sub setrealname {
  my ($pkg,$jid,$realname) = @_;

  main::pd("change realname of $jid to $realname");
  $pkg->{_hash}->{$jid}->setrealname($realname);
}

sub chpass {
  my ($pkg,$jid,$pass) = @_;
  $pkg->{_hash}->{$jid}->chpass($pass);
}

sub chstatus {
  my ($pkg, $who, $status, $show) = @_;
  
  main::pd("Trying to change status from $who to $show ($status)");
  my %hash = %{$pkg->{_hash}};
  
  if(defined $hash{$who}) {
    $hash{$who}->setstatus($status);
    $hash{$who}->setshow($show);
    main::pd("Changed status from $who to $show ($status)");
  }

#    foreach my $c (@{$pkg->{_list}}) {
#      main::pd("c",$c);
#	if($c->getjid() eq $who) {
#	    $c->setstatus($status);
#	    $c->setshow($show);
#	    pd("Changed status from $who to $show ($status)");
#	    last;
#	}
#    }
#    pd("back ..");
  $pkg->{_hash} = \%hash;
  $pkg->savestatus();
}

sub savestatus {
  my $pkg = shift;
  
  return unless $pkg->{_save};
  open(FILE,">$pkg->{_filename}");
#  foreach my $c (@{$pkg->{_list}}) {
#    print FILE $c->getjid() . "<#>" . $c->getshow() . "<#>" . $c->getstatus() . "<#>" . time() . "<#>\n";
#  }
  my %hash = %{$pkg->{_hash}};
  foreach my $c (keys %hash) {
    main::pd("Saving ", $c);
    print(FILE 
	  $hash{$c}->getjid()      . "<#>" .
	  $hash{$c}->getshow()     . "<#>" .
	  $hash{$c}->getstatus()   . "<#>" .
	  $hash{$c}->getrealname() . "<#>" .
	  time()                   . "<#>\n");
  }
  close(FILE);
}

sub getpass {
  my ($pkg, $jid) = @_;
  main::pd("hehe", $pkg->{_hash}->{$jid}->getpass());
  return $pkg->{_hash}->{$jid}->getpass();
}

package contact;


sub new {
  my ($module, %args) = @_;
  
  main::pd("Adding $args{jid}");
  $main::flags{$args{jid}} = $args{flags} || "";
  bless {
	 _jid          => $args{jid},
	 _realname     => $args{realname} || '',
	 _name         => $args{name},
	 _subscription => $args{subscription} || 'none',
	 _ask          => $args{ask} || '',
	 _groups       => $args{groups} || ([]),
	 _status       => $args{status} || "offline",
	 _show         => $args{show} || "offline",
	 _flags        => $args{flags} || "",
	 _password     => $args{password} || ""
	};
}

sub save {
    my ($pkg, $writer) = @_;
    my @groups = @{$pkg->{_groups}};
    my $groupstring = "";
    foreach my $s (@groups) { $groupstring .= $s . "/"; }
    $writer->emptyTag("contact",
		      jid          => $pkg->{_jid},
		      name         => $pkg->{_name},
		      realname     => $pkg->{_realname},
		      subscription => $pkg->{_subscription},
		      ask          => $pkg->{_ask},
		      groups       => $groupstring,
		      status       => $pkg->{_status},
		      show         => $pkg->{_show},
		      flags        => $main::flags{$pkg->{_jid}},
		      password     => $pkg->{_password}
		      );
}

sub addflags { my ($pkg,$jid,$flag) = @_; $main::flags{$jid} .= $flag;
	       $pkg->{_flags} .= $flag; }
sub remflag { my ($pkg,$flag) = @_; $main::flags{$pkg->{_jid}} =~ s/$flag//g;
	      $pkg->{_flags} =~ s/$flag//g; }
sub getjid { my $pkg = shift; return $pkg->{_jid}; }
sub setstatus { my $pkg = shift; return ($pkg->{_status} = shift); }
sub getstatus { my $pkg = shift; return $pkg->{_status}; }
sub setshow { my $pkg = shift; return ($pkg->{_show} = shift); }
sub getshow { my $pkg = shift; return $pkg->{_show}; }
sub chpass { my $pkg = shift; $pkg->{_password} = shift; }
sub getpass { my $pkg = shift; return $pkg->{_password}; }
sub setrealname { my $pkg = shift; $pkg->{_realname} = shift; }
sub getrealname { my $pkg = shift; return $pkg->{_realname}; }

1;











