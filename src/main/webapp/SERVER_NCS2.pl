use strict;
use warnings FATAL => 'all';

###### MALLON CRASHAREI OTAN DEN BRISKEI APOTELESMA

#declare global variables
#my $HMMDB_PATH = "/home/napoleon/Desktop/chrysoula_seqs/HMMDB";
my $HMMDB_PATH = "../../../HMMDB";
#my $HMMDB_PATH = "/home/napoleon/Dropbox/SERVER_NCS-2/HMMDB";
my $HMMER_PATH = "/usr/bin/hmmscan";
#my $HMMER_PATH = "/home/napoleon/Apps/HMMER/binaries/hmmscan";
my %hash_seq = (); #used for the initial seq file -------- FILE IN FASTA FORMAT --> INTO HASH
my %hash = ();
my %hash_2a = ();
my %hash_ncs2 = ();
#declare input file and argument
my ($input_arg , $input_file) = @ARGV;
chomp($input_arg, $input_file);
#print STDOUT $input_file."\n";
format_id($input_file); #this function takes the initial seq file and reformas it to fasta

### GIA TO HMMER:
# -o MAIN_OUT_2A_1.txt --> to output pou tha dwsei sto terminal kathws trexei to hmmer tha apothhkeutei se file (kai den tha fenetai sto terminal)
# --domtblout --> ena sugkekrimeno format pou dinei ena summary me ta apotelesmata (apothhkeuontai sto output HMMDOM_2A_1.txt)
# -E --> e-value (krataei hits me e-value <= apo auto pou exei orisei sthn entolh
# meta to evalue dinei prwta to database file kai meta to query file gia na treksei to hmmer

system($HMMER_PATH." -o ./MAIN_OUT_2A_1.txt --domtblout ./HMMDOM_2A_1.txt -E 1e-2 ".$HMMDB_PATH."/HMMDB_2A ./tmp_seq_2a_1.fasta");
read2A_HMMER();
#fainetai na mhn ektelei auth thn entolh an den exei dwsei apotelesmata h panw entolh
system($HMMER_PATH." -o ./MAIN_OUT_NCS2_2.txt --domtblout ./HMMDOM_NCS2_2.txt -E 1e-2 ".$HMMDB_PATH."/HMMDB_NCS2 ./tmp_seq_ncs2.fasta");
readNCS2_HMMER();
open (FOUT_3, "> ./REPORT FINISHED.txt") || die "Failed FOUT_3\n";
print FOUT_3 "FINISHED OK\n";
close(FOUT_3);

sub format_id {
	my $file_in = shift;
#	print STDOUT $file_in."\n";

	open(FIN, "< ./".$file_in) || die "Failed FIN from FORMAT_ID\n";

	my $first_line = qx/head -n 1 $file_in/;
	chomp($first_line);
	if($first_line =~ /^>\S+/){                    #if it is a fasta file
		while(my $line = <FIN>){
			chomp($line);
			$line =~ s/\R//g;
			if ($line =~ /^>(\S+)/) {
				my $prot = $1;
				$hash_seq{tmp_protein_name}[0] = $prot;
			}

			if ($line =~ /^(\w+)/){
				my $prot = $hash_seq{tmp_protein_name}[0];
				$hash_seq{$prot}[0] .= $1;
			}
		}
	} elsif ($first_line =~ /^\w+/){                #if it is not fasta
		my $tmp_id = 1;
		while(my $line = <FIN>){
			chomp($line);
			$line =~ s/\R//g;

			if($line =~ /^(\w+)/){
				my $tmp_name = "PROTEIN_".$tmp_id;
				$hash_seq{$tmp_name}[0] .= $1;
				#print STDOUT $tmp_id."\n";
			}

			if($line =~ /^$/){                       #I do not know why it is not working with \s+ or \W+
				$tmp_id++;
				#print STDOUT $tmp_id."\n";
			}
		}
	} else {
		die "Format of the file is unknown!"
	}
	close(FIN);

###### ANOIGEI OUTFILE (tmp_seq_2a_1.fasta) KAI KANEI PRINT TIS AKOLOUTHIES SE FASTA  FORMAT SE MIA GRAMMH
# KAI XRHSIMOPOIEI TO FILE AUTO SAN INPUT STO HHMER
	open(FOUT, "> ./tmp_seq_2a_1.fasta") || die "Failed FOUT FORMAT ID\n";
	foreach my $key(keys %hash_seq){
		chomp($key);
		if($key eq "tmp_protein_name"){
			next;
		}
		print FOUT ">".$key."\n".$hash_seq{$key}[0]."\n";
	}
	close(FOUT);
}

