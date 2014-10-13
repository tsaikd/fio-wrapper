
$ouputrows=0;
$DEBUG=0;
$CLAT=0;
$fillzero=0;

if ( 1 == $DEBUG ) { $debug=1; }

foreach $argnum (0 .. $#ARGV) {
    ${$ARGV[$argnum]}=1;
}
print "continuting ... \n" if defined ($debug);

# these are all the possible buckets for fio histograms:
@buckets_fio=("2", "4","10","20","50","100","250","500","750","1000","2000","4000","10000","20000","50000","100000","250000","500000","750000","1000000","2000000","20000000");

# translation of fio buckets into labels
$buckett{2}="2us";
$buckett{4}="4us";
$buckett{10}="10us";
$buckett{20}="20us";
$buckett{50}="50us";
$buckett{100}=".1ms";
$buckett{250}=".25ms";
$buckett{500}=".5ms";
$buckett{750}=".75ms";
$buckett{1000}="1ms";
$buckett{2000}="2ms";
$buckett{4000}="4ms";
$buckett{10000}="10ms";
$buckett{20000}="20ms";
$buckett{50000}="50ms";
$buckett{100000}=".1s";
$buckett{250000}=".25ms";
$buckett{500000}=".5s";
$buckett{750000}=".75s";
$buckett{1000000}="1s";
$buckett{2000000}="2s";
$buckett{20000000}="2s+";

$bucketr{2}="us2";
$bucketr{4}="us4";
$bucketr{10}="us10";
$bucketr{20}="us20";
$bucketr{50}="us50";
$bucketr{100}="us100";
$bucketr{250}="us250";
$bucketr{500}="us500";
$bucketr{750}="us750";
$bucketr{1000}="ms1";
$bucketr{2000}="ms2";
$bucketr{4000}="ms4";
$bucketr{10000}="ms10";
$bucketr{20000}="ms20";
$bucketr{50000}="ms50";
$bucketr{100000}="ms100";
$bucketr{250000}="ms250";
$bucketr{500000}="ms500";
$bucketr{750000}="ms750";
$bucketr{1000000}="s1";
$bucketr{2000000}="s2";
$bucketr{20000000}="s2g";

@output_buckets=("50","1000","4000","10000","20000","50000","100000","1000000","2000000","20000000");
@rbuckets_fio=("2","4","10", "20", "50", "100","250","500","1000","2000","4000","10000","20000","50000","100000","250000","500000","1000000","2000000","20000000");
@percentiles_header=("95%", "99%", "99.5%", "99.9%", "99.95%", "99.99%");
# clat of interest
@clat_class = ("95.00", "99.00", "99.50", "99.90", "99.95", "99.99");

sub hist_head {
    printf("%8s", "test");
    printf("%6s", "users");
    printf("%5s", "size");
    printf("%9s",  "MB/s ");
    printf("%10s", "lat(ms)");
    printf("%10s", "min  ");
    printf("%10s", "max  ");
    printf("%10s", "std  ");
    printf("%7s", "IO/s");
    if($verbose == 1) {
        foreach my $time (@output_buckets) {
            if ( $time > $higbucket ) {
                printf(" %5s",$buckett{$time});
            }
        }
    }
    if($percentiles == 1) {
        foreach my $percentile (@percentiles_header) {
            printf(" %8s",$percentile);
        }
    }
    printf("\n");
}

sub rplots_footer {
    if($labels != 1) {
        $nrow = $percentiles == 1? 31 : 25;
        printf("),nrow=%d)\n", $nrow);
        printf("tm <- t(m)\n");
        printf("m <-tm\n");
        printf("colnames <- c(\"name\",\"users\",\"bs\",\"MB\",\"lat\",\"min\",\"max\",\"std\",\"iops\"\n");
        printf(", \"us50\",\"us100\",\"us250\",\"us500\",\"ms1\",\"ms2\",\"ms4\",\"ms10\",\"ms20\"\n");
        printf(", \"ms50\",\"ms100\",\"ms250\",\"ms500\",\"s1\",\"s2\",\"s5\"\n");
        if ( $percentiles == 1 ) {
            printf(",\"p95_00\", \"p99_00\", \"p99_50\", \"p99_90\", \"p99_95\", \"p99_99\"\n");
        }
        printf(")\n");
        printf("colnames(m)=colnames\n");
        printf("m <- data.frame(m)\n");
    }
}

