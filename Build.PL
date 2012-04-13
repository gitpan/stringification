use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
   module_name => 'stringification',
   requires => {
      'XSLoader' => 0,

      # I can't work out how to make this work on 5.8.9's lexical hint hash
      # "patches welcome" if anyone knows and cares...
      'perl'     => '5.10.0',
   },
   build_requires => {
      'Test::Fatal' => 0,
      'Test::More' => 0,
   },
   auto_configure_requires => 0, # Don't add M::B to configure_requires
   license => 'perl',
   create_makefile_pl => 'small',
   create_license => 1,
   create_readme  => 1,
);

$build->create_build_script;
