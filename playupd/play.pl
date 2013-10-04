#!/usr/bin/perl
use warnings;
use strict;
use English;
use Term::ReadKey;

#define name of processes we are interested in gathering data
my $p1 = "lightorgan"; 
my $p2 = "timidity"; 
my $p3 = "aplaymidi";

#define lists and scalars to store relevant data
my $p1_id = qx(pidof $p1);          
my @p1_cpu;                          
my @p1_mem;                         
my $p1_time;
my $p2_id = qx(pidof $p2);          
my @p2_cpu;                         
my @p2_mem;                         
my $p2_time;
my $p3_id; 
my @p3_cpu;                         
my @p3_mem;                         
my $p3_time;            

#Change priority on timidity process to allow more CPU time
`sudo renice -10 -p $p2_id`;
#system("/etc/init.d/timidity restart");
#sleep 5;

#interval to wait for user input
my $interval = 0.1;

#variable to hold user input
my$key;
ReadMode 4; # Turn off control keys

#Start playing selected midi and display to user
if ((my $len = @ARGV) > 0)
{
   print("Processes Running\n");
   print("-----------------\n\n");
   printf("%-11s %5d\n", 'timidity', $p2_id);
   printf("%-11s %5d\n", 'lightorgan', $p1_id);
   system("aplaymidi --port 14 $ARGV[0] &");
   $p3_id = qx(pidof aplaymidi);
   printf("%-11s %5d\n\n\n", 'aplaymidi', $p3_id);
}
else
{
   print("No command line argument supplied\n");
   ReadMode 0;
   exit;
}

if(defined($p3_id))
{
   while(((my $aplaymidiID = `pidof $p3`) eq ($p3_id)) && (!defined( $key = ReadKey(-1))))
   {
      #define temporary storage scalars
      my $temp_cpu = qx(ps --no-headers -o %cpu -p $p1_id);
      my $temp_mem = qx(ps --no-headers -o %mem -p $p1_id);

      #Process 1 Info      
      push(@p1_cpu, $temp_cpu);
      push(@p1_mem, $temp_mem);
      $p1_time = qx(ps --no-headers -o time -p $p1_id);


      #process 2 info
      $temp_cpu = qx(ps --no-headers -o %cpu -p $p2_id);
      $temp_mem = qx(ps --no-headers -o %mem -p $p2_id);
      
      push(@p2_cpu, $temp_cpu);
      push(@p2_mem, $temp_mem);
      $p2_time = qx(ps --no-headers -o time -p $p2_id);


      #Process 3 Info
      $temp_cpu = qx(ps --no-headers -o %cpu -p $p3_id);
      $temp_mem = qx(ps --no-headers -o %mem -p $p3_id);

      push(@p3_cpu, $temp_cpu);
      push(@p3_mem, $temp_mem);
      $p3_time = qx(ps --no-headers -o time -p $p3_id);

      sleep $interval;
   }
}
else
{
   print("Error acquiring PI for aplaymidi\n");
   ReadMode 0;
   exit;
}

#Average Cpu usage percentages

#For process 1 "lightorgan"
my $sum_p1_cpu = my $avg_p1_cpu = 0;
$sum_p1_cpu += $_ for @p1_cpu;
my $len_p1_cpu = @p1_cpu;
$avg_p1_cpu = $sum_p1_cpu / $len_p1_cpu;

#For process 2 "timidity"
my $sum_p2_cpu = my $avg_p2_cpu = 0;
$sum_p2_cpu += $_ for @p2_cpu;
my $len_p2_cpu = @p2_cpu;
$avg_p2_cpu = $sum_p2_cpu / $len_p2_cpu;

#For process 3 "aplaymidi"
my $sum_p3_cpu = my $avg_p3_cpu = 0;
$sum_p3_cpu += $_ for @p3_cpu;
my $len_p3_cpu = @p3_cpu;
$avg_p3_cpu = $sum_p3_cpu / $len_p3_cpu;


#Average memory usage percentage

#For process 1 "lightorgan"
my $sum_p1_mem = my $avg_p1_mem = 0;
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

#Clean up GPIO sockets and processes
system("sudo python cleanup.py");
if(my $aplaymidiID = `pidof $p3` eq ($p3_id))
{
   system("sudo kill $p3_id");
}
`sudo renice 0 -p $p2_id`;
ReadMode 0;
exit;        
