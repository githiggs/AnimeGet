# auto download

use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
    authors     => 'Higgsy',
    name        => 'AnimeGet',
    description => 'Auto download Anime when they get anounced in public',
    license     => 'Public Domain'
);

sub update_seriesdb {
	my($name, $epnr) = @_;
	# open db, load db to array, 2d structure, aa[x][y]
	my @aa_seriedb = load_db_array();
	# get nr of elements in aa_seriedb
	my $nr_aa_seriedb = @aa_seriedb;
	#open file, update
	open(FILE_SERIESDB, '>'.$ENV{'HOME'}.'/.irssi/AnimeGet/SeriesDB') || die ("AnimeGet.pl: Could not open file:".$!);
	for (my $i = 0; $i <= $nr_aa_seriedb-1; $i++){
		if ($aa_seriedb[$i][0] eq $name && $aa_seriedb[$i][1]+1 == $epnr){
			if ($i == 0){
				print FILE_SERIESDB $aa_seriedb[$i][0]."::".$epnr."::".$aa_seriedb[$i][2]."::".$aa_seriedb[$i][3];
			}
			else{
				print FILE_SERIESDB "\n".$aa_seriedb[$i][0]."::".$epnr."::".$aa_seriedb[$i][2]."::".$aa_seriedb[$i][3];
			}
		}
		else {
			if ($i == 0){
				print FILE_SERIESDB $aa_seriedb[$i][0]."::".$aa_seriedb[$i][1]."::".$aa_seriedb[$i][2]."::".$aa_seriedb[$i][3];
			}
			else{
				print FILE_SERIESDB "\n".$aa_seriedb[$i][0]."::".$aa_seriedb[$i][1]."::".$aa_seriedb[$i][2]."::".$aa_seriedb[$i][3];
			}
		}
	}
	close (FILE_SERIESDB);	
}

sub update_queue {
	my($name, $epnr) = @_;
	# open queue, load queue to array, 2d structure, aa[x][y], (name, epnr, getnr, altgetnr, alttime)
	my @aa_getqueue = load_queue_array();
	#get nr of elements in @aa_getqueue
	my $nr_aa_getqueue = @aa_getqueue;
	#open file, update
	open(FILE_GETQUEUE, '>'.$ENV{'HOME'}.'/.irssi/AnimeGet/GetQueue') || die ("AnimeGet.pl: Could not open file:".$!);
	for (my $i = 0; $i <= $nr_aa_getqueue-1; $i++){
		if ($aa_getqueue[$i][0] ne $name && $aa_getqueue[$i][1] != $epnr){
			if ($i == 0){
				print FILE_GETQUEUE $aa_getqueue[$i][0]."::".$aa_getqueue[$i][1]."::".$aa_getqueue[$i][2]."::".$aa_getqueue[$i][3]."::".$aa_getqueue[$i][4];
			}
			else {
				print FILE_GETQUEUE "\n".$aa_getqueue[$i][0]."::".$aa_getqueue[$i][1]."::".$aa_getqueue[$i][2]."::".$aa_getqueue[$i][3]."::".$aa_getqueue[$i][4];
			}
		}
	}
	close (FILE_GETQUEUE);	
}

sub start_download {
	my ($server, $botname) = @_;
	#check if already downloading
	if (Irssi::Irc::dccs() == "") {
		# open queue, load queue to array, 2d structure, aa[x][y], (name, epnr, getnr, altgetnr, alttime)
		my @aa_getqueue = load_queue_array();
		#get nr of elements in @aa_getqueue
		my $nr_aa_getqueue = @aa_getqueue;
		#see if there are any items in queue
		if ($nr_aa_getqueue != 0){
			#check if queue item is not an alt file with wrong time, else try next item
			for (my $i=0; $i <= $nr_aa_getqueue-1; $i++){
				if ($aa_getqueue[$i][2] != 0){
					#send download msg
					$server->command("/msg ".$botname." xdcc send #".$aa_getqueue[$i][2]);
					#update Queue
					update_queue($aa_getqueue[$i][0], $aa_getqueue[$i][1]);
					#update SeriesDB
					update_seriesdb($aa_getqueue[$i][0], $aa_getqueue[$i][1]);
					$i = $nr_aa_getqueue-1;
				}
				elsif ($aa_getqueue[$i][2] == 0 && $aa_getqueue[$i][3] != 0 && $aa_getqueue[$i][4] <= time()){
					#send download msg
					$server->command("/msg ".$botname." xdcc send #".$aa_getqueue[$i][3]);
					#update Queue
					update_queue($aa_getqueue[$i][0], $aa_getqueue[$i][1]);
					#update SeriesDB
					update_seriesdb($aa_getqueue[$i][0], $aa_getqueue[$i][1]);
					$i = $nr_aa_getqueue-1;
				}
			}			
		}
	}
}

