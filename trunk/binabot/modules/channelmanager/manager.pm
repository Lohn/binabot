package modules::channelmanager::manager;

use module;
use vars '@ISA';
@ISA = ("module");

sub new { bless { _channellist => undef }; }



package channel;

sub new {
    my ($pkg, %args) = @_;

    bless {
	_name     => $args{name},
	_flags    => $args{flags} || '',
	_protocol => $args{protocoll} || 'jabberconference',
    }
}

1;
