# Copyright (c) 2008 Mathieu Parent <math.parent@gmail.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Net::LDAP::Intermediate::SyncInfo;

use vars qw(@ISA $VERSION);
use Net::LDAP::Intermediate;

@ISA = qw(Net::LDAP::Intermediate);
$VERSION = "0.02";

use Net::LDAP::ASN qw(syncInfoValue);
use strict;

sub init {
  my($self) = @_;

  if (exists $self->{responseValue}) {
    $self->{asn} = $syncInfoValue->decode(delete $self->{responseValue});
  } else {
    $self->{asn} = {};
    $self->{asn}{newcookie} =
      delete $self->{newcookie} if exists $self->{newcookie};
    $self->{asn}{refreshDelete} =
      delete $self->{refreshDelete} if exists $self->{refreshDelete};
    $self->{asn}{refreshPresent} =
      delete $self->{refreshPresent} if exists $self->{refreshPresent};
    $self->{asn}{syncIdSet} =
      delete $self->{syncIdSet} if exists $self->{syncIdSet};
  }
  #$self->{asn}{refreshDelete}{refreshDone} defaults to TRUE
  if(defined($self->{asn}{refreshDelete})) {
    $self->{asn}{refreshDelete}{refreshDone} =
      defined($self->{asn}{refreshDelete}{refreshDone})
      ? $self->{asn}{refreshDelete}{refreshDone}
      : 1;
  }
  #$self->{asn}{refreshPresent}{refreshDone} defaults to TRUE
  if(defined($self->{asn}{refreshPresent})) {
    $self->{asn}{refreshPresent}{refreshDone} =
      defined($self->{asn}{refreshPresent}{refreshDone})
      ? $self->{asn}{refreshPresent}{refreshDone}
      : 1;
  }
  #$self->{asn}{syncIdSet}{refreshDeletes} defaults to FALSE
  if(defined($self->{asn}{syncIdSet})) {
    $self->{asn}{syncIdSet}{refreshDeletes} =
      defined($self->{asn}{syncIdSet}{refreshDeletes})
      ? $self->{asn}{syncIdSet}{refreshDeletes}
      : 0;
  }

  $self;
}

sub newcookie {
  my $self = shift;
  @_ ? ($self->{asn}{newcookie}=shift)
     : $self->{asn}{newcookie};
  $self->{asn}{cookie};
}

sub responseValue {
  my $self = shift;

  exists $self->{responseValue}
    ? $self->{responseValue}
    : $self->{responseValue} = $syncInfoValue->encode($self->{asn});
}

1;


__END__

=head1 NAME

Net::LDAP::Intermediate::SyncInfo - LDAPv3 Sync Info Message object

=head1 SYNOPSIS

 use Net::LDAP;
 use Net::LDAP::Control::SyncRequest;
 use Net::LDAP::Constant qw(
  LDAP_SYNC_REFRESH_ONLY
  LDAP_SYNC_REFRESH_AND_PERSIST
  LDAP_SUCCESS );

 $ldap = Net::LDAP->new( "ldap.mydomain.eg" );

 $req = Net::LDAP::Control::SyncRequest->new( mode => LDAP_SYNC_REFRESH_ONLY );
 my $mesg = $ldap->search(base=> 'dc=mydomain,dc='eg',
                          scope    => 'sub',
                          control  => [ $req ],
                          callback => \&searchCallback, # call for each entry
                          filter   => "(objectClass=*)",
                          attrs    => [ '*']);
 sub searchCallback {
   my $message = shift;
   my $entry = shift;
   my @controls = $message->control;

   if($controls[0]->isa('Net::LDAP::Control::SyncState')) {
     print "Received Sync State Control\n";
     print $entry->dn()."\n";
     print 'State: '.$controls[0]->state."\n".', entryUUID: '.$controls[0]->entryUUID.', cookie: '.$controls[0]->cookie;
   } elsif($controls[0]->isa('Net::LDAP::Control::SyncDone')) {
     print "Received Sync Done Control\n";
     print 'Cookie: '.$controls[0]->cookie.', refreshDeletes: '.$controls[0]->refreshDeletes;
   }
 }

=head1 DESCRIPTION

C<Net::LDAP::Intermediate::SyncInfo> provides an interface for the creation and
manipulation of objects that represent the C<Sync Info Message> as described
by RFC 4533.

=head1 CONSTRUCTOR ARGUMENTS

In addition to the constructor arguments described in
L<Net::LDAP::Intermediate> the following are provided.

=over 4

=item TODO

=back

=head1 METHODS

As with L<Net::LDAP::Intermediate> each constructor argument
described above is also avaliable as a method on the object which will
return the current value for the attribute if called without an argument,
and set a new value for the attribute if called with an argument.

=head1 SEE ALSO

L<Net::LDAP>,
L<Net::LDAP::Intermediate>,
L<Net::LDAP::Control>,
L<Net::LDAP::Control::SyncRequest>,
L<Net::LDAP::Control::SyncState>,
http://www.ietf.org/rfc/rfc4533.txt

=head1 AUTHOR

Mathieu Parent E<lt>math.parent@gmail.comE<gt>

Please report any bugs, or post any suggestions, to the perl-ldap mailing list
E<lt>perl-ldap@perl.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2008 Mathieu Parent. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