######## OTAN TO HMMER DINEI APOTELESMATA OI GRAMMES POU EXOUN SXOLIA KSEKINANE ME "#" KAI TA HITS (ta apotelesmata) DEN KSEKINOUN ME "#".
######## GIAYTO, OTAN BRISKEI GRAMMH POY KSEKINAEI ME "#" THN AFHNEI KAI PROXWRAEI STIS EPOMEMNES
######## ARA OTAN TO HMMER DEN EXEI DWSEI APOTELESMA KANEI SKIP (me thn entolh next pou exei mesa sta if-loops) OLES TIS GRAMMES GIATI OLES KSEKINANE ME "#"

sub read2A_HMMER { #this function reads the result from the 2A hmmscan and create the file to be processed with ncs2
	open(FIN, "< ./HMMDOM_2A_1.txt") || die "Failed to read HMMDOM_2A_1 from read2A_HMMER\n";
	while(my $line = <FIN>){
		chomp($line);
		if($line =~ /^#/){
			next;
		}
		my @tmp_array = ();
		@tmp_array = split(/\s+/, $line);
		my $tmp_prot = "xxx";
		$tmp_prot = $tmp_array[3];
		my $tmp_model = "xxx";
		$tmp_model = $tmp_array[0];
		$hash_2a{$tmp_prot}[0] = 0;
	}
	close(FIN);

	open(FIN, "< ./HMMDOM_2A_1.txt") || die "Failed to read HMMDOM_2A_1 from read2A_HMMER\n";
	while(my $line = <FIN>){
		chomp($line);
		if($line =~ /^#/){
			next;
		}
		my @tmp_array = ();
		@tmp_array = split(/\s+/, $line);
		my $tmp_prot = "xxx";
		$tmp_prot = $tmp_array[3];
		my $tmp_model = "xxx";
		$tmp_model = $tmp_array[0];
		if($hash_2a{$tmp_prot}[0] == 0){
			$hash_2a{$tmp_prot}[0] = 1;
			if(($tmp_model =~ /^NCS2/) || ($tmp_model eq "2.A.40.7")){
				$hash_ncs2{$tmp_prot}[0] = $hash_seq{$tmp_prot}[0];
				$hash_ncs2{$tmp_prot}[1] = $tmp_model;
				$hash_ncs2{$tmp_prot}[2] = $tmp_array[6]; #E-value
				$hash_ncs2{$tmp_prot}[3] = $tmp_array[7];  #Score
				$hash_ncs2{$tmp_prot}[4] = $tmp_array[17]; #From
				$hash_ncs2{$tmp_prot}[5] = $tmp_array[18]; #To
			}
		}
	}
	close(FIN);

	########## TRY TO PREDICT IF A HHMER RESULTS FILE IS EMPTY AND STOP THE PROG ###########
	my $empty_hmmer = keys %hash_2a;
	my $empty_ncs2 = keys %hash_ncs2;
	if (($empty_hmmer == 0) || ($empty_ncs2 == 0)){
		open (FOUT_3, "> ./REPORT FINISHED.txt");
		print FOUT_3 "NO RESULTS FOUND\n";
		close(FOUT_3);
		die;
	}
	##############################################


	open(FOUT_NCS2, "> tmp_seq_ncs2.fasta") || die "Failed TMP_FOUT_NCS2\n";
	open(FOUT_GEN, "> 1_GENERAL_REPORT.txt") || die "Failed FOUT\n";
	foreach my $key (keys %hash_ncs2){
		print FOUT_NCS2 ">".$key."\n".$hash_ncs2{$key}[0]."\n";
		print FOUT_GEN $key."\t".$hash_ncs2{$key}[2]."\t".$hash_ncs2{$key}[1]."\t".$hash_ncs2{$key}[0]."\n";
	}
	close(FOUT_NCS2);
	close(FOUT_GEN);
}

