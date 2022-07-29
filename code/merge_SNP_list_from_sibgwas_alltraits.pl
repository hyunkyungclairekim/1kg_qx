

#!/usr/bin/perl -w
#use DBI;
#use Math::CDF qw(qnorm);
#use bytes;
#use warnings;
#use strict;


$SOURCE_PATH = "/project2/jjberg/hkim/1kg_qx";



print STDERR "Reading the list of merged SNPs from all sib-gwas traits..\n";
### merged list

# read 1kg seq data files
@files = <$SOURCE_PATH/data/sib_gwas/filtered/*>;

$cnt = 0;

foreach $file (@files) {
	next if index($file, "_pvalfiltered") == -1;

	open my $fin, '<', $file || die "Cannot read from high freq data\n";
	print STDERR "Reading variants from: $file\n";

	$HEADER = <$fin>;
	$HEADER =~ s/[\r\n]//g;		# split the header by line
	@d = split /\s+/, $HEADER;	# split the header by space

	while(<$fin>) {		# while there's input from the file
		chomp;
		s/[\r\n]//g;
		@d = split /\s+/, $_;	# split by space
	#	print STDERR "$d[0]\n";
		$id = "$d[0]\_$d[1]\_$d[3]\_$d[4]";
	#	print STDERR "$id\n";
		next if exists $idsToTake{$id};
		$id2rs{$id} = $d[2];
		$idsToTake{$id} = 1;
		$id2chr{$id} = $d[0];
		$id2pos{$id} = $d[1];
		$id2ref{$id} = $d[3];
		$id2alt{$id} = $d[4];

		$cnt++;
	}
}

print STDERR "SNP cnt: $cnt\n";

foreach $id (sort { $id2chr{$a} <=> $id2chr{$b} || $id2pos{$a} <=> $id2pos{$b} } keys %idsToTake) {
	push @OUT, "$id2chr{$id}\t$id2pos{$id}\t$id2ref{$id}\t$id2alt{$id}\t$id2rs{$id}";
}


print "CHROM\tPOS\tREF\tALT\tID\n";
foreach(@OUT) { print "$_\n" };

exit;
