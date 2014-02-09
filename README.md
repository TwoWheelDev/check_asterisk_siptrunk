check_asterisk_siptrunk
=======================

This plugin will check the status of a SIP Peer via the Asterisk Management Interface (AMI)

Usage: check_asterisk_siptrunk.pl [ -v|--verbose ]  [--host|-H host] [--port|-P port]
                                  --user AMIUser  --pass AMIPass  --peer SIP Peer

 -?, --usage
   Print usage information
 -h, --help
   Print detailed help screen
 -V, --version
   Print version information
 --extra-opts=[section][@file]
   Read options from an ini file. See http://nagiosplugins.org/extra-opts
   for usage and examples. (Currently not implemented)
 -H, --host <host> IP Address for AMI (Default: 127.0.0.1)
 -P, --port <port> Port for AMI (Default: 5038)
 --user <username> Username for AMI
 --pass <password> Password for AMI
 --peer <peer> Name of the SIP peer to check
 -t, --timeout=INTEGER
   Seconds before plugin times out (default: 15)
 -v, --verbose
   Show details for command-line debugging (can repeat up to 3 times)

## Requirements

- Asterisk::AMI (http://search.cpan.org/~greenbean/Asterisk-AMI/)
- Nagios::Plugin (http://search.cpan.org/~tonvoon/Nagios-Plugin-0.36/)
