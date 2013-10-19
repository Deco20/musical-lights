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







$sum_p1_mem += $_ for @p1_mem;
my $len_p1_mem = @p1_mem;
$avg_p1_mem = $sum_p1_mem / $len_p1_mem;   

#For process 2 "timidity"
my $sum_p2_mem = my $avg_p2_mem = 0;
$sum_p2_mem += $_ for @p2_mem;
my $len_p2_mem = @p2_mem;
$avg_p2_mem = $sum_p2_mem / $len_p2_mem;

#For process 3 "aplaymidi"
my $sum_p3_mem = my $avg_p3_mem = 0;
$sum_p3_mem += $_ for @p3_mem;
my $len_p3_mem = @p3_mem;
$avg_p3_mem = $sum_p3_mem / $len_p3_mem;   

#display test results to user
print("Final Percentage Averages\n");
print("-------------------------\n\n");
printf("%-11s %-5s %-8s %-8s %-10s\n", 'Process', 'PID', 'CPU %', 'MEM %', 'CPU Time');
printf("----------- ----- -------- -------- ----------\n");
printf("%-11s %5d %8.2f %8.2f %10s\n", $p1, $p1_id, $avg_p1_cpu, $avg_p1_mem, $p1_time);
printf("%-11s %5d %8.2f %8.2f %10s\n", $p2, $p2_id, $avg_p2_cpu, $avg_p2_mem, $p2_time);
printf("%-11s %5d %8.2f %8.2f %10s\n\n", $p3, $p3_id, $avg_p3_cpu, $avg_p3_mem, $p3_time);

#Kill aplaymidi if it is still running due to early exit from user
if(my $aplaymidiID = `pidof $p3` eq ($p3_id))
{
   system("sudo kill $p3_id");
}

`sudo renice 0 -p $p2_id`;
ReadMode 0;
exit;        
   

#For process 2 "timidity"
my $sum_p2_mem = my $avg_p2_mem = 0;
$sum_p2_mem += ($_ - $p2_mem_deduction) for @p2_mem;
my $len_p2_mem = @p2_mem;
$avg_p2_mem = $sum_p2_mem / $len_p2_mem;

#For process 3 "aplaymidi"
my $sum_p3_mem = my $avg_p3_mem = 0;
$sum_p3_mem += $_ for @p3_mem;
my $len_p3_mem = @p3_mem;
$avg_p3_mem = $sum_p3_mem / $len_p3_mem; 

#For process 4 "perl play.pl"
my $sum_p4_mem = my $avg_p4_mem = 0;
$sum_p4_mem += $_ for @p4_mem;
my $len_p4_mem = @p4_mem;
$avg_p4_mem = $sum_p4_mem / $len_p4_mem;  


#Total CPU time for daemon processes
$p1_time = (&convertTime($p1_time) - $p1_time_deduction);
$p2_time = (&convertTime($p2_time) - $p2_time_deduction);


#display test results to user
print("Final Percentage Averages\n");
print("-------------------------\n\n");
printf("%-13s %-5s %-8s %-8s %-12s\n", 'Process', 'PID', 'CPU %', 'MEM %', 'CPU Time (s)');
printf("------------- ----- -------- -------- ------------\n");
printf("%-13s %5d %8.2f %8.2f %12s\n", $p1, $p1_id, $avg_p1_cpu, $avg_p1_mem, $p1_time);
printf("%-13s %5d %8.2f %8.2f %12s\n", $p2, $p2_id, $avg_p2_cpu, $avg_p2_mem, $p2_time);
printf("%-13s %5d %8.2f %8.2f %12s\n", $p3, $p3_id, $avg_p3_cpu, $avg_p3_mem, &convertTime($p3_time));
printf("%-13s %5d %8.2f %8.2f %12s\n\n", $p4, $p4_id, $avg_p4_cpu, $avg_p4_mem, &convertTime($p4_time));

#Write CPU usage arrays to txt files
&toFile($p1, @p1_cpu);
&toFile($p2, @p2_cpu);
&toFile($p3, @p3_cpu);
&toFile($p4, @p4_cpu);

`sudo renice 0 -p $p2_id`;
ReadMode 0;
exit;

#Subroutine to Write an array out to an appropriately named file
sub toFile
{
   my $name = shift."_cpu.txt";
   my @data = @_;
   my $index = 1;

   open FH, ">$name" or
   die "Cannot open '$name'";
   
   foreach(@data)
   {
      
      printf FH ($index * $interval)."\t$_";
      $index++;
   }

   close FH;
}

# subroutine to convert CPU time to seconds.
sub convertTime
{
   my $timeIn = $_[0];
   my @time = split /:/ ,$timeIn;
   my $timeSec = 0;
   $timeSec += ($time[0] * 3600);
   $timeSec += ($time[1] * 60);
   $timeSec += $time[2];

   return $timeSec;
}

