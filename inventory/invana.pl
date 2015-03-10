#!../perl

####################################
# INVENTORY ANALYSIS v0.2
# Reads "Sales Summary by Item" and "Inventory" CSV reports from The Uniform Solution
# and outputs min/max, on hand, on order, and average quantities sold to XLS file.
#
# Refer to CPAN libraries' documentation for usage and available methods
#
# Usage: perl invana.pl
#
# Author: Mike Nemeth (mike@mikenemeth.com)
####################################

use strict;
use warnings;
use lib 'C:\scripts\reporting\class';
use InvReport_v2;
use Text::CSV;
use Data::Dumper qw(Dumper);
use Excel::Writer::XLSX;
use Excel::Writer::XLSX::Utility;
use Math::Round::Var;

my $rounder = Math::Round::Var->new(0.01);

############################
# Declare and initialize variables

#my $baseDirectory = 'C:\scripts\reporting\inventory\\';
my $workbook  = Excel::Writer::XLSX->new( 'C:\scripts\reporting\inventory\output\Truck Inventory Analysis.xlsx' );
my $weeks = 11;
my $targetWeeks = 4.5;

############################
# Map directories with hash

my %inputDirectory = (
	'Store 1' => 'C:\scripts\reporting\inventory\input\store 1\\',
	'Store 2' => 'C:\scripts\reporting\inventory\input\store 2\\',
	'Store 3' => 'C:\scripts\reporting\inventory\input\store 3\\',
	'Store 6' => 'C:\scripts\reporting\inventory\input\store 6\\',
	'Store 8' => 'C:\scripts\reporting\inventory\input\store 8\\',
	'Store 10' => 'C:\scripts\reporting\inventory\input\store 10\\',
	'Store 12' => 'C:\scripts\reporting\inventory\input\store 12\\',
	'Store 13' => 'C:\scripts\reporting\inventory\input\store 13\\',
	'Store 15' => 'C:\scripts\reporting\inventory\input\store 15\\',
	'Store 16' => 'C:\scripts\reporting\inventory\input\store 16\\',
	'Store 17' => 'C:\scripts\reporting\inventory\input\store 17\\',
);

############################
# Select stores and map to hash for easy lookup

my @stores = (1, 3, 6, 10, 12, 13, 15, 16, 17);
my %storeMap = map { $_ => 1 } @stores;

############################
# Select vendors and map to hash for easy lookup

#my @vendors = ('WKS', 'CHE', 'KOI');
#my %vendorMap = map { $_ => 1 } @vendors;


##############################################
# Create Excel writer format objects

my $headingFormat = $workbook->add_format(
	bold => 1,
	size => 16,
);

my $tableHeadFormat = $workbook->add_format(
	bold => 1,
	color => 'white',
	bg_color => '#366092',
	border => 1,
	border_color => 'black',
	align => 'center',
);

my $tableFormat = $workbook->add_format(
	border => 1,
	border_color => 'black',
	align => 'center',
);


##########################################
# Main script
# Outputs formatted Excel spreadsheet - loops through array of stores
# and passes input files to generateReport() for each store. 
# Returned hashes for each store are then looped through and output
# to an Excel workbook.
#
# Floats are rounded after calculations are complete to minimize rounding errors


my %myReport;
my $invReport = new InvReport();
my $worksheet = $workbook->add_worksheet( 'Latest' );
 
my $title = 'Truck Inventory Analysis';
my $timestamp = localtime;

$worksheet->write( 0, 0, $title, $headingFormat );
$worksheet->write( 1, 0, "Report generated: $timestamp" );

my $row = 3;
my $col = 0;

foreach my $storeNum (sort {$a <=> $b} @stores) {

	print "\nGenerating report table for Store $storeNum...\n";
	%myReport = InvReport::generateReport( $inputDirectory{ "Store $storeNum" }, 'InventoryList.csv', 'SalesSummary.csv' );
	print "\n-------------------------------------------\n";
	
	#print Dumper \%myReport;
	
	my $tableHeadings = [
		[ "Truck $storeNum", '1 Week', 'In Stock', 'On Order', 'Min-Max', 'At M/M', 'Stock+/-', 'M/M+/-', 'O/H' ],
	];

	$worksheet->write_col( $row, $col, $tableHeadings, $tableHeadFormat );
	$row++;

	foreach my $key ( sort keys %myReport ) {
		my $atMinMax = 0;
		my $oh = 0;
		if (!$myReport{$key}->{ 'WeeklyAverage' } == 0) {
			$atMinMax = $rounder->round(( $myReport{$key}{ 'Min' }) / $myReport{$key}->{ 'WeeklyAverage' });
		}
		else {
			$atMinMax = 0;
		}
		
		if (!$myReport{$key}->{ 'WeeklyAverage' } == 0) {
			$oh = $rounder->round(($myReport{$key}{ 'InStock' } + $myReport{$key}{ 'OnOrder' } + $myReport{$key}{ 'StockOffset' }) / $myReport{$key}{ 'WeeklyAverage' });
		}
		
		else {
			$oh = 0;
		}
		
		
		my $reportData = [
			[ $key, $myReport{$key}->{ 'WeeklyAverage' }, $myReport{$key}->{ 'InStock' }, $myReport{$key}->{ 'OnOrder' }, $myReport{$key}->{ 'Min' }, $atMinMax, $myReport{$key}->{ 'StockOffset' }, $myReport{$key}->{ 'MinMaxOffset' }, $oh ],
		];
		$worksheet->write_col ( $row, $col, $reportData, $tableFormat );
		$row++;
	}
$row++;
}

print "Report generation complete. Go hog wild!\n";


#print Dumper %myReport;