sub readNCS2_HMMER {
	open(FOUT_MEME, "> ./2_MEME_REPORT.txt") || die "Failed FOUT MEME\n";
	open(FIN, "< ./HMMDOM_NCS2_2.txt") || die "Failed FIN NCS2 MEMES\n";
	while(my $line = <FIN>){
		chomp($line);
		$line =~ s/\R//g;
		if ($line =~ /^#/){
			next;
		}
		my @tmp_array_hmmer = ();
		@tmp_array_hmmer = split(/\s+/, $line);

			my $target_name = "xxx";
			my $accession = "xxx";
			my $t_length = "xxx";
			my $query_name = "xxx";
			my $accession2 = "xxx";
			my $q_length = "xxx";
			my $e_value = 10000;
			my $score = 0;
			my $bias = 0;
			my $domain_num = 0;
			my $domain_num_of = 0;
			my $c_E_value = 10000;
			my $i_E_value = 10000;
			my $domain_score = 0;
			my $domain_bias = 0;
			my $hmm_from = 10000;
			my $hmm_to = 0;
			my $ali_from = 10000;
			my $ali_to = 0;
			my $env_from = 10000;
			my $env_to = 0;
			my $acc = 0;
			my $descr_of_target = "xxx";

			$target_name = $tmp_array_hmmer[0];
			$accession = $tmp_array_hmmer[1];
			$t_length = $tmp_array_hmmer[2];
			$query_name = $tmp_array_hmmer[3];
			$accession2 = $tmp_array_hmmer[4];
			$q_length = $tmp_array_hmmer[5];
			$e_value = $tmp_array_hmmer[6];
			$score = $tmp_array_hmmer[7];
			$bias = $tmp_array_hmmer[8];
			$domain_num = $tmp_array_hmmer[9];
			$domain_num_of = $tmp_array_hmmer[10];
			$c_E_value = $tmp_array_hmmer[11];
			$i_E_value = $tmp_array_hmmer[12];
			$domain_score = $tmp_array_hmmer[13];
			$domain_bias = $tmp_array_hmmer[14];
			$hmm_from = $tmp_array_hmmer[15];
			$hmm_to = $tmp_array_hmmer[16];
			$ali_from = $tmp_array_hmmer[17];
			$ali_to = $tmp_array_hmmer[18];
			$env_from = $tmp_array_hmmer[19];
			$env_to = $tmp_array_hmmer[20];
			$acc = $tmp_array_hmmer[21];
			$descr_of_target = $tmp_array_hmmer[22];
	################################################################################
			$target_name = $tmp_array_hmmer[0];		# These three variables needed
			$query_name = $tmp_array_hmmer[3];		# to create the stracture
			$domain_num = $tmp_array_hmmer[9];		# for the hash of hashes
			if($i_E_value > 1e-2){
				next;
			}
	################################################################################
			$hash{$query_name}{$target_name}{$domain_num}{ target_name } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ accession } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ t_length } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ query_name } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ accession2 } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ q_length } = "xxx";
			$hash{$query_name}{$target_name}{$domain_num}{ e_value } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ score } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ bias } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_num } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_num_of } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ c_E_value } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ i_E_value } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_score } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_bias } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ hmm_from } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ hmm_to } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ ali_from } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ ali_to } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ env_from } = 10000;
			$hash{$query_name}{$target_name}{$domain_num}{ env_to } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ acc } = 0;
			$hash{$query_name}{$target_name}{$domain_num}{ descr_of_target } = "xxx";
	}
	close(FIN);
	####################################################################################################################
	##################################################END OF INIT#######################################################
	####################################################################################################################
	open(FIN, "< ./HMMDOM_NCS2_2.txt") || die "Failed FIN NCS2 MEMES 2\n";
	while(my $line = <FIN>){
		chomp($line);
		$line =~ s/\R//g;
		if ($line =~ /^#/){
			next;
		}
		my @tmp_array_hmmer = ();
		@tmp_array_hmmer = split(/\s+/, $line);

			my $target_name = "xxx";
			my $accession = "xxx";
			my $t_length = "xxx";
			my $query_name = "xxx";
			my $accession2 = "xxx";
			my $q_length = "xxx";
			my $e_value = 10000;
			my $score = 0;
			my $bias = 0;
			my $domain_num = 0;
			my $domain_num_of = 0;
			my $c_E_value = 10000;
			my $i_E_value = 10000;
			my $domain_score = 0;
			my $domain_bias = 0;
			my $hmm_from = 10000;
			my $hmm_to = 0;
			my $ali_from = 10000;
			my $ali_to = 0;
			my $env_from = 10000;
			my $env_to = 0;
			my $acc = 0;
			my $descr_of_target = "xxx";

			$target_name = $tmp_array_hmmer[0];
			$accession = $tmp_array_hmmer[1];
			$t_length = $tmp_array_hmmer[2];
			$query_name = $tmp_array_hmmer[3];
			$accession2 = $tmp_array_hmmer[4];
			$q_length = $tmp_array_hmmer[5];
			$e_value = $tmp_array_hmmer[6];
			$score = $tmp_array_hmmer[7];
			$bias = $tmp_array_hmmer[8];
			$domain_num = $tmp_array_hmmer[9];
			$domain_num_of = $tmp_array_hmmer[10];
			$c_E_value = $tmp_array_hmmer[11];
			$i_E_value = $tmp_array_hmmer[12];
			$domain_score = $tmp_array_hmmer[13];
			$domain_bias = $tmp_array_hmmer[14];
			$hmm_from = $tmp_array_hmmer[15];
			$hmm_to = $tmp_array_hmmer[16];
			$ali_from = $tmp_array_hmmer[17];
			$ali_to = $tmp_array_hmmer[18];
			$env_from = $tmp_array_hmmer[19];
			$env_to = $tmp_array_hmmer[20];
			$acc = $tmp_array_hmmer[21];
			$descr_of_target = $tmp_array_hmmer[22];

			if($i_E_value > 1e-2){
				next;
			}
			if ($query_name eq "gi|94985140|ref|YP_604504.1|"){
				#print STDOUT $line."\n";
			}
			$hash{$query_name}{$target_name}{$domain_num}{ target_name } = $target_name;
			$hash{$query_name}{$target_name}{$domain_num}{ accession } = $accession;
			$hash{$query_name}{$target_name}{$domain_num}{ t_length } = $t_length;
			$hash{$query_name}{$target_name}{$domain_num}{ query_name } = $query_name;
			$hash{$query_name}{$target_name}{$domain_num}{ accession2 } = $accession2;
			$hash{$query_name}{$target_name}{$domain_num}{ q_length } = $q_length;
			$hash{$query_name}{$target_name}{$domain_num}{ e_value } = $e_value;
			$hash{$query_name}{$target_name}{$domain_num}{ score } = $score;
			$hash{$query_name}{$target_name}{$domain_num}{ bias } = $bias;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_num } = $domain_num;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_num_of } = $domain_num_of;
			$hash{$query_name}{$target_name}{$domain_num}{ c_E_value } = $c_E_value;
			$hash{$query_name}{$target_name}{$domain_num}{ i_E_value } = $i_E_value;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_score } = $domain_score;
			$hash{$query_name}{$target_name}{$domain_num}{ domain_bias } = $domain_bias;
			$hash{$query_name}{$target_name}{$domain_num}{ hmm_from } = $hmm_from;
			$hash{$query_name}{$target_name}{$domain_num}{ hmm_to } = $hmm_to;
			$hash{$query_name}{$target_name}{$domain_num}{ ali_from } = $ali_from;
			$hash{$query_name}{$target_name}{$domain_num}{ ali_to } = $ali_to;
			$hash{$query_name}{$target_name}{$domain_num}{ env_from } = $env_from;
			$hash{$query_name}{$target_name}{$domain_num}{ env_to } = $env_to;
			$hash{$query_name}{$target_name}{$domain_num}{ acc } = $acc;
			$hash{$query_name}{$target_name}{$domain_num}{ descr_of_target } = $descr_of_target;
	}
	close(FIN);

	foreach my $protein (keys %hash){
		chomp($protein);
		my %tmp_hash = ();				#foreach protein we must create a %tmp_hash, which will store
										# every hit for the specific protein. CARE!!! must be empty
		my $y = 0;						# at the beginning for INIT reason, to find dominant motif
		foreach my $model(keys %{ $hash{$protein} }){
			chomp($model);
			foreach my $domain_num(keys %{ $hash{$protein}{$model}}){
				chomp($domain_num);
				$tmp_hash{$y}[0] = "xxx";		#protein
				$tmp_hash{$y}[1] = "xxx";		#model
				$tmp_hash{$y}[2] = 0;		#domain number
				$tmp_hash{$y}[3] = 0;		#domain number
				$tmp_hash{$y}[4] = 10000;		#E-value
				$tmp_hash{$y}[5] = 10000;		#iE-Value
				$tmp_hash{$y}[6] = 0;			#Score
				$tmp_hash{$y}[7] = 10000;		#hmm_from
				$tmp_hash{$y}[8] = 0;			#hmm_to
				$tmp_hash{$y}[9] = 10000;		#ali_from
				$tmp_hash{$y}[10] = 0;			#ali_to
				$tmp_hash{$y}[11] = 0;			#score
				$y++;
			}
		}

		$y = 0; #CARE!!!! we must reinitiallize the $y

		foreach my $model(keys %{ $hash{$protein} }){
			chomp($model);
			foreach my $domain_num(keys %{ $hash{$protein}{$model}}){
				chomp($domain_num);
				$tmp_hash{$y}[0] = $protein;
				$tmp_hash{$y}[1] = $model;
				$tmp_hash{$y}[2] = $domain_num;
				$tmp_hash{$y}[3] = $hash{$protein}{$model}{$domain_num}{ domain_num_of };
				$tmp_hash{$y}[4] = $hash{$protein}{$model}{$domain_num}{ e_value };
				$tmp_hash{$y}[5] = $hash{$protein}{$model}{$domain_num}{ i_E_value };
				$tmp_hash{$y}[6] = $hash{$protein}{$model}{$domain_num}{ domain_score };
				$tmp_hash{$y}[7] = $hash{$protein}{$model}{$domain_num}{ hmm_from };
				$tmp_hash{$y}[8] = $hash{$protein}{$model}{$domain_num}{ hmm_to };
				$tmp_hash{$y}[9] = $hash{$protein}{$model}{$domain_num}{ ali_from };
				$tmp_hash{$y}[10] = $hash{$protein}{$model}{$domain_num}{ ali_to };
				$tmp_hash{$y}[11] = $hash{$protein}{$model}{$domain_num}{ score };;
				$y++;
			}
		}
		my $seq = "xxx";
		my $prot_seq = "xxx";
		$prot_seq = $tmp_hash{"0"}[0];
		$seq = $hash_ncs2{$prot_seq}[0];
		my $prot_length = 0;
		$prot_length = length($seq);
		my @tmp_sort_array = ();			#for every protein @tmp_sort_array must be empty, we will put
		@tmp_sort_array = sort { $tmp_hash{$a}[9] <=> $tmp_hash{$b}[9] } keys %tmp_hash;	#hits in ali_from order
		my @tmp_models_to_keep = ();
		my $number_of_hits = 0;
		$number_of_hits = @tmp_sort_array;
		#print STDOUT $number_of_hits."\n";
		my @general_models = ();
		for(my $i2=0;$i2<$number_of_hits;$i2++){

			my $i = 1000;
			$i = $tmp_sort_array[$i2];
			#print STDOUT $i."\n";

			my $tmp_model_name = "X";
			my $tmp_model_from = 10000;
			my $tmp_model_to = 0;
			my $tmp_model_evalue = 10000;
			my $tmp_model_ievalue = 10000;
			my $tmp_pre_model_from = 10000;
			my $tmp_pre_model_to = 0;
			my $tmp_pre_model_evalue = 10000;
			my $tmp_pre_model_ievalue = 10000;
			my $num_pre_model = 0;

			$num_pre_model = $tmp_models_to_keep[$#tmp_models_to_keep]; #give last value of array

			$tmp_model_name = $tmp_hash{$i}[1];
			$tmp_model_from = $tmp_hash{$i}[9];
			$tmp_model_to = $tmp_hash{$i}[10];
			$tmp_model_evalue = $tmp_hash{$i}[4];
			$tmp_model_ievalue = $tmp_hash{$i}[5];
			if($tmp_model_name =~ /^NCS2_SF\d_GEN_M\d+/){
				push(@general_models, $i);
				#print STDOUT $i."\n";
				next;
			}
			if(@tmp_models_to_keep < 1){
				$tmp_pre_model_from = 10000;
				$tmp_pre_model_to = 0;
				$tmp_pre_model_evalue = 10000;
				$tmp_pre_model_ievalue = 10000;
				} else {
				$tmp_pre_model_from = $tmp_hash{$num_pre_model}[9];
				$tmp_pre_model_to = $tmp_hash{$num_pre_model}[10];
				$tmp_pre_model_evalue = $tmp_hash{$num_pre_model}[4];
				$tmp_pre_model_ievalue = $tmp_hash{$num_pre_model}[5];
			}

			if ($tmp_model_from < $tmp_pre_model_to){
					if($tmp_model_ievalue < $tmp_pre_model_ievalue){
						pop(@tmp_models_to_keep);
						push(@tmp_models_to_keep, $i);
					}
			} else {
				push(@tmp_models_to_keep, $i);
			}

		}
		#print STDOUT @general_models."\n";




		if((@tmp_models_to_keep == 0) && (@general_models > 0)){
			for(my $i2=0;$i2<$number_of_hits;$i2++){

				my $i = 1000;
				$i = $tmp_sort_array[$i2];
				#print STDOUT $i."\n";

				my $tmp_model_name = "X";
				my $tmp_model_from = 10000;
				my $tmp_model_to = 0;
				my $tmp_model_evalue = 10000;
				my $tmp_model_ievalue = 10000;
				my $tmp_pre_model_from = 10000;
				my $tmp_pre_model_to = 0;
				my $tmp_pre_model_evalue = 10000;
				my $tmp_pre_model_ievalue = 10000;
				my $num_pre_model = 0;

				$num_pre_model = $tmp_models_to_keep[$#tmp_models_to_keep]; #give last value of array

				$tmp_model_name = $tmp_hash{$i}[1];
				$tmp_model_from = $tmp_hash{$i}[9];
				$tmp_model_to = $tmp_hash{$i}[10];
				$tmp_model_evalue = $tmp_hash{$i}[4];
				$tmp_model_ievalue = $tmp_hash{$i}[5];
				# if($tmp_model_name =~ /^NCS2_SF\d_GEN_M\d+/){
				# 	push(@general_models, $i);
				# 	#print STDOUT $i."\n";
				# 	next;
				# }
				if(@tmp_models_to_keep < 1){
					$tmp_pre_model_from = 10000;
					$tmp_pre_model_to = 0;
					$tmp_pre_model_evalue = 10000;
					$tmp_pre_model_ievalue = 10000;
					} else {
					$tmp_pre_model_from = $tmp_hash{$num_pre_model}[9];
					$tmp_pre_model_to = $tmp_hash{$num_pre_model}[10];
					$tmp_pre_model_evalue = $tmp_hash{$num_pre_model}[4];
					$tmp_pre_model_ievalue = $tmp_hash{$num_pre_model}[5];
				}

				if ($tmp_model_from < $tmp_pre_model_to){
						if($tmp_model_ievalue < $tmp_pre_model_ievalue){
							pop(@tmp_models_to_keep);
							push(@tmp_models_to_keep, $i);
						}
				} else {
					push(@tmp_models_to_keep, $i);
				}
			}
		} elsif ((@tmp_models_to_keep > 0) && (@general_models > 0)) {
			my @gen_plus_normal_to_keep = ();
			my @tmp_gen_to_keep = ();
			my @gen_to_keep = ();
			my $tmp_i = 0;
			my %clear_motifs_hash = ();
			my @tmp_clear_motifs_array = ();
			for(my$i4=0;$i4<@tmp_models_to_keep;$i4++) {
				my $model_keep = "X";
				my $pre_model_keep = "X";
				my $after_model_keep = "X";
				my $last_i4 = 0;
				my $i4_minus = 0;
				my $i4_plus = 0;
				########### YPARXEI PROBLHMA GIATI EXEI BREI 1 MODELO (kai to apothhkeuei sto array "@tmp_models_to_keep")
				#(H METABLHTH $after_model_keep DEN MPOREI NA PAREI THN EPOMENH TIMH TOY ARRAY GIATI DEN YPARXEI. TO ARRAY EXEI MONO MIA TIMH)
				###AN MPORW NA FTIAKSW ENA IF EDW ANALOGA ME TO MHKOS TOY ARRAY(AN != 1 --> OI MHDENIKES TIMES POU ORISTIKAN PANW NA ALLAKSOUN)
				if (@tmp_models_to_keep != 1){
					$last_i4 = @tmp_models_to_keep;
					$last_i4 = $last_i4 - 1;
					$i4_minus = $i4 - 1;
					$i4_plus = $i4 + 1;
				}
				#######################################################################################################################
				if($i4 == 0){
					$model_keep = $tmp_models_to_keep[$i4];
					$pre_model_keep = "NONE";
					$after_model_keep = $tmp_models_to_keep[$i4_plus];
				}elsif (($i4 > 0) && ($i4 < $last_i4)) {
					$model_keep = $tmp_models_to_keep[$i4];
					$pre_model_keep = $tmp_models_to_keep[$i4_minus];
					$after_model_keep = $tmp_models_to_keep[$i4_plus];
				} elsif ($i4 == $last_i4) {
					$model_keep = $tmp_models_to_keep[$i4];
					$pre_model_keep = $tmp_models_to_keep[$i4_minus];
					$after_model_keep = "NONE";
				}


				if($tmp_i == 0){
					if($tmp_hash{$model_keep}[9] > 1){
						$clear_motifs_hash{$tmp_i}[0] = $model_keep;
						$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
						$clear_motifs_hash{$tmp_i}[2] = 1;
						$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$model_keep}[9] - 1;
						$tmp_i++;
					}
					if($tmp_hash{$model_keep}[9] == 1){
						$clear_motifs_hash{$tmp_i}[0] = $model_keep;
						$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
						$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$model_keep}[10] + 1;
						$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$after_model_keep}[9] - 1;
						$tmp_i++;
					}
					next;
				}
				if(($tmp_i > 0) && ($after_model_keep ne "NONE")){
					##if two models are one next to an other 22-42 and 43-45 then clear motifs coorfs reversed 43 to 42
					if($clear_motifs_hash{"0"}[2] == 1){
						$clear_motifs_hash{$tmp_i}[0] = $model_keep;
						$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
						$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$pre_model_keep}[10] + 1;
						$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$model_keep}[9] - 1;
						$tmp_i++;
					} else {
						$clear_motifs_hash{$tmp_i}[0] = $model_keep;
						$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
						$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$model_keep}[10] + 1;
						$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$after_model_keep}[9] - 1;
						$tmp_i++;
					}
					next;
				}
				if(($tmp_i > 0) && ($after_model_keep eq "NONE")){
					if($clear_motifs_hash{"0"}[2] == 1){
						if($tmp_hash{$model_keep}[3] < $prot_length){
							$clear_motifs_hash{$tmp_i}[0] = $model_keep;
							$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
							$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$pre_model_keep}[10] + 1;
							$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$model_keep}[9] - 1;
							$tmp_i++;
							$clear_motifs_hash{$tmp_i}[0] = $model_keep."_FINAL";
							$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
							$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$model_keep}[10] + 1;
							$clear_motifs_hash{$tmp_i}[3] = $prot_length;
							$tmp_i++;
						} else {
							$clear_motifs_hash{$tmp_i}[0] = $model_keep;
							$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
							$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$pre_model_keep}[10] + 1;
							$clear_motifs_hash{$tmp_i}[3] = $tmp_hash{$model_keep}[9] - 1;
							$tmp_i++;
						}
					} elsif($clear_motifs_hash{"0"}[2] != 1) {
						if($tmp_hash{$model_keep}[3] < $prot_length){
							$clear_motifs_hash{$tmp_i}[0] = $model_keep;
							$clear_motifs_hash{$tmp_i}[1] = $tmp_hash{$model_keep}[0];
							$clear_motifs_hash{$tmp_i}[2] = $tmp_hash{$model_keep}[10] + 1;
							$clear_motifs_hash{$tmp_i}[3] = $prot_length;
							$tmp_i++;
						}
					}
					next;
				}
			}
			       #######         #########      ######      #####   ######    #############    ############      .	8	7
			       #######         #########      ######      #####   ######    #############    ############			7	7
			#######         #########      ######      #####   ######    #############    ############       			7	7
			#######         #########      ######      #####   ######    #############    ############					6	7


			##########3CREATE CLEAR MOTIFS############################
			##########################################################
			#print STDOUT $protein."\n";
			my @clear_motifs_array = ();
			@clear_motifs_array = keys %clear_motifs_hash;
			# foreach my $key(@clear_motifs_array){
			# 	print STDOUT $key."\t".$clear_motifs_hash{$key}[2]."\t".$clear_motifs_hash{$key}[3]."\n";
			# }

			my %tmp_gen_order_hash = ();
			foreach my $tmp_gen_model(@general_models){
				chomp($tmp_gen_model);
				#print STDOUT $tmp_gen_model."\t".$protein."\n";
				my $tmp_from = 10000;
				my $tmp_to = 0;
				$tmp_from = $tmp_hash{$tmp_gen_model}[9];
				$tmp_to = $tmp_hash{$tmp_gen_model}[10];
				my $pass = 0;
				for(my$i3=0;$i3<@clear_motifs_array;$i3++){
					if(($tmp_from >= $clear_motifs_hash{$i3}[2]) && ($tmp_to <= $clear_motifs_hash{$i3}[3])){
						$pass = 1;
					}
				}
				if($pass == 1){
					push(@tmp_gen_to_keep, $tmp_gen_model);
					$tmp_gen_order_hash{$tmp_gen_model}[0] = $tmp_from;
					#print STDOUT "nice\t".$protein."\n";
				}
			}
			my @sort_array_tmp_general = ();
			@sort_array_tmp_general = sort { $tmp_gen_order_hash{$a}[0] <=> $tmp_gen_order_hash{$b}[0] } keys %tmp_gen_order_hash;
			foreach my $tmp_gen_model(@sort_array_tmp_general){

				for(my $i2=0;$i2<@sort_array_tmp_general;$i2++){

					my $i = 1000;
					$i = $tmp_gen_model;
					#print STDOUT $i."\n";

					my $tmp_model_name = "X";
					my $tmp_model_from = 10000;
					my $tmp_model_to = 0;
					my $tmp_model_evalue = 10000;
					my $tmp_model_ievalue = 10000;
					my $tmp_pre_model_from = 10000;
					my $tmp_pre_model_to = 0;
					my $tmp_pre_model_evalue = 10000;
					my $tmp_pre_model_ievalue = 10000;
					my $num_pre_model = 0;

					$num_pre_model = $gen_to_keep[$#gen_to_keep]; #give last value of array

					$tmp_model_name = $tmp_hash{$i}[1];
					$tmp_model_from = $tmp_hash{$i}[9];
					$tmp_model_to = $tmp_hash{$i}[10];
					$tmp_model_evalue = $tmp_hash{$i}[4];
					$tmp_model_ievalue = $tmp_hash{$i}[5];
					# if($tmp_model_name =~ /^NCS2_SF\d_GEN_M\d+/){
					# 	push(@general_models, $i);
					# 	#print STDOUT $i."\n";
					# 	next;
					# }
					if(@gen_to_keep < 1){
						$tmp_pre_model_from = 10000;
						$tmp_pre_model_to = 0;
						$tmp_pre_model_evalue = 10000;
						$tmp_pre_model_ievalue = 10000;
						} else {
						$tmp_pre_model_from = $tmp_hash{$num_pre_model}[9];
						$tmp_pre_model_to = $tmp_hash{$num_pre_model}[10];
						$tmp_pre_model_evalue = $tmp_hash{$num_pre_model}[4];
						$tmp_pre_model_ievalue = $tmp_hash{$num_pre_model}[5];
					}

					if ($tmp_model_from < $tmp_pre_model_to){
							if($tmp_model_ievalue < $tmp_pre_model_ievalue){
								pop(@gen_to_keep);
								push(@gen_to_keep, $i);
							}
					} else {
						push(@gen_to_keep, $i);
					}
				}
			}
			push(@tmp_models_to_keep, @gen_to_keep);
			#%tmp_for_gen_models = ();
		}
		my %hash_order_normal_gen_models_final = ();
		foreach my $normal_gen_model(@tmp_models_to_keep){
			$hash_order_normal_gen_models_final{$normal_gen_model}[0] = $tmp_hash{$normal_gen_model}[9];
		}
		my @sort_order_normal_gen = ();
		@sort_order_normal_gen = sort { $hash_order_normal_gen_models_final{$a}[0] <=> $hash_order_normal_gen_models_final{$b}[0] } keys %hash_order_normal_gen_models_final;
		@tmp_models_to_keep = @sort_order_normal_gen;
		@sort_order_normal_gen = ();
		%hash_order_normal_gen_models_final = ();

		my $order_number = 0;
		foreach my $model_keep(@tmp_models_to_keep){
			$order_number++;
			#print FOUT_MEME $tmp_hash{$model_keep}[0]."\t".$tmp_hash{$model_keep}[1]."\t".$order_number."\t".$tmp_hash{$model_keep}[2]."\t".$tmp_hash{$model_keep}[3]."\t".$tmp_hash{$model_keep}[4]."\t".$tmp_hash{$model_keep}[5]."\t".$tmp_hash{$model_keep}[11]."\t".$tmp_hash{$model_keep}[6]."\t".$tmp_hash{$model_keep}[7]."\t".$tmp_hash{$model_keep}[8]."\t".$tmp_hash{$model_keep}[9]."\t".$tmp_hash{$model_keep}[10]."\n";
			print FOUT_MEME $tmp_hash{$model_keep}[0]."\t".$tmp_hash{$model_keep}[1]."\t".$order_number."\t".$tmp_hash{$model_keep}[5]."\t".$tmp_hash{$model_keep}[9]."\t".$tmp_hash{$model_keep}[10]."\n";
		}
	}
	close(FOUT_MEME);
}
