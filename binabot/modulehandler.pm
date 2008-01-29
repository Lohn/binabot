#use Module::Reload;

package modulehandler;
use strict;
use XML::Writer;
use XML::Parser;
use IO;

sub new { bless { _modules => undef, _modulelist => { } }; }

sub modulesloaded {
    my ($pkg,$filename) = @_;
    $pkg->initall();
    $pkg->loadall($filename);
}

sub registermodule {
    my ($pkg,%args) = @_;

    my %modulelist = %{$pkg->{_modulelist}};
    if(!($args{name}) || !($args{type}) || !($args{method}) || 
       !($args{pattern})) {
	my ($package, $file, $line) = caller();
#	main::db("Warning @ modulehandler->registermodule(@_): may  - $package - $file - $line" . each %args;
    }

    my $tmp = undef;
    if(defined $modulelist{$args{name}}) {
	$tmp = $modulelist{$args{name}};
    } else {
	my $path = $args{name} . '.pm'; $path =~ s/::/\//g;
	require $path || main::pd("erm.. error ??? $!");
      main::pd("no match found - $path - $args{name}");
	$tmp = $args{name}->new();
	$modulelist{$args{name}} = $tmp;
    }

    my %tmp = ( #_pkg     => $tmp,
		_type    => (defined $args{type} ? $args{type} : 'chat' ),
		_method  => $args{method},
		_pattern => $args{pattern},
		_name    => $args{name},
		_tag     => $args{tag} || 'message',
		_other   => $args{other} || { },
	        _flags   => $args{flags}
		);
    push(@{$pkg->{_modules}},\%tmp);
    $pkg->{_modulelist} = \%modulelist;
  main::pd("done..");
}

sub got_msg {
  my ($pkg,%args) = @_;
  
  my %modulelist = %{$pkg->{_modulelist}};
  main::pd("Got msg ... $args{type}: $args{body}");
  my $rc;
  foreach my $m (@{$pkg->{_modules}}) {
    next unless $m->{_type} eq $args{type};
    if($args{tag} eq $m->{_tag} && $args{body} =~ /$m->{_pattern}/) {
      main::pd("Got msg, test flags of $args{from}");
      my $flags = $main::flags{$args{from}};
      my $neededflags = $m->{_flags};
      main::pd("$args{from} has flags: $flags (Needed: " . $neededflags . ")");
      $neededflags =~ s/[$flags]//g if $flags ne "";
      next unless $neededflags eq "";
      main::pd("\$modulelist{'$m->{_name}'}->" . $m->{_method} . "()");
      my $code = "\$rc = \$modulelist{'$m->{_name}'}->" . $m->{_method} . "(%args)";
      eval $code;# || warn @!; #main::pd("error eval $code: ", @!);
      warn $@ if $@;
    }
  }
  return $rc;
}

sub reloads {
    my ($pkg) = @_;

    $pkg->initreload();
    my @newpm;
  main::pd("reload ...");
    foreach my $key (keys(%{$pkg->{_modulelist}})) {
	my $realkey = $key . '.pm'; $realkey =~ s/::/\//g;
	delete $INC{$realkey};
    }
    delete $INC{'module.pm'};
    splice( @{ $pkg->{_modules}} );
    $pkg->{_modulelist} = { };
    $pkg->reloadmods();
    $pkg->afterreload();
}

sub bindm { main::bindm(@_); }
sub sbind { main::sbind(@_); }
sub ipcbind { main::ipcbind(@_); }

sub reloadmods {
  main::reloadmods();
}

sub exiting {
  my ($pkg) = @_;

  foreach my $key (keys %{$pkg->{_modulelist}}) {
    $pkg->{_modulelist}->{$key}->exiting();
  }
}

sub saveall {
    my ($pkg, $filename) = @_;

    my $out = IO::File->new(">$filename");
    my $writer = new XML::Writer(OUTPUT => $out, NEWLINES => 1);

    my %modules = %{$pkg->{_modulelist}};
    $writer->startTag("JabberBotsSaveFile");
    foreach my $key (keys %modules) {
	my $tag = $key; $tag =~ s/::/_/g;
	$writer->startTag($tag);
	$modules{$key}->save($writer);
	$writer->endTag($tag);
    }
    $writer->endTag("JabberBotsSaveFile");
    $writer->end();
    $out->close();
}

sub loadall {
    my ($pkg,$filename) = @_;
    open(FILE,"$filename") || return;
    close(FILE);
    my $pl = XML::Parser->new(Style => "Tree");
    my $tree = $pl->parsefile($filename);
    my $i = 1;
    my %modules = %{$pkg->{_modulelist}};
    $tree = $tree->[1];
    while($i < $#$tree) {
	my $mod = $$tree[$i];
	my $now = $$tree[$i+1];
	$mod =~ s/_/::/g;
	if(defined $modules{$mod}) {
          main::pd("Calling $mod->load(...)");
            $modules{$mod}->load($now);
	}
        $i+=2;
    }
}

sub initall {
    my ($pkg) = @_;

    my %modules = %{$pkg->{_modulelist}};
    foreach my $key (keys %modules) {
      main::pd("Calling $key->init()");
	$modules{$key}->init();
    }
}

sub initreload {
    my ($pkg) = @_;

    my %modules = %{$pkg->{_modulelist}};
    foreach my $key (keys %modules) {
        $pkg->{_tmp}->{$key} = $modules{$key}->reload();
    }
}

sub afterreload {
    my ($pkg) = @_;

    my %modules = %{$pkg->{_modulelist}};
    foreach my $key (keys %modules) {
	$modules{$key}->afterreload($pkg->{_tmp}->{$key});
    }
    delete $pkg->{_tmp};
}

1;
