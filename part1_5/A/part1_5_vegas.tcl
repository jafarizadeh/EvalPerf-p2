# ======================================
# Partie 1.5A - Vegas, extensibilite 10Gbps
# Mesure debit sans gros trace et sans overflow
# ======================================

set ns [new Simulator]

set pktSize 10000
set qlim 20000
set wnd 50000
set simTime 60.0

set rfile [open thr_part1_5_vegas.txt w]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n1 50000Mb 1ms DropTail
$ns duplex-link $n2 $n3 50000Mb 1ms DropTail

$ns duplex-link $n1 $n2 10000Mb 5ms DropTail
$ns queue-limit $n1 $n2 $qlim
$ns queue-limit $n2 $n1 $qlim

set tcp0 [new Agent/TCP/Vegas]
$tcp0 set fid_ 0
$tcp0 set packetSize_ $pktSize
$tcp0 set window_ $wnd
$tcp0 set maxcwnd_ $wnd
$ns attach-agent $n0 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set totBytes 0.0
set lastBytes 0

proc record_bytes {} {
    global ns sink0 totBytes lastBytes
    set cur [$sink0 set bytes_]
    set diff [expr $cur - $lastBytes]
    if {$diff < 0} {
        set diff [expr $diff + 4294967296.0]
    }
    set totBytes [expr $totBytes + $diff]
    set lastBytes $cur
    set now [$ns now]
    $ns at [expr $now + 1.0] "record_bytes"
}

$ns at 0.5 "$ftp0 start"
$ns at 0.5 "record_bytes"

proc finish {} {
    global rfile simTime totBytes
    set thr [expr $totBytes*8.0/$simTime/1000000.0]
    puts $rfile "Throughput Vegas = [format %.3f $thr] Mbps"
    close $rfile
    puts "Fin Vegas haut debit t=$simTime s"
    exit 0
}

$ns at $simTime "finish"
$ns run
