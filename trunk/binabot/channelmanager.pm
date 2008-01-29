
package channelmanager;
#use strict;
use Fcntl;
use MLDBM qw( DB_File Storable );

sub new { bless { _channels => undef }; }

sub addchannel {
    my $pkg = shift;
    my $name = shift;
    push(@{$pkg->{_channels}}, channel::new($name));
}

sub removechannel {
}

sub savechans {
    my $pkg = shift;
    local *DBM;
    my %hash;
    my $db = tie %hash, "MLDBM", "test.dbm", O_CREATE | O_RDWR, 0644 ||
	die "Could not tie to test.dbm: $!";
    my $fd = $db->fd;
    open DBM, "+<&=$fd" || die "Could not dup DBM for lock: $!";
    flock DBM, LOCK_EX;
    undef $db;
    $hash{channels} = $pkg;
    untie %hash;
    print "erm.. jo .. test ?\n";
}


package channel;

sub new {
    my $pkg = shift;
    my $name = shift;
    bless {
	_name    => $name,
	_members => undef,
	_subject => ""
	}; }

sub addmember {
    my $pkg = shift; my $name = shift;
    push(@{$pkg->{_members}}, $name);
}

sub removemember {
    my $pkg = shift; my $name = shift;
    my $i = 0;
    foreach my $now (@{$pkg->{_members}}) {
	if($now eq $name) {
	    splice(@{$pkg->{_members}}, $i, 1);
	    last;
	}
	$i++;
    }
    return $i;
}

sub getmembers { my $pkg = shift; return @{$pkg->{_members}}; }



1;

