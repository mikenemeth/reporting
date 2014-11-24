#!perl

package SalesReport;

use strict;
use warnings;
use Text::CSV;
use Math::Round::Var;

my $rounder = Math::Round::Var->new(0.01);

#############################
# Constructor
# Takes in three arguments; Store Number, Inventory file name, and Sales Summary file name

sub new {
	my $class = shift;
	my $self = {
		#_storeNumber => shift,
		#_inventoryFile => shift,
		#_salesFile => shift,
	};
	
	bless $self, $class;
	return $self;
}


#############################
# Subroutine to calculate percentages

sub percentage {

	my $num = $_[0];
	my $denom = $_[1];
	my $percentage = 0;
	
	if (!$num) {
		$percentage = 0;
	}
	elsif (!$denom == 0) {
		$percentage = ($num/$denom)*100;
	}
	else {
		$percentage = 0;
	}
	
	return $percentage;
}


#############################
# Open source file and build hashes then close file

sub getSalesData {

	my $filename = $_[0];
	my %report;
	
	open(my $SOURCEFILE, '<', $filename) or die "Could not open '$filename' $!\n";

	<$SOURCEFILE>;
	while (my $line = <$SOURCEFILE>) {
		chomp $line;
		my($driver, $soldto, $retail, $actual) = (split "\",\"" , $line)[1, 2, 21, 22];
		
		$driver =~ s/.*-//;
		
		my $facilityRetail = $report{$driver}{$soldto}{ 'retail' };
		my $facilityActual = $report{$driver}{$soldto}{ 'actual' };
		my $facilityDiscount = $report{$driver}{$soldto}{ 'discount' };
		my $facilityPercentage = $report{$driver}{$soldto}{ 'percentage' };
		
		#my $driverRetail = $report{$driver}{ 'Total' }{ 'retail' };
		#my $driverActual = $report{$driver}{ 'Total' }{ 'actual' };
		#my $driverDiscount = $report{$driver}{ 'Total' }{ 'discount' };
		#my $driverPercentage = $report{$driver}{ 'Total' }{ 'percentage' };	
		
		$report{$driver}{$soldto}{ 'retail' } = ($facilityRetail += $retail);
		$report{$driver}{$soldto}{ 'actual' } = ($facilityActual += $actual);
		$report{$driver}{$soldto}{ 'discount' } = ($facilityRetail - $facilityActual);
		$report{$driver}{$soldto}{ 'percentage' } = (&percentage($facilityDiscount, $facilityRetail));
		
		#$report{$driver}{ 'Total' }{ 'retail' } = ($driverRetail += $retail);
		#$report{$driver}{ 'Total' }{ 'actual' } = ($driverActual += $actual);
		#$report{$driver}{ 'Total' }{ 'discount' } = ($driverRetail - $driverActual);
		#$report{$driver}{ 'Total' }{ 'percentage' } = (&percentage($driverDiscount, $driverRetail));
	}

	close($SOURCEFILE);

	return %report;
}


##############################
# Calculate discounts and round floating numbers

sub totalSales {
	
	my %input;
	my %totalSales;

	my $totalDiscount = $totalSales{ 'retail' };
	my $totalRetail = $totalSales{ 'actual' };
	my $totalActual= $totalSales{ 'discount' };
	my $discountPercentage= $totalSales{ 'percentage' };
	

	foreach my $driver ( keys %input )  {

		print "Store $driver\n";
		my $key = 'Total';
		my $retail = $input{$driver}{$key}{ 'retail' };
		my $actual = $input{$driver}{$key}{ 'actual' };
		my $discount = $input{$driver}{$key}{ 'discount' };
		my $percentage = $input{$driver}{$key}{ 'percentage' };		
	}

	return %totalSales;
	
}

1;