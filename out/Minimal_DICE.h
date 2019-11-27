/* 
  This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
  KreMLin invocation: krml -no-prefix Minimal.DICE ./src/Minimal.DICE.fst -skip-compilation -tmpdir ./out -I ./src -I /home/zhetao/Sources/hacl-star/specs -I /home/zhetao/Sources/hacl-star/specs/lemmas -I /home/zhetao/Sources/hacl-star/code/hash -I /home/zhetao/Sources/hacl-star/code/hkdf -I /home/zhetao/Sources/hacl-star/code/hmac -I /home/zhetao/Sources/hacl-star/code/curve25519 -I /home/zhetao/Sources/hacl-star/code/ed25519 -I /home/zhetao/Sources/hacl-star/lib -I /home/zhetao/Sources/hacl-star/providers/evercrypt -warn-error +11
  F* version: 953b2211
  KreMLin version: e324b7e6
 */

#include "kremlib.h"
#ifndef __Minimal_DICE_H
#define __Minimal_DICE_H

#include "Hacl_Hash_SHA1.h"
#include "Hacl_HMAC.h"
#include "HWIface.h"
#include "Lib_IntTypes.h"
#include "Spec_Hash_Definitions.h"
#include "Hacl_Hash_SHA2.h"
#include "kremlinit.h"
#include "Prims.h"
#include "C.h"
#include "FStar.h"


void
(*dice_hash(Spec_Hash_Definitions_hash_alg alg1))(
  Lib_IntTypes_sec_int_t____ *x0,
  uint32_t x1,
  Lib_IntTypes_sec_int_t____ *x2
);

void
(*dice_hmac(Spec_Hash_Definitions_hash_alg alg1))(
  Lib_IntTypes_sec_int_t____ *x0,
  Lib_IntTypes_sec_int_t____ *x1,
  uint32_t x2,
  Lib_IntTypes_sec_int_t____ *x3,
  uint32_t x4
);

void
dice_on_stack(HWIface_state st, uint32_t riot_size, Lib_IntTypes_sec_int_t____ *riot_binary);

HWIface_state dice_main(uint32_t riot_size, Lib_IntTypes_sec_int_t____ *riot_binary);

extern uint32_t riot_size;

extern Lib_IntTypes_sec_int_t____ *riot_binary;

exit_code main();

#define __Minimal_DICE_H_DEFINED
#endif
