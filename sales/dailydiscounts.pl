#!perl

####################################
# SALES SUMMARY BY FACILITY v0.4
# Reads "Sales Detail by Transaction" report from The Uniform Solution
# and outputs sales and discount figures for all trucks.
#
# Usage: perl dailydiscounts.pl
#
# Author: Mike Nemeth (mike@mikenemeth.com)
####################################

use strict;
use warnings;
use lib 'C:\scripts\reporting\class';
use SalesReport;
use Text::CSV;
use Math::Round::Var;
use Excel::Writer::XLSX;
use Excel::Writer::XLSX::Utility;
use Data::Dumper qw(Dumper);

############################
# Declare and initialize variables

my $filename = 'C:\scripts\reporting\sales\dailysales.csv';
my $workbook  = Excel::Writer::XLSX->new( 'C:\scripts\reporting\sales\discounts.xlsx' );

my $rounder = Math::Round::Var->new(0.01);
my $totalDiscount = 0;
my $totalRetail = 0;
my $totalActual= 0;
my $discountPercentage= 0;
my %report;
my %totals;


#############################
# Main script

print "Generating sales report table for all stores...\n";
%report = SalesReport::getSalesData( $filename );	#Gets sales data and stores into hash
print "\n-------------------------------------------\n";

my $worksheet = $workbook->add_worksheet( 'Discounts' );
 
my $title = 'Driver Sales and Discounts';
my $timestamp = localtime;

$worksheet->write( 0, 0, $title );
$worksheet->write( 1, 0, "Report generated: $timestamp" );

my $row = 3;
my $col = 0;
my $grandRetail = 0;
my $grandActual = 0;

foreach my $storeNum ( sort keys %report) {	#steps through hash and outputs to Excel file
	
	
	my $tableHeadings = [
		[ "Store $storeNum", "Retail", "Actual", "Discount", "Discount %"],
	];

	$worksheet->write_col( $row, $col, $tableHeadings );
	$row ++;
	my $totalRetail = 0;
	my $totalActual = 0;
	my $totalDisocunt = 0;
	my $totalPercentage = 0;

	foreach my $facility ( sort keys $report{$storeNum} ) {
		my $reportData = [
			[ $facility, $report{$storeNum}{$facility}->{ 'retail' }, $report{$storeNum}{$facility}->{ 'actual' }, $report{$storeNum}{$facility}->{ 'discount' }, $rounder->round($report{$storeNum}{$facility}->{ 'percentage' }) . "%"],
		];
		$worksheet->write_col ( $row, $col, $reportData );
		$row++;
		$totalRetail += $report{$storeNum}{$facility}{ 'retail' };
		$totalActual += $report{$storeNum}{$facility}{ 'actual' };
	}
	$totalDiscount = $totalRetail - $totalActual;
	$totalPercentage = SalesReport::percentage($totalDiscount, $totalRetail);
	$grandRetail += $totalRetail;
	$grandActual += $totalActual;
	my $storeTotals = [
		[ "Total", $rounder->round($totalRetail), $rounder->round($totalActual), $rounder->round($totalDiscount), $rounder->round($totalPercentage) . "%"],
	];
	$worksheet->write_col( $row, $col, $storeTotals);
	$row += 2;
}

my $grandDiscount = $grandRetail - $grandActual;
my $grandTotals = [
	[ "", "Retail", "Actual", "Discount", "Discount %"],
	[ "Totals", $rounder->round($grandRetail), $rounder->round($grandActual), $rounder->round($grandDiscount), $rounder->round(SalesReport::percentage($grandDiscount, $grandRetail)) . "%"],
];
$worksheet->write_col( $row, $col, $grandTotals);

######################################
# Print summary to terminal window
print "\n------  DISCOUNTS BY FACILITY  ------\n";
foreach my $driver ( keys %report )  {
	print "Store $driver\n";

	foreach my $facility (keys $report{$driver}) {
		print "---\n";
		print "$facility\n";
		
		foreach my $figures (keys $report{$driver}{$facility}) {
			my $mynums = $report{$driver}{$facility}{$figures};
			$report{$driver}{$facility}{$figures} = $rounder->round($mynums);
			print "$figures: " . $rounder->round($mynums) . "\n";
		}
	}
	print "\n-----------------------------------\n";
}



#print Dumper \%report;

# End main script
#############################
