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
    status: InternalPaymentStatus,
    pub created_at: u64,
    // TODO
    // status: InternalPaymentStatus,
}

// TODO: expired state (probably shouldn't store in the db)
// TODO: InternalPaymentStatus and Payment Sstatus
#[derive(Clone, Debug, Encodable, Decodable, PartialEq)]
pub enum InternalPaymentStatus {
    Paid,
    Pending,
    Failed,
}

#[derive(Clone, Debug, Encodable, Decodable, PartialEq)]
pub enum PaymentStatus {
    Paid,
    Pending,
    Failed,
    Expired,
}

// impl From<InternalPaymentStatus> for PaymentStatus {
//     fn from(status: InternalPaymentStatus) -> Self {
//         match status {
//             InternalPaymentStatus::Paid =>
//         }

// }

impl Payment {
    fn new(invoice: Invoice, status: InternalPaymentStatus) -> Self {
        Self {
            invoice,
            status,
            created_at: SystemTime::now()
                .duration_since(SystemTime::UNIX_EPOCH)
                .expect("couldn't get utc timestamp") // FIXME: maybe just return 0?
                .as_secs(),
        }
    }

    pub fn new_pending(invoice: Invoice) -> Self {
        Self::new(invoice, InternalPaymentStatus::Pending)
    }

    pub fn new_paid(invoice: Invoice) -> Self {
        Self::new(invoice, InternalPaymentStatus::Paid)
    }

    pub fn new_failed(invoice: Invoice) -> Self {
        Self::new(invoice, InternalPaymentStatus::Failed)
    }

    pub fn paid(&self) -> bool {
        self.status() == PaymentStatus::Paid
    }

    pub fn expired(&self) -> bool {
        self.status() == PaymentStatus::Expired
    }

    pub fn status(&self) -> PaymentStatus {
        match self.status {
            InternalPaymentStatus::Paid => PaymentStatus::Paid,
            InternalPaymentStatus::Pending => {
                if self.invoice.is_expired() {
                    return PaymentStatus::Expired;
                }
                PaymentStatus::Pending
            }
            InternalPaymentStatus::Failed => PaymentStatus::Failed,
        }
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
