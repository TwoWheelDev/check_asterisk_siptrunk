#!/usr/bin/perl

###  check_asterisk_siptrunk.pl ##############################################
#                                                                            #
# A plugin to check the status of Asterisk SIP Peers.                        #
#                                                                            #
# Written by Daniel Lintott, daniel@serverb.co.uk                            #
# 08 February 2014                                                           #
#                                                                            #
##############################################################################

use strict;
use warnings;

use Monitoring::Plugin;
use File::Basename;
use Asterisk::AMI;
no warnings qw(Asterisk::AMI);

use vars qw($VERSION $PROGNAME  $verbose $timeout $result);
$VERSION = '1.0';

# get the base name of this script for use in the examples
$PROGNAME = basename($0);

##############################################################################
# define and get the command line options.                                   #
##############################################################################

# Instantiate Monitoring::Plugin object (the 'usage' parameter is mandatory)
my $p = Monitoring::Plugin->new(
        usage => "Usage: %s [ -v|--verbose ]  [--host|-H host] [--port|-P port]
                  --user AMIUser  --pass AMIPass  --peer SIP Peer",
        version => $VERSION,
        blurb => 'This plugin will check the status of a SIP Peer via the Asterisk Management Interface (AMI)',
        url => 'http://www.github.com/dlintott/check_asterisk_siptrunk'
        );

# Define and document the valid command line options
# usage, help, version, timeout and verbose are defined by default.

$p->add_arg(
	spec => 'host|H:s',
	help => qq{--host|-H <host> IP Address for AMI (Default: 127.0.0.1)},
    default => '127.0.0.1'
    );
$p->add_arg(
	spec => 'port|P:s',
	help => qq{--port|-P <port> Port for AMI (Default: 5038)},
    default => '5038'
    );
$p->add_arg(
	spec => 'user=s',
	help => qq{--user <username> Username for AMI},
    required => 1
    );
$p->add_arg(
	spec => 'pass=s',
	help => qq{--pass <password> Password for AMI},
    required => 1
    );
$p->add_arg(
	spec => 'peer=s',
	help => qq{--peer <peer> Name of the SIP peer to check},
    required => 1
    );

# Parse arguments and process standard ones (e.g. usage, help, version)
$p->getopts;

##############################################################################
# Check SIP Trunk using AMI                                                  #
##############################################################################

my $result = 0;
my $message;

if ( $p->opts->verbose ) {
    print "User: "     . $p->opts->user . "\n";
    print "Password: " . $p->opts->pass . "\n";
    print "Host: "     . $p->opts->host . "\n";
    print "Port: "     . $p->opts->port . "\n";
    print "Peer: "     . $p->opts->peer . "\n";
}

my $astman = Asterisk::AMI->new(PeerAddr => $p->opts->host,
                                PeerPort => $p->opts->port,
                                Username => $p->opts->user,
                                Secret   => $p->opts->pass
                                );
die "Unable to connect to asterisk" unless ($astman);

my $actionid = $astman->send_action({
					Action => 'SIPshowpeer',
					Peer => $p->opts->peer
				    });

my $response = $astman->get_response($actionid);

if ($response->{'GOOD'} == 0) {
    $result = 2;
    $message = $response->{'Message'};
	print "Error: " . $response->{'Message'} . "\n" if $p->opts->verbose;
} else {
    my $status = \$response->{'PARSED'}->{'Status'};
    
    if (index($$status, 'OK') != -1) { 
        $message = $$status;
        print $p->opts->peer . "is" . $message . "\n" if $p->opts->verbose;
    } else {
        $message = $$status;
        $result = 1;
        print $p->opts->peer . "is" . $message . "\n" if $p->opts->verbose;
    }
}

$actionid = $astman->send_action({ Action => 'Logoff' });
$response = $astman->get_response($actionid);

##############################################################################
# Output the result and exit                                                 #
##############################################################################

$p->plugin_exit( return_code => 'CRITICAL', 
                 message => $p->opts->peer . " is $message" ) if ($result == 1);

$p->plugin_exit( return_code => 'UNKNOWN', 
                 message => $message ) if ($result == 2);

$p->plugin_exit( return_code => 'OK', 
                 message => $p->opts->peer . " is $message" );




