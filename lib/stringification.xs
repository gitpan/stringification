/*  You may distribute under the terms of either the GNU General Public License
 *  or the Artistic License (the same terms as Perl itself)
 *
 *  (C) Paul Evans, 2011-2012 -- leonerd@leonerd.org.uk
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define __PACKAGE__ "stringification"
#define __PACKAGE_LEN__ (sizeof(__PACKAGE__)-1)

static int init_done = 0;

static int is_enabled(pTHX)
{
  SV *hint;

#ifdef cop_hints_fetch_pvn
  hint = cop_hints_fetch_pvn(PL_curcop, __PACKAGE__, __PACKAGE_LEN__, 0, 0);
#elif PERL_VERSION >= 9 || (PERL_VERSION == 9 && PERL_SUBVERSION >= 5)
  hint = Perl_refcounted_he_fetch(aTHX_ PL_curcop->cop_hints_hash,
            NULL, __PACKAGE__, __PACKAGE_LEN__, 0, 0);
#else
 SV **val = hv_fetch(GvHV(PL_hintgv), __PACKAGE__, __PACKAGE_LEN__, 0);
  if (!val)
    return 1;
  hint = *val;
#endif
  return !(hint && SvOK(hint));
}

static int is_allowed(SV *arg)
{
  if(!SvROK(arg))
    return 1;
  if(sv_isobject(arg))
    return 1;

  return 0;
}

OP *(*real_pp_stringify)(pTHX);
OP *(*real_pp_uc)(pTHX);
OP *(*real_pp_ucfirst)(pTHX);
OP *(*real_pp_lc)(pTHX);
OP *(*real_pp_lcfirst)(pTHX);
OP *(*real_pp_quotemeta)(pTHX);
OP *(*real_pp_match)(pTHX);

PP(pp_stringification_top1) {
  dSP;

  if(is_allowed(sp[0]) || is_enabled(aTHX)) {
    switch(PL_op->op_type) {
      case OP_STRINGIFY:
        return (*real_pp_stringify)(aTHX);
      case OP_UC:
        return (*real_pp_uc)(aTHX);
      case OP_UCFIRST:
        return (*real_pp_ucfirst)(aTHX);
      case OP_LC:
        return (*real_pp_lc)(aTHX);
      case OP_LCFIRST:
        return (*real_pp_lcfirst)(aTHX);
      case OP_QUOTEMETA:
        return (*real_pp_quotemeta)(aTHX);
      case OP_MATCH:
        return (*real_pp_match)(aTHX);
    }
  }

  croak("Attempted to %s a reference", PL_op_desc[PL_op->op_type]);
}

OP *(*real_pp_concat)(pTHX);

PP(pp_stringification_concat) {
  dSP;

  if((is_allowed(sp[0]) && is_allowed(sp[-1])) || is_enabled(aTHX)) {
    return (*real_pp_concat)(aTHX);
  }

  croak("Attempted to %s a reference", PL_op_desc[PL_op->op_type]);
}

OP *(*real_pp_split)(pTHX);

PP(pp_stringification_split) {
  dSP;

  if(is_allowed(sp[-1]) || is_enabled(aTHX)) {
    return (*real_pp_split)(aTHX);
  }

  croak("Attempted to %s a reference", PL_op_desc[PL_op->op_type]);
}

OP *(*real_pp_join)(pTHX);
OP *(*real_pp_print)(pTHX);

PP(pp_stringification_all) {
  dSP; dMARK;
  SV **svp;

  if(!is_enabled(aTHX)) {
    for(svp = MARK; svp <= SP; svp++) {
      if(!is_allowed(*svp))
        croak("Attempted to %s a reference", PL_op_desc[PL_op->op_type]);
    }
  }

  switch(PL_op->op_type) {
    case OP_JOIN:
      return (*real_pp_join)(aTHX);
    case OP_PRINT:
    case OP_SAY: /* OP_SAY and OP_PRINT share the same function */
      return (*real_pp_print)(aTHX);
  }
}

MODULE = stringification       PACKAGE = stringification

BOOT:
if(!init_done++) {
  /* top1 */
  real_pp_stringify = PL_ppaddr[OP_STRINGIFY];
  PL_ppaddr[OP_STRINGIFY] = &Perl_pp_stringification_top1;
  real_pp_uc = PL_ppaddr[OP_UC];
  PL_ppaddr[OP_UC] = &Perl_pp_stringification_top1;
  real_pp_ucfirst = PL_ppaddr[OP_UCFIRST];
  PL_ppaddr[OP_UCFIRST] = &Perl_pp_stringification_top1;
  real_pp_lc = PL_ppaddr[OP_LC];
  PL_ppaddr[OP_LC] = &Perl_pp_stringification_top1;
  real_pp_lcfirst = PL_ppaddr[OP_LCFIRST];
  PL_ppaddr[OP_LCFIRST] = &Perl_pp_stringification_top1;
  real_pp_quotemeta = PL_ppaddr[OP_QUOTEMETA];
  PL_ppaddr[OP_QUOTEMETA] = &Perl_pp_stringification_top1;
  real_pp_match = PL_ppaddr[OP_MATCH];
  PL_ppaddr[OP_MATCH] = &Perl_pp_stringification_top1;

  real_pp_concat = PL_ppaddr[OP_CONCAT];
  PL_ppaddr[OP_CONCAT] = &Perl_pp_stringification_concat;

  real_pp_split = PL_ppaddr[OP_SPLIT];
  PL_ppaddr[OP_SPLIT] = &Perl_pp_stringification_split;

  /* all */
  real_pp_join = PL_ppaddr[OP_JOIN];
  PL_ppaddr[OP_JOIN] = &Perl_pp_stringification_all;
  real_pp_print = PL_ppaddr[OP_PRINT];
  PL_ppaddr[OP_PRINT] = &Perl_pp_stringification_all;
  PL_ppaddr[OP_SAY]   = &Perl_pp_stringification_all; /* OP_SAY and OP_PRINT share the same function */
}
