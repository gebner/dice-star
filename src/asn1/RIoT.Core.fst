/// Reference: https://github.com/microsoft/RIoT/blob/master/Reference/RIoT/Core/RIoT.cpp
module RIoT.Core

open LowStar.Comment

module Fail = LowStar.Failure
module B = LowStar.Buffer
module IB = LowStar.ImmutableBuffer
module HS  = FStar.HyperStack
module HST = FStar.HyperStack.ST

open Lib.IntTypes
module S = Spec.Hash.Definitions
module H = Hacl.Hash.Definitions

module ECDSA = Hacl.Impl.ECDSA
// module P256 = Hacl.Impl.P256
module Ed25519 = Hacl.Ed25519
module Curve25519 = Hacl.Curve25519_51
module HKDF = Hacl.HKDF

// module HW = HWAbstraction

open S
open H
open RIoT.Definitions

open ASN1.Spec
open ASN1.Low
open X509
open RIoT.X509
open RIoT.Base
open RIoT.Declassify

module B32 = FStar.Bytes

#set-options "--query_stats --z3rlimit 16"
let _ = assert (length_of_oid OID_EC_GRP_SECP256R1 == 6)

// #push-options "--z3rlimit 32"
// let label_DeviceID_l: list byte_sec = [u8 0; u8 0]
// let label_DeviceID_len
// : len: size_t { valid_hkdf_lbl_len len /\
//                 v len == List.length label_DeviceID_l }
// = assert_norm (valid_hkdf_lbl_len 2ul);
//   assert_norm (List.length label_DeviceID_l == 2);
//   2ul
// let label_DeviceID
// : ib:IB.libuffer uint8 (v label_DeviceID_len) (Seq.createL label_DeviceID_l)
//   { IB.frameOf ib == HS.root /\ IB.recallable ib /\
//     valid_hkdf_lbl_len (B.len ib) }
// = assert_norm (valid_hkdf_lbl_len label_DeviceID_len);
//   IB.igcmalloc_of_list HS.root label_DeviceID_l

// let label_AliasKey_l: list byte_sec = [u8 1; u8 1]
// let label_AliasKey_len
// : len: size_t { valid_hkdf_lbl_len len /\
//                 v len == List.length label_AliasKey_l }
// = assert_norm (valid_hkdf_lbl_len 2ul);
//   assert_norm (List.length label_AliasKey_l == 2);
//   2ul
// let label_AliasKey
// : ib:IB.libuffer uint8 (v label_AliasKey_len) (Seq.createL label_AliasKey_l)
//   { IB.frameOf ib == HS.root /\ IB.recallable ib /\
//     valid_hkdf_lbl_len (B.len ib) }
// = assert_norm (valid_hkdf_lbl_len label_AliasKey_len);
//   IB.igcmalloc_of_list HS.root label_AliasKey_l
// #push-options

unfold
let valid_ed25519_sign_mag_length
  (l: nat)
= 64 + l <= max_size_t

#restart-solver
#push-options "--query_stats --z3rlimit 512 --fuel 2 --ifuel 1"
let riot_main
(* inputs *)
  (cdi : B.lbuffer byte_sec 32)
  (fwid: B.lbuffer byte_sec 32)
  (version: datatype_of_asn1_type INTEGER)
  (aliasKeyTBS_template_len: size_t)
  (aliasKeyTBS_template: B.lbuffer byte_pub (v aliasKeyTBS_template_len))
  (deviceID_label_len: size_t)
  (deviceID_label: B.lbuffer byte_sec (v deviceID_label_len))
  (aliasKey_label_len: size_t)
  (aliasKey_label: B.lbuffer byte_sec (v aliasKey_label_len))
(* outputs *)
  (aliasKeyCRT_len: size_t)
  (aliasKeyCRT_buf: B.lbuffer byte_pub (v aliasKeyCRT_len))
  (aliasKey_pub: B.lbuffer byte_pub 32)
  (aliasKey_priv: B.lbuffer uint8 32)
