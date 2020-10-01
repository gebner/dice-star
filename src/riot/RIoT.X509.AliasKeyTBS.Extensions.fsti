module RIoT.X509.AliasKeyTBS.Extensions

open ASN1.Spec
open ASN1.Low
open X509
open RIoT.X509.Base
open RIoT.X509.FWID
open RIoT.X509.CompositeDeviceID
open RIoT.X509.Extension
open RIoT.X509.AliasKeyTBS.Extensions.BasicConstraints
open RIoT.X509.AliasKeyTBS.Extensions.AuthKeyIdentifier
open RIoT.X509.AliasKeyTBS.Extensions.ExtendedKeyUsage
open FStar.Integers

module B32 = FStar.Bytes

#set-options "--z3rlimit 128 --fuel 0 --ifuel 0 --using_facts_from '* -FStar.Tactics -FStar.Reflection'"

(* Extensions of the AliasKey Certificate
 * Includes the RIoT Extension (`CompositeDeviceID`) and others
 * This is the SEQUENCE under the outmost explicit tag
 * Contains SEQUENCEs of individual extensions ({extID, extValue})
 * [3] {               <--- The outmost explicit tag
 *   SEQUENCE {        <--- *HERE*
 *     SEQUENCE {      <--- Individual extension
 *       extID   : OID
 *       extValue: OCTET STRING {..}  <--- Actual extension content enveloped by tag OCTET STRING
 *     };
 *     SEQUENCE {..};
 *     SEQUENCE {..};  <--- Other extensions
 *   }
 * }
 *)

type aliasKeyTBS_extensions_payload_t = {
  (* More extensions could be added here.
   * For example:
   * aliasKeyTBS_extensions_key_usage: key_usage_t;
   *)
  aliasKeyTBS_extensions_key_usage: key_usage_t;
  aliasKeyTBS_extensions_extendedKeyUsage: aliasKeyTBS_extensions_extendedKeyUsage_t;
                                           //P.norm
                                           // (norm_steps_x509_keyPurposeIDs (`%aliasKeyCrt_extendedKeyUsage_oids))
                                           // (x509_ext_key_usage_t aliasKeyCrt_extendedKeyUsage_oids);
  aliasKeyTBS_extensions_basicConstraints: aliasKeyTBS_extensions_basicConstraints_t;
  aliasKeyTBS_extensions_authKeyID: aliasKeyTBS_extensions_authKeyID_t;
  aliasKeyTBS_extensions_riot: riot_extension_t
}

noextract
let parse_aliasKeyTBS_extensions_payload_kind
: parser_kind
= parse_asn1_envelop_tag_with_TLV_kind SEQUENCE
  `and_then_kind`
  X509.BasicFields.Extension2.parse_x509_extension_kind
  `and_then_kind`
  X509.BasicFields.Extension2.parse_x509_extension_kind
  `and_then_kind`
  X509.BasicFields.Extension2.parse_x509_extension_kind
  `and_then_kind`
  parse_x509_extension_sequence_TLV_kind

(* Parser Specification for VALUE *)
noextract
val parse_aliasKeyTBS_extensions_payload
: parser parse_aliasKeyTBS_extensions_payload_kind (aliasKeyTBS_extensions_payload_t)

(* Serializer Specification for VALUE *)
noextract
val serialize_aliasKeyTBS_extensions_payload
: serializer (parse_aliasKeyTBS_extensions_payload)

(* Lemmas for serialization *)
val lemma_serialize_aliasKeyTBS_extensions_payload_unfold
  (x: aliasKeyTBS_extensions_payload_t)
: Lemma (
  serialize_aliasKeyTBS_extensions_payload `serialize` x ==
  (serialize_x509_key_usage `serialize` x.aliasKeyTBS_extensions_key_usage)
  `Seq.append`
  (serialize_aliasKeyTBS_extensions_extendedKeyUsage
                            `serialize` x.aliasKeyTBS_extensions_extendedKeyUsage)
  `Seq.append`
  (serialize_aliasKeyTBS_extensions_basicConstraints
                            `serialize` x.aliasKeyTBS_extensions_basicConstraints)
  `Seq.append`
  (serialize_aliasKeyTBS_extensions_authKeyID
                            `serialize` x.aliasKeyTBS_extensions_authKeyID)
  `Seq.append`
  (serialize_riot_extension `serialize` x.aliasKeyTBS_extensions_riot)
)

let valid_aliasKeyTBS_extensions_payload_ingredients
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Type0
= length_of_x509_key_usage ku +
  length_of_aliasKeyTBS_extensions_extendedKeyUsage () +
  length_of_aliasKeyTBS_extensions_basicConstraints () +
  length_of_aliasKeyTBS_extensions_authKeyID () +
  length_of_riot_extension version
  <= asn1_value_length_max_of_type SEQUENCE

val lemma_aliasKeyTBS_extensions_payload_ingredients_valid
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Lemma (
  valid_aliasKeyTBS_extensions_payload_ingredients ku version
)

