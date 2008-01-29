#-*-cperl-*-
package modules::IRC::channels;


sub new { bless { _channels => { } }; }

sub addchannel {
  my ($pkg,$name) = @_;
  return -1 if defined $pkg->{_channels}->{$name};
  $pkg->{_channels}->{$name} = { autojoin => 1,
			       };
  return 1;
}

sub remchannel {
  my ($pkg,$name) = @_;
  return -1 unless defined $pkg->{_channels}->{$name};
  delete $pkg->{_channels}->{$name};
  return 1;
}

sub getchannels {
  my ($pkg) = @_;
  my @rc;
  foreach my $k (keys %{$pkg->{_channels}}) {
    push(@rc,"$k");
  }
  return @rc;
}

sub save {
  my ($pkg, $writer) = @_;
  foreach my $key (keys %{$pkg->{_channels}}) {
    $writer->emptyTag('channel',
		      name     => $key,
		      autojoin => $pkg->{_channels}->{$key}->{autojoin}
		     );
  }
}

sub autojoin {
  my ($pkg) = @_;
  my @rc;
  foreach my $c (keys %{$pkg->{_channels}}) {
    if($pkg->{_channels}->{$c}->{autojoin}) {
      push(@rc,$c);
    }
  }
  return @rc;
}

1;
