/* Automatically generated by the Kremlin tool */



#ifndef __L0_X509_FWID_H
#define __L0_X509_FWID_H

#if defined(__cplusplus)
extern "C" {
#endif

#include "ASN1_X509.h"
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "LowStar_Printf.h"
#include <string.h>

typedef struct fwid_payload_t_s
{
  oid_t fwid_hashAlg;
  octet_string_t fwid_value;
}
fwid_payload_t;

typedef fwid_payload_t fwid_t;

uint32_t serialize32_fwid_payload_backwards(fwid_payload_t x, uint8_t *input, uint32_t pos);

uint32_t serialize32_fwid_backwards(fwid_payload_t x, uint8_t *b, uint32_t pos);

fwid_payload_t x509_get_fwid(FStar_Bytes_bytes fwid);

#if defined(__cplusplus)
}
#endif

#define __L0_X509_FWID_H_DEFINED
#endif