sub print_hist {
    $mybucket=0;
    # for all possible fo buckets, @buckets_fio is all known fio histogram buckets
    if ( $rplot_hist == 1 ) {
        foreach $curbucket (@rbuckets_fio) {
            $label="";
            if ($curbucket eq "2" ) {
                if ( $labels == 1 ) {
                    $label=$bucketr{"50"}."=";
                }
                printf(",%s%2d",$label, int(${$hist_type}{"2"})||0 + int(${$hist_type}{"4"})||0 + int(${$hist_type}{"10"})||0 + int(${$hist_type}{"20"})||0 + int(${$hist_type}{"50"})||0 );
                delete ${$hist_type}{"2"};
                delete ${$hist_type}{"4"};
                delete ${$hist_type}{"10"};
                delete ${$hist_type}{"20"};
                delete ${$hist_type}{"50"};
            }
            # merge 750 and 1000 bucket
            elsif ( $curbucket eq "1000" || $curbucket eq "750" ) {
                if ( $labels == 1 ) {
                    $label=$bucketr{"1000"}."=";
                }
                printf(",%s%2d",$label, int(${$hist_type}{"1000"})||0 + int(${$hist_type}{"750"})||0 );
                delete ${$hist_type}{"750"};
                delete ${$hist_type}{"1000"};
            }
            # merge 750000 and 1000000 bucket
            elsif ( $curbucket eq "1000000" || $curbucket eq "750000" ) {
                if ( $labels == 1 ) { $label=$bucketr{"1000000"}."="; }
                printf(",%s%2d",$label, int(${$hist_type}{"1000000"})||0+ int(${$hist_type}{"750000"})||0 );
                delete ${$hist_type}{"1000000"};
                delete ${$hist_type}{"750000"};
            }
            # the "20000000" bucket is just a tag for > 2s, so lets call it 5s for graphing purposes
            elsif ( $curbucket eq "20000000" ) {
                if ( $labels == 1 ) { $label="s5="; }
                printf(",%s%2d",$label, int(${$hist_type}{$curbucket})||0 );
            }
            elsif (defined ${$hist_type}{$curbucket}) {
                $value = int(${$hist_type}{$curbucket})||0;
                if ( $labels == 1 ) { $label=$bucketr{$curbucket}."="; }
                printf(",%s%2d",$label, $value);   
            }
            delete ${$hist_type}{$curbucket};
        }
    }
    else {
        foreach $curbucket (@{$bucket_list}) {
            # output_buckets => the list of buckets to actually output
            # bucket_list => buckets possible for this data (fio or dtrace)
            # curbucket => is this bucket less the bucket to output? if so add it to
            # if the current bucket from curbucket is smaller then our the planed output bucket
            # but larger than the last output bucket, then summ it up
            # ie if the first output bucket at 1ms, sum up all buckets from 4us to 1ms
            # if the next output bucket is 1s, them sum up all bucets from 1ms+ to 1s
            if ( $curbucket <= $output_buckets[$mybucket] ) {
                # bucket values from fio are in $lat[key]
                # bucket values from dtrace are in $dtrace_lat[key]
                $bucketu{$output_buckets[$mybucket]}+=${$hist_type}{$curbucket};
            }
            else {
                $bucketu{$output_buckets[$mybucket+1]}+=${$hist_type}{$curbucket};
            }
            delete ${$hist_type}{$curbucket};
            # if we reach our output bucket time, then go to the next bucket in all buckets
            if ( $curbucket >= $output_buckets[$mybucket] ) {
                $mybucket++;
            }
        }
        # now that weve summed up the fine grain buckets in all buckets into
        # the desired courser grain buckets, print out the course grain bucket values
        foreach $tu (@output_buckets) {
            if ( $bucketu{$tu} > 0 ) {
                printf(" %5s",int( 100*($bucketu{$tu}/$iop) ) );
            }
            else {
                if ( $fillzero ) {
                    printf(" %5s","0");
                }
                else {
                    printf(" %5s","");
                }
            }
            $bucketu{$tu}=0;
        }
    }
}

