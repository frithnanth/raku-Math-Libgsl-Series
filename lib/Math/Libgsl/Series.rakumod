unit class Math::Libgsl::Series:ver<0.0.1>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Series;

has gsl_sum_levin_u_workspace       $.w;
has gsl_sum_levin_utrunc_workspace  $.wt;
has Bool                            $.truncation;
has UInt                            $.size;

# Workspace allocation
multi method new(UInt:D() $size!,  Bool  $truncation? = False) { self.bless(:$size, :$truncation) }
multi method new(UInt:D() :$size!, Bool :$truncation? = False) { self.bless(:$size, :$truncation) }
submethod BUILD(UInt:D :$!size, Bool :$!truncation) {
  if $!truncation {
    $!wt = gsl_sum_levin_utrunc_alloc($!size);
  } else {
    $!w  = gsl_sum_levin_u_alloc($!size);
  }
}

submethod DESTROY {
  if $!truncation {
    gsl_sum_levin_utrunc_free($!wt);
  } else {
    gsl_sum_levin_u_free($!w);
  }
}

method levin-accel(*@array where *.all > 0 --> List){
  my CArray[num64] $carray .= new: @array».Num;
  my num64 ($sum-accel, $abserr);
  my int32 $ret;
  my $terms-used;
  if $!truncation {
    $ret = gsl_sum_levin_utrunc_accel($carray, $!size, $!wt, $sum-accel, $abserr);
    $terms-used = $!wt.terms_used;
  } else {
    $ret = gsl_sum_levin_u_accel($carray, $!size, $!w, $sum-accel, $abserr);
    $terms-used = $!w.terms_used;
  }
  fail X::Libgsl.new: errno => $ret, error => "Can't compute series" if $ret ≠ GSL_SUCCESS;
  return $sum-accel, $abserr, $terms-used;
}

=begin pod

=head1 NAME

Math::Libgsl::Series - An interface to libgsl, the Gnu Scientific Library - Series Acceleration

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::Libgsl::Series;

constant \N = 20;
my Math::Libgsl::Series $s .= new: N;
my @array := Array[Num].new;
(^N).map: -> $n { my $np1 = $n + 1e0; @array[$n] = 1e0 / ($np1 * $np1) }
my ($sum, $err) = $s.levin-accel: @array;
say "The series' sum is $sum, with an estimated error $err";

=end code

=head1 DESCRIPTION

Math::Libgsl::Series is an interface to the Series Acceleration functions of libgsl, the Gnu Scientific Library.

=head3 new(UInt:D() $size!,  Bool  $truncation? = False)
=head3 new(UInt:D() :$size!, Bool :$truncation? = False)

The constructor accepts one or optionally two simple or named arguments: the mandatory series size and the optional
error estimation type.
This last argoment may have two values: propagation of rounding error or truncation error in the estrapolation.
If the B<Bool :$truncation> parameter is B<True> then the error is estimated by means of the truncation error in
the estrapolation.
If the B<Bool :$truncation> parameter is B<False> then the error is estimated by means of the propagation of rounding
errors.

=head3 levin-accel(*@array where *.all > 0 --> List)

This method computes the extrapolated limit of the series using a Levin u-transform.
It returns a B<List>: the extrapolated B<$sum>, the estimated B<$error>, and the number of B<$terms-used> during the
computation.

=head1 C Library Documentation

For more details on libgsl see L<https://www.gnu.org/software/gsl/>.
The excellent C Library manual is available here L<https://www.gnu.org/software/gsl/doc/html/index.html>, or here L<https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf> in PDF format.

=head1 Prerequisites

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux and Ubuntu 20.04+

=begin code
sudo apt install libgsl23 libgsl-dev libgslcblas0
=end code

That command will install libgslcblas0 as well, since it's used by the GSL.

=head2 Ubuntu 18.04

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04.
I solved the issue installing the Debian Buster version of those three libraries:

=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb>

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::Libgsl::Series
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