let length_of_aliasKeyTBS_extensions_payload
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: GTot (asn1_value_length_of_type SEQUENCE)
= lemma_aliasKeyTBS_extensions_payload_ingredients_valid ku version;
  length_of_x509_key_usage ku +
  length_of_aliasKeyTBS_extensions_extendedKeyUsage () +
  length_of_aliasKeyTBS_extensions_basicConstraints () +
  length_of_aliasKeyTBS_extensions_authKeyID () +
  length_of_riot_extension version

let len_of_aliasKeyTBS_extensions_payload
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Tot (len: asn1_value_int32_of_type SEQUENCE
            { v len == length_of_aliasKeyTBS_extensions_payload ku version })
= lemma_aliasKeyTBS_extensions_payload_ingredients_valid ku version;
  len_of_x509_key_usage ku +
  len_of_aliasKeyTBS_extensions_extendedKeyUsage () +
  len_of_aliasKeyTBS_extensions_basicConstraints () +
  len_of_aliasKeyTBS_extensions_authKeyID () +
  len_of_riot_extension version

val lemma_serialize_aliasKeyTBS_extensions_payload_size
  (x: aliasKeyTBS_extensions_payload_t)
: Lemma (
  lemma_serialize_aliasKeyTBS_extensions_payload_unfold x;
    lemma_serialize_x509_key_usage_size_exact x.aliasKeyTBS_extensions_key_usage;
    lemma_x509_keyPurposeIDs_unique aliasKeyCrt_extendedKeyUsage_oids;
    lemma_serialize_aliasKeyTBS_extensions_extendedKeyUsage_size_exact
                                              x.aliasKeyTBS_extensions_extendedKeyUsage;
    lemma_serialize_aliasKeyTBS_extensions_basicConstraints_size_exact
                                              x.aliasKeyTBS_extensions_basicConstraints;
    lemma_serialize_aliasKeyTBS_extensions_authKeyID_size_exact
                                              x.aliasKeyTBS_extensions_authKeyID;
    lemma_serialize_riot_extension_size_exact x.aliasKeyTBS_extensions_riot;
  (* unfold *)
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions_payload)      x ==
  length_of_opaque_serialization (serialize_x509_key_usage)              x.aliasKeyTBS_extensions_key_usage +
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions_extendedKeyUsage)
                                                                         x.aliasKeyTBS_extensions_extendedKeyUsage +
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions_basicConstraints)
                                                                         x.aliasKeyTBS_extensions_basicConstraints +
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions_authKeyID)
                                                                         x.aliasKeyTBS_extensions_authKeyID +
  length_of_opaque_serialization (serialize_riot_extension)              x.aliasKeyTBS_extensions_riot /\
  (* exact size *)
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions_payload)      x
  == length_of_aliasKeyTBS_extensions_payload
       (snd x.aliasKeyTBS_extensions_key_usage)
       (x.aliasKeyTBS_extensions_riot.x509_extValue_riot.riot_version)
)

(*
 * SEQUENCE serializer
 *)
(* aliasKeyTBS_extensions: inbound sub type for SEQUENCE TLV*)
let aliasKeyTBS_extensions_t
= inbound_sequence_value_of (serialize_aliasKeyTBS_extensions_payload)

(* aliasKeyTBS_extensions: parser for TLV *)
noextract
let parse_aliasKeyTBS_extensions
: parser (parse_asn1_envelop_tag_with_TLV_kind SEQUENCE) (aliasKeyTBS_extensions_t)
= aliasKeyTBS_extensions_t
  `coerce_parser`
  parse_asn1_sequence_TLV (serialize_aliasKeyTBS_extensions_payload)

(* aliasKeyTBS_extensions: serializer for TLV *)
noextract
let serialize_aliasKeyTBS_extensions
: serializer (parse_aliasKeyTBS_extensions)
= coerce_parser_serializer
  (* t *) (parse_aliasKeyTBS_extensions)
  (* s *) (serialize_asn1_sequence_TLV (serialize_aliasKeyTBS_extensions_payload))
  (*prf*) ()

(* aliasKeyTBS_extensions: lemmas for TLV *)
val lemma_serialize_aliasKeyTBS_extensions_unfold
  (x: aliasKeyTBS_extensions_t)
: Lemma ( predicate_serialize_asn1_sequence_TLV_unfold serialize_aliasKeyTBS_extensions_payload x )

val lemma_serialize_aliasKeyTBS_extensions_size
  (x: aliasKeyTBS_extensions_t)
: Lemma ( predicate_serialize_asn1_sequence_TLV_size serialize_aliasKeyTBS_extensions_payload x )

let valid_aliasKeyTBS_extensions_ingredients
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Type0
= valid_aliasKeyTBS_extensions_payload_ingredients ku version /\
  length_of_aliasKeyTBS_extensions_payload ku version
  <= asn1_value_length_max_of_type SEQUENCE

val lemma_aliasKeyTBS_extensions_ingredients_valid
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Lemma (
  valid_aliasKeyTBS_extensions_ingredients ku version
)