sub add_to_queue {
	my ($name, $epnr, $getnr, $altgetnr, $alttime) = @_;
	# open queue, load queue to array, 2d structure, aa[x][y], (name, epnr, getnr, altgetnr, alttime)
	my @aa_getqueue = load_queue_array();
	#get nr of elements in @aa_getqueue
	my $nr_aa_getqueue = @aa_getqueue;
	#check if the series is in the queue already
	my $found = -1;
	for (my $i=0; $i <= $nr_aa_getqueue-1; $i++){
		if ($aa_getqueue[$i][0] eq $name && $aa_getqueue[$i][1] == $epnr){
			$found = $i;
		}
	}
	#if series is in queue already than $found is not -1
	if ($found == -1){
		#open file, write to end
		open(FILE_GETQUEUE, '>>'.$ENV{'HOME'}.'/.irssi/AnimeGet/GetQueue') || die ("AnimeGet.pl: Could not open file:".$!);
		#solve new line problem
		if ($nr_aa_getqueue == 0){
			print FILE_GETQUEUE $name."::".$epnr."::".$getnr."::".$altgetnr."::".$alttime;
		}
		else{
			print FILE_GETQUEUE "\n".$name."::".$epnr."::".$getnr."::".$altgetnr."::".$alttime;
		}
		close (FILE_GETQUEUE);
	}
	else{
		#update $aa_getqueue
		$aa_getqueue[$found][2] = $getnr;
		$aa_getqueue[$found][3] = $altgetnr;
		$aa_getqueue[$found][4] = $alttime;
		#open file, update
		open(FILE_GETQUEUE, '>'.$ENV{'HOME'}.'/.irssi/AnimeGet/GetQueue') || die ("AnimeGet.pl: Could not open file:".$!);
		for (my $i = 0; $i <= $nr_aa_getqueue-1; $i++){
			if ($i == 0){
				print FILE_GETQUEUE $aa_getqueue[$i][0]."::".$aa_getqueue[$i][1]."::".$aa_getqueue[$i][2]."::".$aa_getqueue[$i][3]."::".$aa_getqueue[$i][4];
			}
			else{
				print FILE_GETQUEUE "\n".$aa_getqueue[$i][0]."::".$aa_getqueue[$i][1]."::".$aa_getqueue[$i][2]."::".$aa_getqueue[$i][3]."::".$aa_getqueue[$i][4];
			}
		}
		close (FILE_GETQUEUE);
	}
}

sub split_to_array {
	my ($msg) = @_;
	my @a_msg = split(/\[|\]/, $msg);
	my @a_name_epnr = (split(/(-)/, $a_msg[4]));
	my $epnr = substr $a_name_epnr[-1], 1, -1;
	delete $a_name_epnr[-1];
	my @a_getnr = (split(/ /, $a_msg[6]));
	my @a_split_msg = ((substr join("",@a_name_epnr), 1, -2), $epnr, $a_msg[5], (substr $a_getnr[-1], 0, -2));
	#return (name, epnr, quality, getnr)
	return @a_split_msg;
}

sub load_queue_array {
	#open file, read
	open(FILE_GETQUEUE, '<'.$ENV{'HOME'}.'/.irssi/AnimeGet/GetQueue') || die ("AnimeGet.pl: Could not open file:".$!);
	my @aa_getqueue;
	while (<FILE_GETQUEUE>) {
		chomp;
		push @aa_getqueue, [ split /::/ ];
	}
	close (FILE_GETQUEUE);
	return @aa_getqueue;
}

sub load_db_array {
	#open file, read
	open(FILE_SERIESDB, '<'.$ENV{'HOME'}.'/.irssi/AnimeGet/SeriesDB') || die ("AnimeGet.pl: Could not open file:".$!);
	my @aa_seriedb;
	while (<FILE_SERIESDB>) {
		chomp;
		push @aa_seriedb, [ split /::/ ];
	}
	close(FILE_SERIESDB);
	return @aa_seriedb;
}

sub sig_get_public_chat {
	my ($server, $msg, $nick, $address, $target) = @_;
	#open file, read
	open(FILE_ANIMEGET_CONFIG, '<'.$ENV{'HOME'}.'/.irssi/AnimeGet/getconfig') || die ("AnimeGet.pl: Could not open file:".$!);
	my ($configname, $configvalue) = split(/=/, <FILE_ANIMEGET_CONFIG>);
	close(FILE_ANIMEGET_CONFIG);
	
	if ($nick eq $configvalue) {
		# open db, load db to array, 2d structure, aa[x][y], (name, epnr, quality, altquality)
		my @aa_seriedb = load_db_array();
		# get nr of elements in aa_seriedb
		my $nr_aa_seriedb = @aa_seriedb;
		#split (name, epnr, quality, getnr)
		my @a_msg = split_to_array($msg);
		
		for (my $i = 0; $i <= $nr_aa_seriedb-1; $i++){
		
			if ($aa_seriedb[$i][0] eq $a_msg[0] && $aa_seriedb[$i][1]+1 <= $a_msg[1]){
				if ($aa_seriedb[$i][2] eq $a_msg[2]){
					#add serie to queue file
					add_to_queue($a_msg[0], $a_msg[1], $a_msg[3], 0, 0);
				}
				elsif ($aa_seriedb[$i][3] eq $a_msg[2]){
					#add series to queue as alt, add time.
					my $dl_time = (time() + 3600);
					add_to_queue($a_msg[0], $a_msg[1], 0, $a_msg[3], $dl_time);
				}
				else{
					#end loop
					$i = ($nr_aa_seriedb-1);
				}				
			}
		}
	}
	start_download($server, $configvalue);
}

Irssi::signal_add_last("message public", "sig_get_public_chat");
