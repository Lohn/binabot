#-*-cperl-*-
package module;

sub new { my $class = shift; bless { }, ref($class) || $class; }

sub save { my ($pkg,$writer) = @_; $writer->emptyTag("empty"); return -1; }
sub load { my ($pkg,$data) = @_; return -1; }
sub init { return -1; }
sub reload { my ($pkg) = @_; }
sub afterreload { }
sub exiting { }
sub getargs { my ($pkg,$string) = @_; my @rc = split(/ /,$string); return @rc[1..$#rc]; }

1;