let valid_aliasKeyTBS_extensions
  (x: aliasKeyTBS_extensions_t)
: Type0
= valid_aliasKeyTBS_extensions_ingredients
          (snd x.aliasKeyTBS_extensions_key_usage)
          (x.aliasKeyTBS_extensions_riot.x509_extValue_riot.riot_version)

val lemma_aliasKeyTBS_extensions_valid
  (x: aliasKeyTBS_extensions_t)
: Lemma (
  valid_aliasKeyTBS_extensions x
)

let length_of_aliasKeyTBS_extensions
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: GTot (asn1_TLV_length_of_type SEQUENCE)
= lemma_aliasKeyTBS_extensions_ingredients_valid ku version;
  length_of_TLV SEQUENCE
    (length_of_aliasKeyTBS_extensions_payload ku version)

let len_of_aliasKeyTBS_extensions
  (ku: key_usage_payload_t)
  (version: datatype_of_asn1_type INTEGER)
: Tot (len: asn1_TLV_int32_of_type SEQUENCE
            { v len == length_of_aliasKeyTBS_extensions ku version })
= lemma_aliasKeyTBS_extensions_ingredients_valid ku version;
  len_of_TLV SEQUENCE
    (len_of_aliasKeyTBS_extensions_payload ku version)

val lemma_serialize_aliasKeyTBS_extensions_size_exact
  (x: aliasKeyTBS_extensions_t)
: Lemma (
  Classical.forall_intro_2 lemma_aliasKeyTBS_extensions_ingredients_valid;
  (* exact size *)
  length_of_opaque_serialization (serialize_aliasKeyTBS_extensions) x
  == length_of_aliasKeyTBS_extensions
       (snd x.aliasKeyTBS_extensions_key_usage)
       (x.aliasKeyTBS_extensions_riot.x509_extValue_riot.riot_version)
)


(*
 * Low Level Serializer
 *)
(* aliasKeyTBS_extensions: low level serializer for VALUE *)
val serialize32_aliasKeyTBS_extensions_payload_backwards
: serializer32_backwards (serialize_aliasKeyTBS_extensions_payload)

(* aliasKeyTBS_extensions: low level serializer for SEQUENCE TLV *)
val serialize32_aliasKeyTBS_extensions_backwards
: serializer32_backwards (serialize_aliasKeyTBS_extensions)

let x509_get_aliasKeyTBS_extensions
  (ku: key_usage_payload_t)
  (keyID: datatype_of_asn1_type OCTET_STRING {dfst keyID == 20ul})
  (version: datatype_of_asn1_type INTEGER)
  (fwid: B32.lbytes32 32ul)
  (deviceIDPub: B32.lbytes32 32ul)
: Tot (aliasKeyTBS_extensions_t)
=
  (* Prf*) Classical.forall_intro_2 lemma_aliasKeyTBS_extensions_ingredients_valid;

  let key_usage = x509_get_key_usage ku in
  (* Prf *) lemma_serialize_x509_key_usage_size_exact key_usage;

  let extendedKeyUsage = x509_get_aliasKeyTBS_extensions_extendedKeyUsage
  (*TODO: FIXME: Maybe move criticality to params *) true in
  (* Prf *) lemma_serialize_aliasKeyTBS_extensions_extendedKeyUsage_size_exact extendedKeyUsage;

  let basicConstraints = x509_get_aliasKeyTBS_extensions_basicConstraints
  (*TODO: FIXME: Maybe move criticality to params *) false in
  (* Prf *) lemma_serialize_aliasKeyTBS_extensions_basicConstraints_size_exact basicConstraints;

  let authKeyID = x509_get_aliasKeyTBS_extensions_authKeyID
  (*TODO: FIXME: Maybe move criticality to params *) true
                                                     keyID in
  (* Prf *)  lemma_serialize_aliasKeyTBS_extensions_authKeyID_size_exact authKeyID;

  let riot_extension= x509_get_riot_extension
                        version
                        fwid
                        deviceIDPub in
  (* Prf *) lemma_serialize_riot_extension_size_exact riot_extension;

  let aliasKeyTBS_extensions: aliasKeyTBS_extensions_payload_t = {
    aliasKeyTBS_extensions_key_usage        = key_usage;
    aliasKeyTBS_extensions_extendedKeyUsage = extendedKeyUsage;
    aliasKeyTBS_extensions_basicConstraints = basicConstraints;
    aliasKeyTBS_extensions_authKeyID        = authKeyID;
    aliasKeyTBS_extensions_riot             = riot_extension
  } in
  (* Prf *) lemma_serialize_aliasKeyTBS_extensions_payload_unfold aliasKeyTBS_extensions;
  (* Prf *) lemma_serialize_aliasKeyTBS_extensions_payload_size   aliasKeyTBS_extensions;
  // (* Prf *) assert ( length_of_opaque_serialization serialize_aliasKeyTBS_extensions_payload aliasKeyTBS_extensions
  //                    <= asn1_value_length_max_of_type SEQUENCE );

(*return*) aliasKeyTBS_extensions
