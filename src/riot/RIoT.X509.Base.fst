module RIoT.X509.Base
open ASN1.Spec
open RIoT.Base
open X509

module B32 = FStar.Bytes

#set-options "--z3rlimit 32 --fuel 0 --ifuel 0"

let aliasKeyCrt_key_usage: key_usage_payload_t
= normalize_term (x509_KU_KEY_CERT_SIGN
  (*
   * Adding more key usage bits for test only. According to the
   * [reference implementation](https://github.com/microsoft/RIoT/blob/master/Reference/RIoT/RIoTCrypt/include/x509bldr.h#L22),
   * Only the KeyCertSign bit is set.
   *)
  `op_ku_with` x509_KU_DIGITAL_SIGNATURE
  `op_ku_with` x509_KU_CRL_SIGN)

let sha1_digest_to_octet_string_spec
  (s: lbytes_pub 20)
: GTot (x: datatype_of_asn1_type OCTET_STRING
           { dfst x == 20ul /\
             B32.reveal (dsnd x) == s })
= assert_norm (Seq.length s < pow2 32);
  let s32: B32.lbytes 20 = B32.hide s in
  B32.reveal_hide s;
  assert (B32.reveal s32 == s);
  (|20ul, s32|)

type deviceIDCSR_ingredients_t = {
  deviceIDCSR_ku: key_usage_payload_t;
  deviceIDCSR_version: datatype_of_asn1_type INTEGER;
  deviceIDCSR_s_common:  x509_RDN_x520_attribute_string_t COMMON_NAME  IA5_STRING;
  deviceIDCSR_s_org:     x509_RDN_x520_attribute_string_t ORGANIZATION IA5_STRING;
  deviceIDCSR_s_country: x509_RDN_x520_attribute_string_t COUNTRY      PRINTABLE_STRING
}

type aliasKeyCRT_ingredients_t = {
  aliasKeyCrt_version: x509_version_t;
  aliasKeyCrt_serialNumber: x509_serialNumber_t;
  aliasKeyCrt_i_common:  x509_RDN_x520_attribute_string_t COMMON_NAME  IA5_STRING;
  aliasKeyCrt_i_org:     x509_RDN_x520_attribute_string_t ORGANIZATION IA5_STRING;
  aliasKeyCrt_i_country: x509_RDN_x520_attribute_string_t COUNTRY      PRINTABLE_STRING;
  aliasKeyCrt_notBefore: datatype_of_asn1_type Generalized_Time;
  aliasKeyCrt_notAfter : datatype_of_asn1_type Generalized_Time;
  aliasKeyCrt_s_common:  x509_RDN_x520_attribute_string_t COMMON_NAME  IA5_STRING;
  aliasKeyCrt_s_org:     x509_RDN_x520_attribute_string_t ORGANIZATION IA5_STRING;
  aliasKeyCrt_s_country: x509_RDN_x520_attribute_string_t COUNTRY      PRINTABLE_STRING;
  aliasKeyCrt_ku: key_usage_payload_t;
  aliasKeyCrt_riot_version: datatype_of_asn1_type INTEGER;
}

// inline_for_extraction
// let alg_DeviceID = AlgID_Ed25519

// inline_for_extraction
// let alg_AliasKey = AlgID_Ed25519
