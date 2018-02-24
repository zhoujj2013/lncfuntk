use strict;
use warnings;
use LWP::Simple;

my $query = "http://137.189.133.71/lncfuntk/";
my $browser = LWP::UserAgent->new;
my $response = $browser->get( $query );

print $response->code;
