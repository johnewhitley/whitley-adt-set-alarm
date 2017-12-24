#!/usr/bin/perl
# ADT Pulse Script (For use with CRON Trigger)
# Author John Whitley
# johnewhitley@gmail.com
#
# The script accesses the ADT Pulse website, and sends the form to turn the house alarm on. 
#
# This program is not in any way endorsed by ADT or even by myself. Use at your own risk.
#
#

use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;
use FileHandle;
use CGI;
use strict;


my $mech = new WWW::Mechanize;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

my $cgi = new CGI;
my $params = $cgi->Vars;

my $fn;
if(-e "/home/johnw/adt_project/whitley-adt/whitley-pulse.conf")
{
  $fn = "/home/johnw/adt_project/whitley-adt/whitley-pulse.conf";
}
elsif(-e "~/.pulse.conf")
{
  $fn = "~/.pulse.conf";
}
elsif(-e "/etc/pulse/pulse.conf")
{
  $fn = "/etc/pulse/pulse.conf";
}


# Allow username/password to come from web, or local config.
my %conf;
if($params->{'PASS'} and $params->{'USER'})
{
  $conf{username} = $params->{'USER'};
  $conf{password} = $params->{'PASS'};
}
else
{
  if(!$fn)
  {
    print("Missing config file and no username/password provided.\n");
    exit;
  }

  my $fh = new FileHandle;
  if(!$fh->open("< $fn"))
  {
    print("Cannot read config file: $fn\n");
    exit;
  }

  # Read config
  while(my $foo = <$fh>)
  {
    $conf{$1} = $2 if($foo =~ m/([^=]*)=(.*)/o);
  }
  $fh->close();
}

###Main Script###


{
 $mech->get("https://portal.adtpulse.com");

 $mech->submit_form( with_fields => { usernameForm => $conf{username}, passwordForm => $conf{password} },
                      button => 'signin');

 $mech->get("://portal.adtpulse.com/myhome/9.5.0-956/quickcontrol/armDisarmRRA.jsp?href=rest/adt/ui/client/security/setArmState&armstate=away&arm=off");
}



