#!/usr/bin/perl

use strict;
use warnings;
use feature qw( say );

use Test::More tests => 8;
use Test::Fatal;

use Scalar::Util qw( refaddr );

my $arr = [];
my $arraddr = sprintf "0x%x", refaddr $arr;

{
   use stringification;

   open my $fh, ">", \my $str;

   $str = ""; seek( $fh, 0, 0 );
   ok( !exception { print $fh "My", $arr, "here\n" }, 'print in use stringification' );

   is( $str, "MyARRAY($arraddr)here\n", 'print result' );

   $str = ""; seek( $fh, 0, 0 );
   ok( !exception { say $fh "My", $arr, "here" }, 'say in use stringification' );

   is( $str, "MyARRAY($arraddr)here\n", 'say result' );
}

{
   no stringification;

   open my $fh, ">", \my $str;

   ok( exception { print $fh "My", $arr, "here\n" }, 'print in no stringification' );

   ok( exception { say $fh "My", $arr, "here\n" }, 'say in no stringification' );

   $str = ""; seek( $fh, 0, 0 );
   ok( !exception { print $fh "Hello world\n" }, 'print plain strings OK in no stringification' );
   is( $str, "Hello world\n", 'print result' );
}
