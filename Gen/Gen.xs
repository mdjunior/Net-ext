/*

# Copyright 1995,1996 Spider Boardman.
# All rights reserved.
#
# Automatic licensing for this software is available.  This software
# can be copied and used under the terms of the GNU Public License,
# version 1 or (at your option) any later version, or under the
# terms of the Artistic license.  Both of these can be found with
# the Perl distribution, which this software is intended to augment.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef I_FCNTL
#include <fcntl.h>
#endif
#ifdef I_SYS_FILE
#include <sys/file.h>
#endif

#include <sys/socket.h>

static U32
constant(name)
char *name;
{
    errno = 0;
    switch (*name) {
    case 'E':
	if (strEQ(name, "EOF_NONBLOCK")) {
#ifdef EOF_NONBLOCK
	    return 1;
#else
	    return 0;
#endif
	}
	break;
    case 'R':
	if (strEQ(name, "RD_NODATA")) {
#ifdef RD_NODATA
	    return RD_NODATA;
#else
	    goto not_there;
#endif
	}
	break;
    case 'V':
	if (strEQ(name, "VAL_O_NONBLOCK")) {
#ifdef VAL_O_NONBLOCK
	    return VAL_O_NONBLOCK;
#else
	    goto not_there;
#endif
	}
	if (strEQ(name, "VAL_EAGAIN")) {
#ifdef VAL_EAGAIN
	    return VAL_EAGAIN;
#else
	    goto not_there;
#endif
	}
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

MODULE = Net::Gen		PACKAGE = Net::Gen

U32
constant(name)
	char *	name

void
pack_sockaddr(family,address)
	unsigned short	family
	SV *		address
	CODE:
	{
	    struct sockaddr sad;
	    char * adata;
	    STRLEN adlen;

	    Zero(&sad, sizeof sad, char);
	    sad.sa_family = family;
	    adata = SvPV(address, adlen);
	    if (adlen > sizeof(sad.sa_data)) {
		SV * rval = sv_newmortal();
		sv_setpvn(rval, (char*)&sad, sizeof sad - sizeof sad.sa_data);
		sv_catpvn(rval, adata, adlen);
		ST(0) = rval;
	    }
	    else {
		Copy(adata, &sad.sa_data, adlen, char);
		ST(0) = sv_2mortal(newSVpv((char*)&sad, sizeof sad));
	    }
	}

void
unpack_sockaddr(sad)
	SV *	sad
	PPCODE:
	{
	    char * cp;
	    STRLEN len;

	    if ((cp = SvPV(sad, len)) != (char*)0) {
		struct sockaddr sa;
		unsigned short family;
		SV * famsv;
		SV * datsv;

		Copy(cp, &sa, len < sizeof sa ? len : sizeof sa, char);
		family = sa.sa_family;
		famsv = sv_2mortal(newSViv(family));
		if (len >= sizeof sa - sizeof sa.sa_data) {
		    len -= sizeof sa - sizeof sa.sa_data;
		    datsv = sv_2mortal(newSVpv(cp + sizeof sa - sizeof sa.sa_data, len));
		}
		else {
		    datsv = sv_mortalcopy(&sv_undef);
		}
		
		EXTEND(sp, 2);
		PUSHs(famsv);
		PUSHs(datsv);
	    }
	}

