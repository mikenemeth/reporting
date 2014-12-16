#!../perl

####################################
# PRINT TOP ANALYSIS v0.1
# Reads "Sales Summary by Item" and "Inventory" CSV reports from The Uniform Solution
# and outputs min/max, on hand, on order, and average quantities sold to XLS file.
#
# Refer to CPAN libraries' documentation for usage and available methods
#
# Usage: perl printana.pl
#
# Author: Mike Nemeth (mike@mikenemeth.com)
####################################

use strict;
use warnings;
use lib 'C:\scripts\reporting\class';
use PrintReport;
use Text::CSV;
use Data::Dumper qw(Dumper);
use Excel::Writer::XLSX;
use Excel::Writer::XLSX::Utility;


############################
# Declare and initialize variables

#my $baseDirectory = 'C:\scripts\reporting\inventory\\';
my $workbook  = Excel::Writer::XLSX->new( 'C:\scripts\reporting\inventory\output\Print Analysis.xlsx' );

############################
# Map directories with hash

my %inputDirectory = (
	'Store 1' => 'C:\scripts\reporting\inventory\input\store 1\\',
	'Store 3' => 'C:\scripts\reporting\inventory\input\store 3\\',
	'Store 6' => 'C:\scripts\reporting\inventory\input\store 6\\',
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
my $invReport = new PrintReport();

####################################################
# FULL-PRICE PRINT REPORT


	my $worksheet = $workbook->add_worksheet( 'Full-Price' );
	my $title = 'Full-Price Print Inventory';
	my $timestamp = localtime;

	$worksheet->write( 0, 0, $title, $headingFormat );
	$worksheet->write( 1, 0, "Report generated: $timestamp" );

	my $row = 3;
	my $col = 0;

	my $tableHeadings = [
		[ '', 'XS', 'S', 'M', 'L', 'XL', '2X', '3X', '4X', '5X' ],
		[ '', 50, 65, 100, 100, 100, 60, 36, 11, 8 ],
	];

	$worksheet->write_col( $row, $col, $tableHeadings, $tableHeadFormat );
	$row += 2;

	foreach my $storeNum (sort {$a <=> $b} @stores) {

		print "\nGenerating report table for Store $storeNum...\n";
		%myReport = PrintReport::generateReport( $inputDirectory{ "Store $storeNum" }, 'InventoryList.csv', 'SalesSummary.csv' );
		print "\n-------------------------------------------\n";
		
		print Dumper \%myReport;
		
		my $regPrintData = [
			[ "Truck $storeNum", $myReport{'PRINT'}{'XS'}, $myReport{'PRINT'}{'S'}, $myReport{'PRINT'}{'M'}, $myReport{'PRINT'}{'L'}, $myReport{'PRINT'}{'XL'},$myReport{'PRINT'}{'2XL'},$myReport{'PRINT'}{'3XL'}, $myReport{'PRINT'}{'4XL'}, $myReport{'PRINT'}{'5XL'} ],
		];
		
		$worksheet->write_col ( $row, $col, $regPrintData, $tableFormat );
		$row++;
	}

print "Report generation complete. Go hog wild!\n";