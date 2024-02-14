/* Automatically generated by the Kremlin tool */



#ifndef __L0_X509_DeviceIDCRI_H
#define __L0_X509_DeviceIDCRI_H

#if defined(__cplusplus)
extern "C" {
#endif

#include "L0_X509_DeviceIDCRI_Subject.h"
#include "L0_X509_DeviceIDCRI_Attributes.h"
#include "ASN1_X509.h"
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "LowStar_Printf.h"
#include <string.h>

typedef struct deviceIDCRI_payload_t_s
{
  int32_t deviceIDCRI_version;
  deviceIDCRI_subject_payload_t deviceIDCRI_subject;
  subjectPublicKeyInfo_payload_t deviceIDCRI_subjectPKInfo;
  deviceIDCRI_attributes_t deviceIDCRI_attributes;
}
deviceIDCRI_payload_t;

uint32_t
len_of_deviceIDCRI_payload(
  int32_t version,
  character_string_t s_common,
  character_string_t s_org,
  character_string_t s_country
);

typedef deviceIDCRI_payload_t deviceIDCRI_t;

uint32_t
len_of_deviceIDCRI(
  int32_t version,
  character_string_t s_common,
  character_string_t s_org,
  character_string_t s_country
);

uint32_t
serialize32_deviceIDCRI_payload_backwards(
  deviceIDCRI_payload_t x,
  uint8_t *input,
  uint32_t pos
);

uint32_t serialize32_deviceIDCRI_backwards(deviceIDCRI_payload_t x, uint8_t *b, uint32_t pos);

deviceIDCRI_payload_t
x509_get_deviceIDCRI(
  int32_t version,
  character_string_t s_common,
  character_string_t s_org,
  character_string_t s_country,
  int32_t ku,
  FStar_Bytes_bytes deviceIDPub
);

#if defined(__cplusplus)
}
#endif

#define __L0_X509_DeviceIDCRI_H_DEFINED
#endif