sub flush_stat_line_simple {
    printf("%8s", $benchmark);
    printf("%6s", $users);
    printf("%5s", $bs);
    if ( $iops{$type} > 0 ) {
        printf(" %8.3f", $throughput{$type}/1048576);
        printf(" %9.3f", $lat{$type}/1000);

        printf(" %9.3f", $latmin{$type}/1000);
        printf(" %9.3f", $latmax{$type}/1000);
        printf(" %9.2f", $latstd{$type}/1000);

        printf(" %6s", $iops{$type});
    }
    else {
        printf("%27s ", "");
    }
    if ( $verbose == 1 ) {
        $iop=100;
        $hist_type="lat";
        $bucket_list= "buckets_fio";
        print_hist;
    }

    if ( $percentiles == 1 ) {
        foreach $percent ( @clat_class ) {
            $value = $clat{$type}{$percent};
            printf(" %8.3f",$value*$clat_mult);
        }
    }

    printf("\n");

    $users="";
    $benchmark="";
    foreach $type ( keys %iops ) {
        delete $throughput{$type};
        delete $lat{$type};
        delete $iops{$type};
    }
    $type="";
    $benchmark="";
    $users="";
    $bs="";
}

sub flush_stat_line_rplots {
    if ($users > 0 ) {
        if ( $outputrows > 0 ) {
            if ( $labels == 1 ) {
                printf("m <- rbind(m,data.frame(");
            }
            else {
                printf(",");
            }
        }
        else {
            printf("m <- NULL \n");
            if ( $labels == 1 ) {
                printf("m <- data.frame(");
            }
            else {
                printf("m <- matrix(c(\n");
            }
        }
        $label="";
        if ( $labels == 1 ) { $label="name=";}
        printf("%s%10s,", $label, "\"" . $benchmark . "\"") ;
        if ( $labels == 1 ) { $label="users=";}
        printf("%s%3s,", $label, $users);
        if ( $labels == 1 ) { $label="bs=";}
        printf("%s%6s,", $label, "\"" . $bs . "\"") ;
        if ( $labels == 1 ) { $label="MB=";}
        printf("%s%8.3f,", $label, $throughput{$type}/1048576);
        if ( $labels == 1 ) { $label="lat=";}
        printf("%s%9.3f,", $label, $lat{$type}/1000);
        if ( $labels == 1 ) { $label="min=";}
        printf("%s%4.1f,", $label, $latmin{$type}/1000);
        if ( $labels == 1 ) { $label="max=";}
        printf("%s%9d,", $label, $latmax{$type}/1000);
        if ( $labels == 1 ) { $label="std=";}
        printf("%s%7.1f,", $label, $latstd{$type}/1000);
        if ( $labels == 1 ) { $label="iops=";}
        printf("%s%5s", $label, $iops{$type});
        $iop=100;
        $hist_type="lat";
        $bucket_list= "buckets_fio";
        $rplot_hist = 1;
        print_hist;
        $rplot_hist = 0;
        if ( $percentiles == 1 ) {
            foreach $percent ( @clat_class ) {
                $value = $clat{$type}{$percent};
                if($labels == 1) {
                    $label = $percent;
                    $label =~ s/\./_/;
                    $label = "p".$label."=";
                }
                else {
                    $label="";
                }
                printf(",%s%5.3f",$label,$value*$clat_mult);
            }
        }
        if ( $outputrows > 0 && $labels == 1 ) { printf(")"); }
        if ( $labels == 1 ) { printf(")"); }
        printf("\n");
        $outputrows++;
    }
}

sub flush_stat_line {
    if ( $benchmark eq "write" ) {
        $type="write" ;
        $dtype="W" ;
    }
    else {
        $type="read" ;
        $dtype="R" ;
    }

    if ( $rplots == 0 ) {
        flush_stat_line_simple
    }
    elsif( $rplots == 1 ) {
        flush_stat_line_rplots
    }
}

