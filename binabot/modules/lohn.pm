package	modules::lohn;

use module;
use vars '@ISA';
@ISA = ("module");

sub external {
  my ($pkg, %args) = @_;
  print($args{body});
  system("/home/binabot/bot $args{from} $args{body}"); 
#system {'/bin/bash'} '-sh';
}

1;
