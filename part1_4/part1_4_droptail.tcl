# ======================================
# Partie 1.4 - DropTail (taille file variable)
# RTT homogenes, 6 flux NewReno
# ======================================

set ns [new Simulator]

# Taille de la file du goulet (a changer)
set qlim 1000

set ftrace [open "part1_4_droptail_${qlim}.tr" w]
$ns trace-all $ftrace

# Noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

# Liens d'acces (RTT homogenes)
$ns duplex-link $n0 $n3 100Mb 10ms DropTail
$ns duplex-link $n1 $n3 100Mb 10ms DropTail
$ns duplex-link $n2 $n3 100Mb 10ms DropTail

$ns duplex-link $n4 $n5 100Mb 10ms DropTail
$ns duplex-link $n4 $n6 100Mb 10ms DropTail
$ns duplex-link $n4 $n7 100Mb 10ms DropTail

# Goulet DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns queue-limit $n3 $n4 $qlim
$ns queue-limit $n4 $n3 $qlim

# Trace de la file
set qtrace [open "part1_4_droptail_${qlim}_queue.tr" w]
$ns trace-queue $n3 $n4 $qtrace

# Creation d'un flux TCP/FTP
proc create_tcp_ftp {ns src dst fid tcpName sinkName ftpName} {
    upvar $tcpName tcp
    upvar $sinkName sink
    upvar $ftpName ftp

    set tcp [new Agent/TCP/Newreno]
    $tcp set fid_ $fid
    $tcp set window_ 2000
    $tcp set maxcwnd_ 2000
    $ns attach-agent $src $tcp

    set sink [new Agent/TCPSink]
    $ns attach-agent $dst $sink

    $ns connect $tcp $sink

    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
}

# 6 flux
create_tcp_ftp $ns $n0 $n5 0 tcp0 sink0 ftp0
create_tcp_ftp $ns $n0 $n5 1 tcp1 sink1 ftp1

create_tcp_ftp $ns $n1 $n6 2 tcp2 sink2 ftp2
create_tcp_ftp $ns $n1 $n6 3 tcp3 sink3 ftp3

create_tcp_ftp $ns $n2 $n7 4 tcp4 sink4 ftp4
create_tcp_ftp $ns $n2 $n7 5 tcp5 sink5 ftp5

set simTime 200.0

$ns at 0.5 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 0.5 "$ftp3 start"
$ns at 0.5 "$ftp4 start"
$ns at 0.5 "$ftp5 start"

proc finish {} {
    global ns ftrace qtrace simTime qlim
    $ns flush-trace
    close $ftrace
    close $qtrace
    puts "Fin DropTail qlim=$qlim t=$simTime s"
    exit 0
}

$ns at $simTime "finish"
$ns run
