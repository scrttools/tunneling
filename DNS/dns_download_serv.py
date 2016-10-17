# -*- coding: utf-8 -*-
#!/usr/bin/python
import socket
import logging
import dns
import dns.message
import string
import re
import argparse
import sys
from struct import pack
import base64

def get_response_data(query_name):
    infos = query_name.split('.')
    try:
        filename = infos[0]
        offset = int(infos[1])
        size = int(infos[2])
        print "Sending %d bytes from %d of %s"%(size, offset, filename)
        f = open(filename)
        f.seek(offset)
        buf = f.read(size)
        f.close()
    except:
        buf = u'error'
    return base64.b64encode(buf)

def compress_name(query_name):
    parts = query_name.split('.')
    compressed = ''
    for part in parts:
        compressed += '%c%s'%(len(part), part)
    return compressed

def handle_query(msg,address,message_id):
    qs = msg.question

    for q in qs:
        resp = dns.message.make_response(msg)
        resp.flags |= dns.flags.AA
        resp.set_rcode(0)
        responses_data = []
        if(resp):
            response_data = get_response_data(str(q.name))
            if response_data:
                payload = pack('>H', message_id)+'85000001000100000000'.decode('hex')
                payload += compress_name(str(q.name))
                payload += '00100001c00c0010000100000e10'.decode('hex')
                txtData = ''
                totalLength = 0
                for i in range(0,len(response_data),255):
                    chunk = response_data[i:i+255]
                    txtData += '%c%s'%(len(chunk),chunk)
                    totalLength+=1+len(chunk)
                payload += pack('>H',totalLength)
                payload += txtData
                s.sendto(payload, address)
            else:
                logging.debug('[-] No more data - item requested exceeds range')
                return
        else:
            logging.error('[x] Error creating response, not replying')
            return

def requestHandler(address, message):
    serving_ids = []

    message_id = ord(message[0]) * 256 + ord(message[1])
    if message_id in serving_ids:
        logging.debug('[-] Request already being served - aborting')
        return

    serving_ids.append(message_id)

    msg = dns.message.from_wire(message)
    op = msg.opcode()
    if op == 0:
        qs = msg.question
        if len(qs) > 0 and "IN PTR" not in str(qs[0]):
            q = qs[0]
            logging.debug('[+] DNS request is: ' + str(q))
            handle_query(msg,address,message_id)
        else:
            logging.debug('qs : %s'%qs)
    else:
        logging.error('[x] Received invalid request')

    serving_ids.remove(message_id)



if __name__ == '__main__':

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('', 53))
    serving_ids = []

    while True:
        message, address = s.recvfrom(1024)
        requestHandler(address, message)
