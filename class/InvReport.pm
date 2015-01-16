#!perl

package InvReport;

use Text::CSV;
use Text::ParseWords;
use Math::Round;

############################
# TESTING: Select vendors and map to hash for easy lookup

my @vendors = ('WKS', 'CHE', 'KOI', 'WCS');
my %vendorMap = map { $_ => 1 } @vendors;


############################
# TESTING: Declare and initialize variables
# $weeks is number of weeks to divided sales averages by
# $targetWeeks is number of weeks to stock for

my $weeks = 11;
my $targetWeeks = 4.5;


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
	
	#print "Store Number is: $self->{_storeNumber}\n;";
	#print "Inventory file is: $self->{_inventoryFile}\n";
	#print "Sales summary file is: $self->{_salesFile}\n";
}

#############################
# Method to set number of weeks to calculate average quantity sold *future use*

sub setWeeks {
	
}


#############################
# Method to set list of vendors to report *future use*

sub setVendors {
	
}

#############################
# Method to calculate Min/Max divided by weekly average

sub minMaxAverage {

	my $minMax = $_[0];
	my $weeklyAverage = $_[1];
	my $minMaxAverage = 0;
	
	if (!$weeklyAverage == 0) {
		$minMaxAverage = ($minMax/$weeklyAverage);
	}
	else {
		$minMaxAverage = 0;
	}
	
	return $minMaxAverage;
}


#############################
# Method to calculate target stock over/under amount

sub stockOffset {

	my $weeklyAverage = $_[0];
	my $onHand = $_[1];
	my $onOrder = $_[2];
	my $stockOffset = 0;
	
	if ($weeklyAverage) {
		$stockOffset = ($weeklyAverage * $targetWeeks) - ($onHand + $onOrder);
	}
	
	return $stockOffset;
}

#############################
# Method to calculate Min/Max over/under amount

sub minMaxOffset {

	my $stockOffset = $_[0];
	my $onHand = $_[1];
	my $onOrder = $_[2];
	my $min = $_[3];
	my $minMaxOffset = 0;
	
		$minMaxOffset = (($onHand + $onOrder) + $stockOffset) - $min;
	
	return $minMaxOffset;
}


############################
# Takes in two file names as arguments,
# and returns data in a multidimensional hash.
# CSV file is parsed line-by-line and 

sub generateReport {
	
	my $inputDirectory = $_[0];
	my $inventoryDataFile = "${inputDirectory}$_[1]";
	my $salesDataFile = "${inputDirectory}$_[2]";
	
	my %report;

	print "Using inventory list: $inventoryDataFile\n";
	print "Using sales list: $salesDataFile\n";
	
	open( my $INVENTORYFILE, '<', $inventoryDataFile ) or die "Could not open '$inventoryDataFile' $!\n";
	
	<$INVENTORYFILE>;
	while (my $line = <$INVENTORYFILE>) {
		chomp $line;
		$line =~ s/\"//g;  # remove double quotes from line before splitting since first column is to be used; better way to do this?
		my ($vendor, $inStock, $onOrder, $max, $min) = (split ",", $line)[0, 11, 12, 13, 14];   # assign names to current row data in array
		
		if (exists $vendorMap{$vendor}) {
			if ($min or $max) {  #check if min or max value exists
			
				my $inStockTotal = $report{$vendor}{ 'InStock' };
				my $onOrderTotal = $report{$vendor}{ 'OnOrder' };
				my $minTotal = $report{$vendor}{ 'Min' };
				my $maxTotal = $report{$vendor}{ 'Max' };
			
				if ($inStock) {
					$report{$vendor}{ 'InStock' } += $inStock;
				}		
				else {
					$report{$vendor}{ 'InStock' } += 0;
				}
				
				if ($onOrder) {
					$report{$vendor}{ 'OnOrder' } += $onOrder;
				}		
				else {
					$report{$vendor}{ 'OnOrder' } += 0;
				}
				
				$report{$vendor}{ 'Min' } += $min;
				$report{$vendor}{ 'Max' } += $max;
			}
		}
	}

	close($INVENTORYFILE);


	open( my $SALESFILE, '<', $salesDataFile ) or die "Could not open '$salesDataFile' $!\n";
		
	<$SALESFILE>;
	while (my $line = <$SALESFILE>) {
		chomp $line;
		my($vendor, $soldQty) = (split "\",\"", $line)[2, 9];   # assign names to current row data in array
		
		if (exists $vendorMap{$vendor}) {
		
			my $weeklyAverage = $report{$vendor}{ 'WeeklyAverage' };
			
			if ($soldQty) {
				$report{$vendor}{ 'SoldQty' } += $soldQty;
			}		
			else {
					$report{$vendor}{ 'SoldQty' } += 0;
			}
			
			$report{$vendor}{ 'WeeklyAverage' } = round($report{$vendor}{ 'SoldQty' } / $weeks);
			
			$report{$vendor}{ 'StockOffset' } = stockOffset($report{$vendor}{ 'WeeklyAverage' }, $report{$vendor}{ 'InStock' }, $report{$vendor}{ 'OnOrder' });
			
			$report{$vendor}{ 'MinMaxOffset' } = minMaxOffset($report{$vendor}{ 'StockOffset' }, $report{$vendor}{ 'InStock' }, $report{$vendor}{ 'OnOrder' }, $report{$vendor}{ 'Min' });
		}
	}

	close($SALESFILE);
	
	return %report;
}

##########################################
# Print to screen

sub printScreen {
	
	my %myReport = $_[0];
	
	print "\n------  INVENTORY BY VENDOR  ------\n";
	foreach my $key ( keys %myReport )  {
		print "$key\n";
		foreach my $value (keys $myReport{$key}) {
			print "$value: " . $myReport{$key}->{$value} . "\n";
		}
		print "\n";
	}

	print "Pull single value from hashses: " . $myReport{ 'WKS' }->{ 'SoldQty' } . "\n";
}