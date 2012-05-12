#!%%PERLBIN%%
# scanner.perl -- Scanner for the qmail bounce program.
# Author          : Brian T. Wightman
# Created On      : Tue May  6 19:44:48 1997
# Last Modified By: Brian T. Wightman
# Last Modified On: Wed Jun 11 08:08:10 1997
# Update Count    : 42
# Status          : 0.0alpha6
# 
# HISTORY
# 

#                                                                   
# Configuration section
#                                                                   

$version="%%VERSION%%";				   # program's version string
$topdir="%%QMAILDIR%%";				   # Top level qmail directory
$queuedir="$topdir/queue";			   # queue directory
$statedir="$queuedir/state";			   # State storage

#
# These times are in seconds, however, you can use
# math operators to make reading easier.
#

# You need to change this array and the next array to reflect your
# tastes in how often delay messages should happen.  By default it
# is set to 4 hours, 1 day, 2 days, and 4 days.  At 7 days the message
# is returned.

@bouncetimes=(0,				   # (makes logic easier)
	      3600 * 4,				   # 4 hours
	      3600 * 24 * 1,			   # 1 day
	      3600 * 24 * 2,			   # 2 days
	      3600 * 24 * 4);			   # 4 days

#
# This array should match the @bouncetimes array.
# It contains the text that will be sent back to 
# the user when a delay notification is received.
#

@bouncewords=("0 seconds",			   # Shouldn't be reached
	      "4 hours",
	      "1 day",
	      "2 days",
	      "4 days");

#----------------------------------------------------
# End of configuration section
#----------------------------------------------------

# Initialize the umask for this process
umask(077);				   # Turn off all but owner

# Save the current time
$curtime = time();

# Get a list of all messages in the queue
@messages = ();
if (! opendir(QUEUE, "$queuedir/mess")) {
    &mydie(111, "Unable to open the queue directory.\n");
} else {
    @dirs = (grep(/^[0-9]+$/, readdir(QUEUE)));
    closedir(QUEUE);
}
foreach $queue (@dirs) {
    if (! opendir(QUEUE, "$queuedir/mess/$queue")) {
	warn("Unable to open the subqueue $queue.\n");
    } else {
	foreach $message (grep(/^[0-9]+$/, readdir(QUEUE))) {
	    unshift(@messages, "$queue/$message");
	}
	closedir(QUEUE);
    }
}

# Process each message
foreach $message (@messages) {
    $msgtime = (stat("$queuedir/mess/$message"))[10];
    $difftime = $curtime - $msgtime;
    &startbounce($message, $msgtime, $difftime);   # Main logic
}

# Cleanup files from the statedir that no longer have a queued message
if (! opendir(STATE, "$statedir")) {
    &mydie(111, "Unable to open the state directory.\n");
} else {
    @dirs = (grep(/^[0-9]+$/, readdir(STATE)));
    closedir(STATE);
}
foreach $state (@dirs) {
    if (! opendir(STATE, "$statedir/$state")) {
	warn("Unable to open the substate $state.\n");
    } else {
	foreach $message (grep(/^[0-9]+$/, readdir(STATE))) {
	    open(FILE, "$statedir/$state/$message");
	    chomp($filetime = <FILE>);
	    close(FILE);
	    if ((stat("$queuedir/mess/$state/$message"))[10] != $filetime) {
		unlink("$statedir/$state/$message") ;
	    }
	}
	closedir(STATE);
    }
}


#
# Main logic for notification
#
# Takes a messageID, create time, and queued time
# and decides if a message should be generated.  If
# a message should be generated, it also outputs
# how much time the message should say.
#
sub startbounce {
    local($msgid, $messagetime, $timeinqueue) = @_;
    local($savedtime, $lastwarn, $thiswarn, *FILE);

    # Get the old information about the message
    if (-f "$statedir/$msgid") {
	open(FILE, "$statedir/$msgid");
	chomp($savedtime = <FILE>);
	chomp($lastwarn = <FILE>);
	close(FILE);
    } else {
	$savedtime = $messagetime;
	$lastwarn = 0;
    }

    # If the message and state don't match.....
    if ($savedtime != $messagetime) {
	unlink("$statedir/$msgid");
	$savedtime = $messagetime;
	$lastwarn = 0;
    }
	
    # Figure out what the current warn level should be
    $thiswarn = $#bouncetimes;
    while (($timeinqueue < @bouncetimes[$thiswarn]) && $thiswarn){
	$thiswarn--;
    }

    # Trigger a bounce warning
    #
    # At this time it only prints a line.  This is probably good,
    # as it allows a separate process to generate the bounce
    # message.
    #
    if ($thiswarn != $lastwarn) {
	print sprintf("%s:%s\n",
		      $msgid,
		      @bouncewords[$thiswarn]);
    }
    
    # Save the state information
    open(FILE, "> $statedir/$msgid");
    print FILE "$messagetime\n$thiswarn\n";
    close(FILE);
}

#
# Simple abort function
#
sub mydie {
    local($level, $message) = @_;

    print STDERR $message;
    exit ($level);
}

