#!%%PERLBIN%%
# lookup.perl -- Looks up the sender/recipient addresses for a message
# Author          : Brian T. Wightman
# Created On      : Wed May  7 11:19:24 1997
# Last Modified By: Brian T. Wightman
# Last Modified On: Wed Jun 11 08:07:59 1997
# Update Count    : 31
# Status          : 0.0alpha6
# 
# HISTORY
# 

#
# The only parameter that this program accepts is a messageID.  It should
# be of the form dir/id, where dir is the split directory and ID is the
# actual filename.
#

$version="%%VERSION%%";

# Where qmail's queue directory resides
$topdir="%%QMAILDIR%%";
$queuedir="$topdir/queue";

# The messageid is passed in on argv
$messageid = @ARGV[0];

# variable initialization
@done=();
@undone=();

# Glean information from the queue
$from=&get_from("$queuedir/info/$messageid");
unshift(@done, &get_done("$queuedir/remote/$messageid"));
unshift(@done, &get_done("$queuedir/local/$messageid"));
unshift(@undone, &get_undone("$queuedir/remote/$messageid"));
unshift(@undone, &get_undone("$queuedir/local/$messageid"));

# Print results to be used by other scripts
&display($from, *done, *undone);

# Get the from address (envelope) from a queue file
sub get_from {
    local($file) = @_;
    local($line);

    open(FILE, $file);
    chomp($line=<FILE>);
    close(FILE);
    $line = (split(/\0/, $line))[0];
    $line = substr($line, 1);
    return $line;
}

# Get addresses that have been delivered to from the queue file
sub get_done { 
    local($file) = @_;
    local($name, $line, @names);
 
    @names=();

    open(FILE, $file);
    chomp($line=<FILE>);
    close(FILE);
    foreach $name (split(/\0/, $line)) {
	unshift(@names, substr($name, 1)) if substr($name,0,1) eq "D";
    }
    return @names;
}

# Get addresses yet to be processed from the queue file
sub get_undone { 

    local($file) = @_;
    local($name, $line, @names);

    @names=();

    open(FILE, $file);
    chomp($line=<FILE>);
    close(FILE);
    foreach $name (split(/\0/, $line)) {
	unshift(@names, substr($name, 1)) if substr($name,0,1) eq "T";
    }
    return @names;
}

# Print the from, done, and undone lines to the out pipe
sub display {
    local($from, *done, *undone) = @_;
    local($name);

    print "F $from\n";

    foreach $name (@done) {
	print "D $name\n";
    }

    foreach $name (@undone) {
	print "T $name\n";
    }

    return 0;
}