sub parse_line {
    my ($line) = @_;
    chomp($line);
    printf("line: %s\n", $line) if defined ($debug);
    #filename=
    if ( $line =~ m/^filename=/ ) {
        $dir=$line;
        $dir =~ s/filename=//;
        $dir =~ s/\/.*//;
        
        # prepare an empty latency array
        foreach $curbucket (@rbuckets_fio) {
            $lat{$curbucket}=0;
        }
    }
    #job: (g=0): rw=randread, bs=8K-8K/8K-8K, ioengine=psync, iodepth=2
    elsif ( $line =~ m/ ioengine=/ ) {
        $bs=$benchmark=$line;
        $benchmark =~ s/.* rw=//;
        $benchmark =~ s/,.*//;
        $bs =~ s/.* bs=//;
        $bs =~ s/-.*//;        
    }
    # read : io=48216KB, bw=822173 B/s, iops=100 , runt= 60052msec
    # get iops and set type for later usage
    elsif ( $line =~ m/ bw=/ ) {
        $type=$iops =$line;
        $type =~ s/[ ]*:.*//;
        $type =~ s/[ ]*//;
        $iops =~ s/.*iops=//;
        $iops =~ s/ ?, .*//;
        $iops{$type}=$iops;
    }
    # lat (usec): min=7 , max=1305.5K, avg=61053.50, stdev=73135.80
    elsif ( $line =~ m/ lat .* stdev=/ ) { # filter out histogram lines that have "lat"
        $lat=$unit=$latmin=$latmax=$latstd=$line;
        $lat =~ s/.*avg=//;
        $lat =~ s/,.*//;
        $latmin =~ s/.*min=//;
        $latmin =~ s/ *,.*//;
        $latmax =~ s/.*max=//;
        $latmax =~ s/ *,.*//;
        $latstd =~ s/.*stdev=//;
        $latstd =~ s/ *//;

        $unit =~ s/.*\(//;
        $unit =~ s/\).*//;
        $unit =~ s/msec/1000/;
        $unit =~ s/usec/1/;

        foreach $var ( "latmin" , "latmax" , "laststd" ) {
            if ( ${$var} =~ m/K/ ) {
                ${$var} =~ s/K//;
                ${$var} = ${$var} *1000;
            }
        }

        $latmin{$type}=$latmin*$unit;
        $latmax{$type}=$latmax*$unit;
        $latstd{$type}=$latstd*$unit;

        $lat{$type}=$lat*$unit;
        $unit{$type}=$unit;
    }
    #Starting 1 process
    elsif ( $line =~ m/^Starting / ) {
        $users=$line;
        $users =~ s/Starting //;
        $users =~ s/ process.*//;
        $users =~ s/ thread.*//;
    }
    # lat (usec): 4=97.56%, 10=1.10%, 20=0.09%, 50=0.03%, 100=0.01%
    # lat (usec): 250=0.01%, 500=0.01%, 750=0.01%
    # lat (msec): 4=0.01%, 10=0.50%, 20=0.64%, 50=0.04%, 100=0.01%
    # lat (msec): 250=0.01%
    # lat (msec): 4=6.20%, 10=15.29%, 20=42.56%, 50=30.58%, 100=2.89%
    # lat (msec): 250=0.41%, 750=0.41%, 1000=0.83%, 2000=0.41%, >=2000=0.41%

    # 2 4 10 20 50 100 250 500 750 1000 2000 4000 10000 20000 50000
    # 100000 250000 500000 750000 1000000 2000000 2000000+
    elsif ( $line =~ m/ lat / ) {
        if ( $line =~ m/%/ ) {
            $units=$lats=$line;
            $units =~ s/.*\(//;
            $units =~ s/\).*//;
            $units =~ s/msec/1000/;
            $units =~ s/usec/1/;
            $lats =~ s/.*://;
            $lats =~ s/%//g;
            $lats =~ s/>=/Z/g;
            @lats = split(",", $lats);
            foreach $lat (@lats) {
                ($key,$val) = split("=", $lat);
                if ( $key =~ m/Z/ ) {
                    $key=20000000;
                    $extra="+";
                }
                else {
                    $key=$key*$units;
                    $extra="";
                }
                $lat{$key}=$val;
            }
        }
    }
    # clat percentiles (usec):
    elsif ( $line =~ m/clat percentiles / ) {
        $CLAT=1 ;
        
        $clat_unit=$line ;
        $clat_unit =~ s/.*\(//;
        $clat_unit =~ s/\).*//;
        if ( $clat_unit eq "usec" ) {
            $clat_mult = .001 ;
        }
        elsif ( $clat_unit eq "msec" ) {
            $clat_mult = 1;
        }
        elsif ( $clat_unit eq "sec" ) {
            $clat_mult = 1000;
        }
        else {
            printf("clat unit :%s: unknown\n",$clat_unit);
            printf("exiting \n");
            exit;
        }
    }
    # | 1.00th=[ 179], 5.00th=[ 185], 10.00th=[ 191], 20.00th=[ 195],
    # | 30.00th=[ 199], 40.00th=[ 201], 50.00th=[ 203], 60.00th=[ 207],
    # | 70.00th=[ 215], 80.00th=[ 219], 90.00th=[ 229], 95.00th=[ 266],
    # | 99.00th=[ 398], 99.50th=[ 474], 99.90th=[ 532], 99.95th=[ 796],
    # | 99.99th=[ 1352]
    # bw (KB/s) : min=33040, max=38352, per=100.00%, avg=36799.16, stdev=1312.23
    elsif ( $CLAT == 1 ) {
        if ( $line =~ m/\|/ ) {
            my $parse = $line;
            while ( $parse =~ m/([\d\.]+)th=\[\s*(\d+)\](.*)/ ) {
                $clat{$type}{$1}=$2;
                $parse = $3;
            }
            if ( $line =~ m/95.00th/ ) {
                $clat95_00 = $line;
                $clat95_00 =~ s/.*95.00th=\[//;
                $clat95_00 =~ s/\],.*//;
                $clat95_00 =~ s/ //g;
            }
            if ( $line =~ m/99.00th/ ) {
                $line =~ s/99\...th.*?=\[//g;
                $line =~ s/\|//g;
                $line =~ s/\]//g;
                $line =~ s/ //g;
                ($clat99_00, $clat99_50, $clat99_90, , $clat99_95 )=split(",",$line);
            }
            if ( $line =~ m/99.99th/ ) {
                $clat99_99 = $line;
                $clat99_99 =~ s/.*99.99th=\[//;
                $clat99_99 =~ s/\].*//;
                $clat99_99 =~ s/ //g;
            }
        }
        else {
            $CLAT = 0;
        }
    }
    # READ: io=48216KB, aggrb=802KB/s, minb=822KB/s, maxb=822KB/s, mint=60052msec, maxt=60052msec
    # WRITE: io=12256KB, aggrb=204KB/s, minb=208KB/s, maxb=208KB/s, mint=60052msec, maxt=60052msec
    elsif ( $line =~ m/ aggrb=/ ) {
        $type=$throughput=$line;
        $type =~ s/:.*//;
        $type =~ s/[ ][ ]*//;
        # lower case:
        $type = lc( $type);
        $throughput =~ s/.*aggrb=//;
        $throughput =~ s/,.*//;
        printf("throughput:%s:\n",$throughput) if defined ($debug);
        $factor = $throughput;
        $factor =~ s/.*MB.s/1048576/;
        $factor =~ s/.*KB.s/1024/;
        $factor =~ s/.*B.s/1/;
        $throughput =~ s/MB.s//;
        $throughput =~ s/KB.s//;
        $throughput =~ s/B.s//;
        printf("throughput:%s: factor:%s:\n",$throughput,$factor) if defined ($debug);
        $throughput{$type}=$throughput*$factor;
    }
    # END
    elsif ($line =~ m/END/) {
        flush_stat_line
    }
    
}

$| = 1;

hist_head if ($rplots == 0);

while (my $line = <STDIN>) {
    parse_line($line);
}

rplots_footer if ($rplots == 1)
