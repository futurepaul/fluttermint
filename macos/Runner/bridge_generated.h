#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_BridgeGuardianInfo {
  struct wire_uint_8_list *name;
  struct wire_uint_8_list *address;
  bool online;
} wire_BridgeGuardianInfo;

typedef struct wire_list_bridge_guardian_info {
  struct wire_BridgeGuardianInfo *ptr;
  int32_t len;
} wire_list_bridge_guardian_info;

typedef struct wire_BridgeFederationInfo {
  struct wire_uint_8_list *name;
  struct wire_uint_8_list *network;
  bool current;
  struct wire_list_bridge_guardian_info *guardians;
} wire_BridgeFederationInfo;

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_init(int64_t port_, struct wire_uint_8_list *path);

void wire_join_federation(int64_t port_, struct wire_uint_8_list *config_url);

void wire_leave_federation(int64_t port_);

void wire_balance(int64_t port_);

void wire_pay(int64_t port_, struct wire_uint_8_list *bolt11);

void wire_invoice(int64_t port_, uint64_t amount, struct wire_uint_8_list *description);

void wire_fetch_payment(int64_t port_, struct wire_uint_8_list *payment_hash);

void wire_list_payments(int64_t port_);

void wire_configured_status(int64_t port_);

void wire_connection_status(int64_t port_);

void wire_network(int64_t port_);

void wire_calculate_fee(int64_t port_, struct wire_uint_8_list *bolt11);

void wire_list_federations(int64_t port_);

void wire_switch_federation(int64_t port_, struct wire_BridgeFederationInfo *_federation);

void wire_decode_invoice(int64_t port_, struct wire_uint_8_list *bolt11);

struct wire_BridgeFederationInfo *new_box_autoadd_bridge_federation_info_0(void);

struct wire_list_bridge_guardian_info *new_list_bridge_guardian_info_0(int32_t len);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void free_WireSyncReturnStruct(struct WireSyncReturnStruct val);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_init);
    dummy_var ^= ((int64_t) (void*) wire_join_federation);
    dummy_var ^= ((int64_t) (void*) wire_leave_federation);
    dummy_var ^= ((int64_t) (void*) wire_balance);
    dummy_var ^= ((int64_t) (void*) wire_pay);
    dummy_var ^= ((int64_t) (void*) wire_invoice);
    dummy_var ^= ((int64_t) (void*) wire_fetch_payment);
    dummy_var ^= ((int64_t) (void*) wire_list_payments);
    dummy_var ^= ((int64_t) (void*) wire_configured_status);
    dummy_var ^= ((int64_t) (void*) wire_connection_status);
    dummy_var ^= ((int64_t) (void*) wire_network);
    dummy_var ^= ((int64_t) (void*) wire_calculate_fee);
    dummy_var ^= ((int64_t) (void*) wire_list_federations);
    dummy_var ^= ((int64_t) (void*) wire_switch_federation);
    dummy_var ^= ((int64_t) (void*) wire_decode_invoice);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_bridge_federation_info_0);
    dummy_var ^= ((int64_t) (void*) new_list_bridge_guardian_info_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}