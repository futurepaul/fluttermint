#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_init(int64_t port_, struct wire_uint_8_list *path);

void wire_join_federation(int64_t port_,
                          struct wire_uint_8_list *user_dir,
                          struct wire_uint_8_list *config_url);

void wire_leave_federation(int64_t port_);

void wire_balance(int64_t port_);

void wire_pay(int64_t port_, struct wire_uint_8_list *bolt11);

void wire_decode_invoice(int64_t port_, struct wire_uint_8_list *bolt11);

void wire_invoice(int64_t port_, uint64_t amount, struct wire_uint_8_list *description);

void wire_fetch_payment(int64_t port_, struct wire_uint_8_list *payment_hash);

void wire_list_payments(int64_t port_);

void wire_connection_status(int64_t port_);

void wire_network(int64_t port_);

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
    dummy_var ^= ((int64_t) (void*) wire_decode_invoice);
    dummy_var ^= ((int64_t) (void*) wire_invoice);
    dummy_var ^= ((int64_t) (void*) wire_fetch_payment);
    dummy_var ^= ((int64_t) (void*) wire_list_payments);
    dummy_var ^= ((int64_t) (void*) wire_connection_status);
    dummy_var ^= ((int64_t) (void*) wire_network);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}