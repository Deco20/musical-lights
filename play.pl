#!/usr/bin/perl
use warnings;
use strict;
use English;
use Term::ReadKey;

#
$SIG{CHLD} = 'IGNORE';

#define name of processes we are interested in gathering data
my $p1 = "lightorgan"; #PROBABLY NEEDS CHANGING
my $p2 = "timidity"; #PROBABLY NEEDS CHANGING

#define lists to store relevant data
my $p1_id;          #[1]
my @p1_cpu;         #[2] 
my @p1_mem;         #[3]
my $p1_time;        #[9]
my $p2_id;          #[1]
my @p2_cpu;         #[2]
my @p2_mem;         #[3]
my $p2_time;        #[9]

#interval to wait for user input
my $interval = 1;

#ps output format
#USER    PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND 

my$key;
ReadMode 4; # Turn off control keys

#quit subroutine
sub quit()
{
    
     #Calculate averages

    #Average Cpu usage percentage
    #p1
    my $sum_p1_cpu = my $avg_p1_cpu= 0;
    $sum_p1_cpu += $_ for @p1_cpu;
    my $len_p1_cpu = @p1_cpu;
     if ($len_p1_cpu == 0) {       
      #  system("./cleanup.py");
        kill 9,$_[0];
       exit;
     }
    $avg_p1_cpu = $sum_p1_cpu / $len_p1_cpu;




    #p2
    my $sum_p2_cpu = my $avg_p2_cpu= 0;
    $sum_p2_cpu += $_ for @p2_cpu;
    my $len_p2_cpu = @p2_cpu;
     if ($len_p2_cpu == 0) {
        system("./cleanup.py");
        kill 9,$_[0];
        exit;
     }
    $avg_p2_cpu = $sum_p2_cpu / $len_p2_cpu;
    

    #Average memory usage percentage
    #p1
    my $sum_p1_mem = my $avg_p1_mem= 0;
    $sum_p1_mem += $_ for @p1_mem;
    my $len_p1_mem = @p1_mem;
    $avg_p1_mem = $sum_p1_mem / $len_p1_mem;
    
    
    #p2
    my $sum_p2_mem = my $avg_p2_mem= 0;
    $sum_p2_mem += $_ for @p2_mem;
    my $len_p2_mem = @p2_mem;
    $avg_p2_mem = $sum_p2_mem / $len_p2_mem;
    
    system("./cleanup.py");
    kill 9,$_[0];
    exit;
    
    
            
 }



die "could not fork: $!" unless defined (my $first_pid = fork);

#first child
if ((my $len = @ARGV) > 0) {
    exec ("./".$p1." ".$ARGV[0]) unless $first_pid;   
}
else{
        exec ("./".$p1." ") unless $first_pid;   
   
}


   


while ( ( (my $ps = `ps aux `) =~ (/$p1/) )  && (!defined( $key = ReadKey(-1) ) ) )
{

   
    
    #Execute OS command ps and process each line separately
    open(PS, "ps aux |"); 

    while (my $line  = <PS>) # process the output of ps command one line at a time
    {

            # For Process 1
            if ( $line =~ /$p1/) {
                my @matched =  split(" ",$line);
                $p1_id = $matched[1];
                push(@p1_cpu,$matched[2]);
                push(@p1_mem,$matched[3]);
                $p1_time = $matched[9];
                
        
            }
    
            # For Process 2    
              if ( $line =~ /$p2/)  {
                my @matched =  split(" ",$line);
                $p2_id = $matched[1];
                push(@p2_cpu,$matched[2]);
                push(@p2_mem,$matched[3]);
                $p2_time = $matched[9];
            }       
    }
    while ( $interval > time() ) {
        if (<STDIN> eq "x") {
           &quit($p1_id);
        }   
    }
    
    
close(PS);  
}
ReadMode 0;
&quit($p1_id);





