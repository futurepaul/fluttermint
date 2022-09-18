use std::time::SystemTime;

use bitcoin::hashes::sha256;
use fedimint_api::{
    db::DatabaseKeyPrefixConst,
    encoding::{Decodable, Encodable},
};
use lightning_invoice::Invoice;

const DB_PREFIX_PAYMENTS: u8 = 0x51;

#[derive(Clone, Debug, Encodable, Decodable)]
pub struct Payment {
    pub invoice: Invoice,
    pub status: PaymentStatus,
    pub created_at: u64,
    pub direction: PaymentDirection,
}

#[derive(Copy, Clone, Debug, Encodable, Decodable, PartialEq)]
pub enum PaymentStatus {
    Paid,
    Pending,
    Failed,
    Expired,
}

#[derive(Copy, Clone, Debug, Encodable, Decodable, PartialEq)]
pub enum PaymentDirection {
    Outgoing,
    Incoming,
}

impl Payment {
    pub fn new(invoice: Invoice, status: PaymentStatus, direction: PaymentDirection) -> Self {
        Self {
            invoice,
            status,
            created_at: SystemTime::now()
                .duration_since(SystemTime::UNIX_EPOCH)
                .expect("couldn't get utc timestamp") // FIXME: maybe just return 0?
                .as_secs(),
            direction,
        }
    }

    pub fn paid(&self) -> bool {
        self.status == PaymentStatus::Paid
    }

    pub fn expired(&self) -> bool {
        self.status == PaymentStatus::Expired
    }
}

#[derive(Debug, Clone, Encodable, Decodable)]
pub struct PaymentKey(pub sha256::Hash);

impl DatabaseKeyPrefixConst for PaymentKey {
    const DB_PREFIX: u8 = DB_PREFIX_PAYMENTS;
    type Key = Self;
    type Value = Payment;
}

#[derive(Debug, Clone, Encodable, Decodable)]
pub struct PaymentKeyPrefix;

impl DatabaseKeyPrefixConst for PaymentKeyPrefix {
    const DB_PREFIX: u8 = DB_PREFIX_PAYMENTS;
    type Key = PaymentKey;

    type Value = Payment;
}
