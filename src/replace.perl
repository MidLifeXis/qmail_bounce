#!/usr/local/bin/perl
# replace.perl -- Does replacements on files.
# Author          : Brian T. Wightman
# Created On      : Wed May 28 14:52:09 1997
# Last Modified By: Brian T. Wightman
# Last Modified On: Wed Jun 11 08:08:05 1997
# Update Count    : 11
# Status          : 0.0alpha6
# 
# HISTORY
# 

$workdir=shift;					   # Working directory
while (@ARGV[0] ne "--") {
    ($pattern,$replace) = split(/=/, shift);
    $replacements{"$pattern"} = "$replace";
}

shift;

if ( ! -d "$workdir" ) {
    mkdir("$workdir", 0700) || die "Unable to make work directory $workdir.\n";
}

foreach $file (@ARGV) {
    if (open(IN, "< $file")) {
	if (open(OUT, "> $workdir/$file")) {
	    # Opened both files successfully
	    while($in=<IN>) {
		foreach $key (keys(%replacements)) {
		    $in =~ s,$key,$replacements{"$key"},g;
		}
		print OUT $in;
	    }
	    close(OUT);
	} else {
	    warn("Problem opening OUTFILE '$workdir/$file'.\n");
	}
	close(IN);
    } else {
	warn("Problem opening INFILE '$file'.\n");
    }
}



