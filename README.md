# OpenTools

OpenTools is a collection of gadget tools for using BSD Unix. It is not a great
tool, such as remotely logging in on a terminal by specifying a remote host,
remotely logging in to the home machine and starting emacs's mail client
on a terminal, but for Unix users Scripts that save one effort. 


---

## Commands

The main ones are the following eight.

* **bwsr**	 Start up the browser.
* **mailprc**	 Command line based MDA. POP/APOP/Maildir compatible
* **sbackup**	 Remote backup to day, week, month, year
* **slgn**	 Launch xterm and log in remotely. Color can be specified
* **w3**	 Launch w3m on xterm. Color can be specified
* **wl**	 Launch emacs+Wanderlust locally or remotely. Decoration can be specified
* **xemcs**	 Start XEmacs. Position and decoration can be specified
* **xtrm**	 Start XTerm. Position and color can be specified

In addition to this, there are auxiliary tools as below.

* **autocol**	Correct HTML table column
* **create-portstree**	Make a unique ports tree
* **latex2latex**	Fiddling with LaTeX source
* **newest**		Pick up the latest one of the specified files
* **sct**		Remote directory tree copy. Permission and Symbolic link save
* **sdoc2page**		SmartDoc HTML->GitHub page conversion
* **sdoc2sdoc**		Edit SmartDoc HTML

For details, refer to the respective help (indicated by '`--help`'
option). There is no manual for now `;-)`

---

## Installation

#### 1. Check out this repository

Check out `github.com/styckm/opentools`.

	% git clone https://github.com/styckm/opentools.git

#### 2. Installation

Install it.

	# cd opentools
	# make install

By default, commands are installed in `/usr/local/bin` and others
(libraries and include files) are installed in `/usr/local/opentools`. If
you want to change the installation destination, specify the installation
destination directory in DEST, 

	# make DEST=/install_destdir install

The configuration file is `/usr/local/etc/opentools.conf`. You can basically
write the initial settings of all commands in this file. See
`/usr/local/opentools/include/*.inc` to see what settings can be made. Include
files corresponding to each command are as follows. 

* `common.inc`	**Common**	
* `mail.inc`	**mailprc**		
* `misc.inc`	**bwsr**, **sbackup**, **slgn**, **w3**, **wl**, **xemcs**, **xtrm**
* `ports.inc`	**create-portstree**
* `sys.inc`	**newest**, **sct**

### FreeBSD

FreeBSD has a package. Download from the site below,

	# pkg add opentools-1.0.xz

If you want to install from ports, the skeleton is in `data/ports/opentools-1.0.tar.gz`.

	# cd $PORTSDIR
	# tar xf opentools-1.0.tar.gz
	# cd sysutils/opentools
	# make install

### NetBSD

There is no pkgsrc. I am trying hard to make it keenly `;-p)`

### OpenBSD

There is no corresponding port here. Does anyone merge it?

### DragonFly BSD, TureOS, ...

I have not examined it at all, but I will make it for easy.

## The assumed environment of each command

Each. It is assumed that it can be executed in the following environment.

* **bwsr**
   Be able to launch FireFox and Chrome
* **mailprc**
   Be able to execute imget. Install ports(mail/im) on FreeBSD.
* **sbackup**
   Especially it is OK in the default environment, but please be able to
   slogin to the remote site without passphrase.
* **slgn**
   Especially OK in the default environment
* **w3**
   w3m must be installed. Install ports(japanese/w3m) on FreeBSD.
* **wl**
   What you can use Wanderust on Emacs/XEmacs.
* **xemcs**
   XEmacs installed.
* **xtrm**
   Especially OK in the default environment

---

opentools@TrueFC.org
