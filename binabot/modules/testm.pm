package modules::testm;

use module;
use vars '@ISA';
@ISA = ("module");


sub gotsmth {
  main::pd("GOT SOMETHING !! YEAH !!");
}


main::pd("loaded..");

1;


