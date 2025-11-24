# ======================================
# Partie 1.5B - Charge en hausse sur le goulet
# 6 flux TCP + trafic de fond CBR/UDP
# RTT homogenes, sans NAM
# ======================================

set ns [new Simulator]

# -------- Parametres a faire varier --------
set bgRate 4.0          ;# Mbps, trafic de fond (0 => pas de fond)
set extraPerPair 1      ;# 0 ou 1 (ajoute 1 flux par paire)
set qlim 200            ;# file du goulet (bon compromis vu 1.4)
set simTime 200.0
# ------------------------------------------

# Traces
set ftrace [open "part1_5B_bg${bgRate}_extra${extraPerPair}.tr" w]
$ns trace-all $ftrace

set qtrace [open "part1_5B_bg${bgRate}_extra${extraPerPair}_queue.tr" w]
# trace de la file du goulet
# (apres creation du lien)

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

# Goulet (lien de coeur)
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns queue-limit $n3 $n4 $qlim
$ns queue-limit $n4 $n3 $qlim

$ns trace-queue $n3 $n4 $qtrace

# ---- Fonction simple pour creer un flux TCP/FTP ----
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

# ---- 6 flux TCP de base (2 par paire) ----
create_tcp_ftp $ns $n0 $n5 0 tcp0 sink0 ftp0
create_tcp_ftp $ns $n0 $n5 1 tcp1 sink1 ftp1

create_tcp_ftp $ns $n1 $n6 2 tcp2 sink2 ftp2
create_tcp_ftp $ns $n1 $n6 3 tcp3 sink3 ftp3

create_tcp_ftp $ns $n2 $n7 4 tcp4 sink4 ftp4
create_tcp_ftp $ns $n2 $n7 5 tcp5 sink5 ftp5

# ---- Flux TCP supplementaires si extraPerPair=1 ----
if {$extraPerPair == 1} {
    create_tcp_ftp $ns $n0 $n5 6 tcp6 sink6 ftp6
    create_tcp_ftp $ns $n1 $n6 7 tcp7 sink7 ftp7
    create_tcp_ftp $ns $n2 $n7 8 tcp8 sink8 ftp8
}

# ---- Trafic de fond UDP/CBR sur le goulet ----
if {$bgRate > 0.0} {
    set udp0 [new Agent/UDP]
    $ns attach-agent $n0 $udp0

    set null0 [new Agent/Null]
    $ns attach-agent $n7 $null0

    $ns connect $udp0 $null0

    set cbr0 [new Application/Traffic/CBR]
    $cbr0 set packetSize_ 1000

    # interval = (packetSize*8)/rate
    set interval [expr (1000.0*8.0)/($bgRate*1000000.0)]
    $cbr0 set interval_ $interval
    $cbr0 attach-agent $udp0
}

# ---- Demarrage des applis ----
$ns at 0.5 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 0.5 "$ftp3 start"
$ns at 0.5 "$ftp4 start"
$ns at 0.5 "$ftp5 start"

if {$extraPerPair == 1} {
    $ns at 0.5 "$ftp6 start"
    $ns at 0.5 "$ftp7 start"
    $ns at 0.5 "$ftp8 start"
}

if {$bgRate > 0.0} {
    $ns at 1.0 "$cbr0 start"
}

proc finish {} {
    global ns ftrace qtrace simTime bgRate extraPerPair
    $ns flush-trace
    close $ftrace
    close $qtrace
    puts "Fin 1.5B bg=$bgRate extra=$extraPerPair t=$simTime s"
    exit 0
}

$ns at $simTime "finish"
$ns run
