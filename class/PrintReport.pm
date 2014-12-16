#!perl

package PrintReport;

use Text::CSV;
use Text::ParseWords;
use Data::Dumper qw(Dumper);

############################
# TESTING: Select vendors and map to hash for easy lookup

my @printTypes = ('PRINT', 'CLEAR', 'CLOSE');
my %printTypeMap = map { $_ => 1 } @printTypes;

my %targetStockLevels = (
	'XS' => 50,
	'S' => 65,
	'M' => 100,
	'L' => 100,
	'XL' => 100,
	'2X' => 60,
	'3X' => 36,
	'4X' => 11,
	'5X' => 8,
);

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
		my ($size, $inStock, $code) = (split "\",\"", $line)[3, 11, 17];   # assign names to current row data in array
		
		if (exists $printTypeMap{$code}) {
			
			if($inStock >= 0) {
				$report{$code}{$size} += $inStock;
			}
		}
	}

	close($INVENTORYFILE);
	
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