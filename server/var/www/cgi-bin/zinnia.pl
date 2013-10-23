#!/usr/bin/perl

use strict;
use warnings;

use zinnia;


my $buffer = $ENV{ 'QUERY_STRING' };
my @qbuf = split/&/, $buffer;
my %query;
foreach( @qbuf ) {
	my ( $key, $value ) = split/=/,$_;
	# Decode url-encoded string
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack( "C", hex( $1 ) )/eg;
	# Put into hash variable by the format key & value
	$query{ $key } = $value;
}

#
# Put parameters into variables
#
my $input = $query{ 'pnl' };
my $count = 10;
if ( exists( $query{ 'count' } ) ) {
	$count = $query{ 'count' };
}

#
# Create objects of zinnia
#
my $s = new zinnia::Character;
my $r = new zinnia::Recognizer;

die "$!: cannot open\n"
	if (!$r->open("/usr/local/lib/zinnia/model/tomoe/handwriting-ja.model"));

#
# Parse a value of scanning
#
die $s->what() if (!$s->parse($input));

#
# Execute a recognition processing
#
my $result = $r->classify( $s, $count );

print "Content-Type: application/xml\n\n";

print "<recognize>\n";
printf "<coordinate>%s</coordinate>\n", $s->toString();
print "<results>\n";
my $size = $result->size();
for ( my $i = 0; $i < $size; ++$i ) {
	printf "<result><character>%s</character><score>%f</score></result>\n", $result->value($i), $result->score($i);
}
print "</results>\n";
print "</recognize>\n";

exit( 0 );


