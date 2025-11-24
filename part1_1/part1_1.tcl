
set ns [new Simulator]

# Fichier trace
set ftrace [open part1_1.tr w]
$ns trace-all $ftrace

# Creation des noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

# Liens feuilles -> coeur (RTT heterogenes)
$ns duplex-link $n0 $n3 100Mb 5ms DropTail
$ns duplex-link $n1 $n3 100Mb 15ms DropTail
$ns duplex-link $n2 $n3 100Mb 30ms DropTail

$ns duplex-link $n4 $n5 100Mb 5ms DropTail
$ns duplex-link $n4 $n6 100Mb 15ms DropTail
$ns duplex-link $n4 $n7 100Mb 30ms DropTail

# Lien de coeur (goulet d'etranglement)
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns queue-limit $n3 $n4 50
$ns queue-limit $n4 $n3 50

# Fonction simple pour creer un flux TCP/FTP
proc create_tcp_ftp {ns src dst fid tcpName sinkName ftpName} {
    upvar $tcpName tcp
    upvar $sinkName sink
    upvar $ftpName ftp

    set tcp  [new Agent/TCP/Newreno]
    $tcp set fid_ $fid      ;# id du flux
    $ns attach-agent $src $tcp

    set sink [new Agent/TCPSink]
    $ns attach-agent $dst $sink

    $ns connect $tcp $sink

    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
}

# 6 flux : 2 par couple (n0->n5), (n1->n6), (n2->n7)
create_tcp_ftp $ns $n0 $n5 0 tcp0 sink0 ftp0
create_tcp_ftp $ns $n0 $n5 1 tcp1 sink1 ftp1

create_tcp_ftp $ns $n1 $n6 2 tcp2 sink2 ftp2
create_tcp_ftp $ns $n1 $n6 3 tcp3 sink3 ftp3

create_tcp_ftp $ns $n2 $n7 4 tcp4 sink4 ftp4
create_tcp_ftp $ns $n2 $n7 5 tcp5 sink5 ftp5

# Demarrage et fin de simulation
set simTime 100.0

$ns at 0.5 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 0.5 "$ftp3 start"
$ns at 0.5 "$ftp4 start"
$ns at 0.5 "$ftp5 start"

proc finish {} {
    global ns ftrace simTime
    $ns flush-trace
    close $ftrace
    puts "Simulation terminee a t=$simTime s"
    exit 0
}

$ns at $simTime "finish"
$ns run
