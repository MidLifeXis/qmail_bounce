## Makefile -- Installation makefile for qmail bouncer script.
## Author          : Brian T. Wightman
## Created On      : Wed May 28 14:36:11 1997
## Last Modified By: Brian T. Wightman
## Last Modified On: Wed Jun 11 08:05:37 1997
## Update Count    : 73
## Status          : 0.0alpha6
## 
## HISTORY
###############################################################################

## #################################################################
## Configuration variables
##
## PERLBIN	Location of your perl executable
##
## PREFIX	Location where the bouncer will be run from
## INSTDIR	Location where program is installed (could be same
##		as PREFIX)
## OWNER	Username to own the files
## DIRMODE	Protection mode for the installation directories
## EXEMODE	Protection mode for the installed executables
## FILEMODE	Protection mode for the installed files
##
## QMAILDIR	Top level directory of qmail installation
## QUEUEOWNER	Owner of the qmail mail queue
## QUEUEMODE	Protection mode for the queue state directory
## WHEREAMI	Name your server is known as.
## TOTALTIME	Word description of queuelifetime
## EXTRARCPTS	Extra recipients of bounces (postmaster).
##
## WORKDIR	A working directory.  Should be subdirectory.
## #################################################################

PERLBIN=/usr/local/bin/perl

PREFIX=/opt/qmail_bounce-$(VERSION)
INSTDIR=/export/$(PREFIX)
OWNER=root
DIRMODE=755
EXEMODE=755
FILEMODE=644

QMAILDIR=/var/qmail
# QUEUEOWNER=qmails.qmail
QUEUEOWNER=qmails:qmail
QUEUEMODE=700
WHEREAMI=example.com
TOTALTIME=7 days
EXTRARCPTS=\"postmaster\\@$(WHEREAMI)\"

WORKDIR=workdir

## #################################################################
## Commands - should be OK for most installations
## #################################################################

LS=/bin/ls
ECHO=echo
MKDIR=mkdir
CHOWN=chown
CHOWNR=chown -R
CHMOD=chmod
CHMODR=chmod -R
CP=cp
RM=/bin/rm -rf

## #################################################################
## End of configuration section
## #################################################################

VERSION=0.0alpha6
REPLACEMENTS=	"%%PERLBIN%%=$(PERLBIN)" \
		"%%PREFIX%%=$(PREFIX)" \
		"%%WHEREAMI%%=$(WHEREAMI)" \
		"%%TOTALTIME%%=$(TOTALTIME)" \
		"%%QMAILDIR%%=$(QMAILDIR)" \
		"%%VERSION%%=$(VERSION)" \
		"%%EXTRARCPTS%%=$(EXTRARCPTS)"
BINFILES=bounce
LIBFILES=lookup.perl scanner.perl
TARGETDIRS=$(INSTDIR) $(INSTDIR)/bin $(INSTDIR)/lib
SHOW=@

## #################################################################
## Rules
## #################################################################

all: check version

install: check all $(TARGETDIRS) binfiles libfiles statedir

version: check $(BINFILES) $(LIBFILES)
	$(SHOW)$(ECHO) "Generating scripts..."
	-$(SHOW)$(MKDIR) $(WORKDIR)
	$(SHOW)$(PERLBIN) replace.perl $(WORKDIR) $(REPLACEMENTS) --\
		$(BINFILES) $(LIBFILES)
	$(SHOW)$(ECHO) "Done."
	$(SHOW)$(ECHO) $(VERSION) > version

$(TARGETDIRS): check
	$(SHOW)$(ECHO) "Creating target directories..."
	$(SHOW)for x in $(TARGETDIRS); do		\
		$(ECHO) "\t$$x...";			\
		$(MKDIR) $$x || /bin/true;		\
		$(CHOWN) $(OWNER) $$x;			\
		$(CHMOD) $(DIRMODE) $$x;		\
	done
	$(SHOW)$(ECHO) "Done."

binfiles: check all $(TARGETDIRS)
	$(SHOW)$(ECHO) "Installing binaries..."
	$(SHOW)for x in $(BINFILES); do				\
		$(ECHO) "\t$$x...";				\
		$(CP) $(WORKDIR)/$$x $(INSTDIR)/bin/$$x;	\
		$(CHOWN) $(OWNER) $(INSTDIR)/bin/$$x;		\
		$(CHMOD) $(EXEMODE) $(INSTDIR)/bin/$$x;	\
	done
	$(SHOW)$(ECHO) "Done."

libfiles: check all $(TARGETDIRS)
	$(SHOW)$(ECHO) "Installing support programs..."
	$(SHOW)for x in $(LIBFILES); do				\
		$(ECHO) "\t$$x...";				\
		$(CP) $(WORKDIR)/$$x $(INSTDIR)/lib/$$x;	\
		$(CHOWN) $(OWNER) $(INSTDIR)/lib/$$x;		\
		$(CHMOD) $(EXEMODE) $(INSTDIR)/lib/$$x;		\
	done
	$(SHOW)$(ECHO) "Done."

statedir: check
	$(SHOW)$(ECHO) "Creating state directory..."
	$(SHOW)if [ ! -d $(QMAILDIR)/queue ]; then 			\
		$(ECHO) "Unable to find queue directory.  Exiting.";	\
		exit 1;							\
	else								\
		$(MKDIR) $(QMAILDIR)/queue/state || /bin/true;		\
		for x in `$(LS) $(QMAILDIR)/queue/mess`; do		\
			$(MKDIR) $(QMAILDIR)/queue/state/$$x || /bin/true;\
		done;							\
		$(CHOWNR) $(QUEUEOWNER) $(QMAILDIR)/queue/state;	\
		$(CHMODR) $(QUEUEMODE) $(QMAILDIR)/queue/state;		\
	fi

# Perform some configuration checks (make sure everything is OK)
check:
	$(SHOW)if [ "$(WHEREAMI)" = "example.com" ]; then 		\
		$(ECHO) "You need to change the WHEREAMI variable";	\
		$(ECHO) "in the Makefile before installing this";	\
		$(ECHO) "program.  Please fix this and try again.";	\
		exit 1;							\
	fi

clean:
	$(SHOW)$(ECHO) "Cleaning up directory..."
	$(SHOW)$(RM) $(WORKDIR)
	$(SHOW)$(RM) version
	$(SHOW)$(RM) *.bak *~

