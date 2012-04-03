#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2011-2012 -- leonerd@leonerd.org.uk

package stringification;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01_003';

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION );

=head1 NAME

C<stringification> - allow or forbid implicitly converting references into
strings

=head1 SYNOPSIS
 
 no stringification;

 my $array = [ 1, 2, 3 ];

 print "My array is $array\n";  # dies

=head1 DESCRIPTION

Normally in Perl, a reference may be implicitly converted into a string,
usually of a form like C<HASH(0x1234567)>.

This module provides a lexically-scoped pragma which alters the behaviour of
the following operations:

 "$ref"             # stringify
 $ref . "foo"       # concat
 lc $ref
 lcfirst $ref
 uc $ref
 ucfirst $ref
 quotemeta $ref

When disabled by C<no stringification>, all of these operations will fail with
an exception when invoked on a non-object reference.

 $ perl -E 'no stringification; my $arr = []; say "Array is $arr"'
 Attempted to concat a reference at -e line 1.

The effects of this module are lexically scoped; to re-enable stringification
of references during a lexical scope, C<use stringification> again.

=cut

sub unimport
{
   # Inform older perls that %^H needs rescoping
   $^H |= 0x20000;

   # This is 'no stringification'; i.e. enable
   $^H{stringification} = 1;
}

sub import
{
   # Inform older perls that %^H needs rescoping
   $^H |= 0x20000;

   # This is 'use stringification'; i.e. disable
   delete $^H{stringification};
}

# Keep perl happy; keep Britain tidy
1;

__END__

=head1 TODO

=over 4

=item *

More testing, especially around interoperatbility with other op-hooking
modules.

=item *

Hook more ops; including

 print $ref
 say $ref
 join "", $ref
 split //, $ref
 $ref =~ m//
 $ref =~ s///;
 s//$ref/;
 substr( $ref, 0, 0 )
 substr( $str, 0, 0, $ref )
 substr( $str, 0, 0 ) = $ref

=item *

Consider whether to detect for objects that don't have overload magic, and
forbid these too.

=item *

A mode where string conversions just give warnings, rather than outright
failures.

 no stringification 'warn';

=back

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>
