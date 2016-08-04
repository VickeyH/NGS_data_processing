#!/usr/bin/perl
use strict; 
use warnings; 
use fileSunhh; 
use Getopt::Long; 
my %opts; 
GetOptions(\%opts, 
	"help!", 
	"out_cumLen:s", 
	"delt_len:i", # 0 
); 

$opts{'delt_len'} //= 0; 

!@ARGV and die "perl $0 apple_chrLen whole_grp_2ato1/apple_whole.chr1.snp.out.xpclr.txt.w10ks10k\n"; 

my %glob; 
defined $opts{'out_cumLen'} and $glob{'fh_oCumLen'} = &openFH( $opts{'out_cumLen'}, '>' ); 

my $fn_chrCL = shift; 
my $fn_wind  = shift; 
my $new_id = "joinedChr"; 

my %chrCumS = %{ &load_chrCL( $fn_chrCL ) }; 

my $fh = &openFH( $fn_wind, '<' ); 
while (&wantLineC($fh)) {
	my @ta = &splitL("\t", $_); 
	if ( $ta[0] =~ m/^chrID$/i ) {
		print STDOUT join("\t", @ta)."\n"; 
		next; 
	}
	my $rawID = $ta[0]; 
	$rawID =~ m!^(\d+)$! and $rawID = "chr$rawID"; 
	defined $chrCumS{$rawID} or die "$_\n"; 
	for my $tb (@ta[1,2]) {
		$tb = $tb + $chrCumS{$rawID}[0]; 
	}
	$ta[0] = $new_id; 
	print STDOUT join("\t", @ta)."\n"; 
}
close($fh); 


sub load_chrCL {
	my $fn = shift; 
	my %back; 
	my $fh = &openFH($fn, '<'); 
	my $cum = 0; 
	defined $opts{'out_cumLen'} and print {$glob{'fh_oCumLen'}} join("\t", qw/chrID chrLen chrCumS chrCumE/)."\n"; 
	while (&wantLineC($fh)) {
		my @ta=&splitL("\t", $_); 
		defined $back{$ta[0]} and die "repeat: $_\n"; 
		$back{$ta[0]} = [$cum, $ta[1]]; 
		defined $opts{'out_cumLen'} and print {$glob{'fh_oCumLen'}} join("\t", $ta[0], $ta[1], $back{$ta[0]}[0]+1, $back{$ta[0]}[0]+$ta[1])."\n"; 
		$cum += ($ta[1] + $opts{'delt_len'}); 
	}
	close($fh); 
	defined $opts{'out_cumLen'} and close($glob{'fh_oCumLen'}); 
	return(\%back); 
}