: HST.Stack unit
  (requires fun h ->
    B.(all_live h [buf cdi;
                   buf fwid;
                   buf aliasKeyTBS_template;
                   buf deviceID_label;
                   buf aliasKey_label;
                   buf aliasKeyCRT_buf;
                   buf aliasKey_pub;
                   buf aliasKey_priv]) /\
    B.(all_disjoint [loc_buffer cdi;
                     loc_buffer fwid;
                     loc_buffer aliasKeyTBS_template;
                     loc_buffer deviceID_label;
                     loc_buffer aliasKey_label;
                     loc_buffer aliasKeyCRT_buf;
                     loc_buffer aliasKey_pub;
                     loc_buffer aliasKey_priv]) /\
   valid_hkdf_lbl_len deviceID_label_len /\
   valid_hkdf_lbl_len aliasKey_label_len /\
   valid_aliasKeyTBS_ingredients aliasKeyTBS_template_len version /\
   valid_aliasKeyCRT_ingredients (len_of_AliasKeyTBS aliasKeyTBS_template_len version) /\
   v aliasKeyCRT_len == length_of_AliasKeyCRT (len_of_AliasKeyTBS aliasKeyTBS_template_len version)
   )
   (ensures fun h0 _ h1 -> True /\
     B.(modifies (loc_buffer aliasKeyCRT_buf `loc_union` loc_buffer aliasKey_pub `loc_union` loc_buffer aliasKey_priv) h0 h1) /\
    ((B.as_seq h1 aliasKey_pub  <: lbytes_pub 32),
     (B.as_seq h1 aliasKey_priv <: lbytes_sec 32)) == derive_AliasKey_spec
                                                        (B.as_seq h0 cdi)
                                                        (B.as_seq h0 fwid)
                                                        aliasKey_label_len                                                        (B.as_seq h0 aliasKey_label) /\
    (let deviceID_pub_seq, deviceID_priv_seq = derive_DeviceID_spec
                                                 (B.as_seq h0 cdi)
                                                 (deviceID_label_len)
                                                 (B.as_seq h0 deviceID_label) in
     let aliasKeyTBS: aliasKeyTBS_t_inbound aliasKeyTBS_template_len = create_aliasKeyTBS_spec
                                                                         (aliasKeyTBS_template_len)
                                                                         (B.as_seq h0 aliasKeyTBS_template)
                                                                         (version)
                                                                         (B.as_seq h0 fwid)
                                                                         (deviceID_pub_seq)
                                                                         (B.as_seq h0 aliasKey_pub)
                                                                         in
     let aliasKeyTBS_seq = serialize_aliasKeyTBS_sequence_TLV aliasKeyTBS_template_len `serialize` aliasKeyTBS in
     let aliasKeyTBS_len = len_of_AliasKeyTBS aliasKeyTBS_template_len version in
     (* Prf *) lemma_serialize_aliasKeyTBS_sequence_TLV_size_exact aliasKeyTBS_template_len aliasKeyTBS;
    (let aliasKeyCRT: aliasKeyCRT_t_inbound aliasKeyTBS_len = sign_and_finalize_aliasKeyCRT_spec
                                                                (deviceID_priv_seq)
                                                                (aliasKeyTBS_len)
                                                                (aliasKeyTBS_seq) in
     B.as_seq h1 aliasKeyCRT_buf == serialize_aliasKeyCRT_sequence_TLV aliasKeyTBS_len `serialize` aliasKeyCRT)) /\
     True
   )
=
 HST.push_frame ();

(* Derive DeviceID *)
  let deviceID_pub : B.lbuffer byte_pub 32 = B.alloca 0x00uy    32ul in
  let deviceID_priv: B.lbuffer byte_sec 32 = B.alloca (u8 0x00) 32ul in
  derive_DeviceID
    (* pub *) deviceID_pub
    (* priv*) deviceID_priv
    (* cdi *) cdi
    (* lbl *) deviceID_label_len deviceID_label;

(* Derive AliasKey *)
  derive_AliasKey
    (* pub *) aliasKey_pub
    (* priv*) aliasKey_priv
    (* cdi *) cdi
    (* fwid*) fwid
    (* lbl *) aliasKey_label_len aliasKey_label;

(* Create AliasKeyTBS *)
  let aliasKeyTBS_len: asn1_TLV_int32_of_type SEQUENCE = len_of_AliasKeyTBS aliasKeyTBS_template_len version in
  let aliasKeyTBS_buf: B.lbuffer byte_pub (v aliasKeyTBS_len) = B.alloca 0x00uy aliasKeyTBS_len in
  create_aliasKeyTBS
    (* fwid   *) fwid
    (* version*) version
    (*deviceID*) deviceID_pub
    (*aliasKey*) aliasKey_pub
    (*template*) aliasKeyTBS_template_len
                 aliasKeyTBS_template
    (*   tbs  *) aliasKeyTBS_len
                 aliasKeyTBS_buf;

(* Sign AliasKeyTBS and Finalize AliasKeyCRT *)
  sign_and_finalize_aliasKeyCRT
    (*signing key*) deviceID_priv
    (*AliasKeyTBS*) aliasKeyTBS_len
                    aliasKeyTBS_buf
    (*AliasKeyCRT*) aliasKeyCRT_len
                    aliasKeyCRT_buf;

  HST.pop_frame()
#pop-options
