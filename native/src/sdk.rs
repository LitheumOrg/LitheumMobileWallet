use anyhow::{anyhow, Result};
use flutter_rust_bridge::frb;
use std::sync::RwLock;
use std::sync::Arc;


use litheumcommon::{keypair_store::KeypairStore, wallet_database::WalletDatabase};
use litheumcommon::types::Sha256Hash;

lazy_static! {
    static ref WALLET_DB: Arc<RwLock<Option<WalletDatabase>>> = Arc::new(RwLock::new(None));
    static ref KEYPAIR_STORE: Arc<RwLock<Option<Arc<KeypairStore>>>> = Arc::new(RwLock::new(None));
}

// https://cjycode.com/flutter_rust_bridge/feature/lang_external.html#types-in-other-crates
#[frb(mirror(Sha256Hash))]
pub struct _Sha256Hash([u8; 32]);

pub struct WalletDBWrapper {}
impl WalletDBWrapper {
    pub fn get_balance() -> Result<u64> {
        match WALLET_DB.try_read() {
            Ok(rw_lock) => match rw_lock.as_ref() {
                Some(wallet_db) => {
                    if let Ok(balance) = wallet_db.get_balance() {
                        Ok(balance)
                    } else {
                        Err(anyhow!("Wallet not synchronized"))
                    }
                }
                None => Err(anyhow!("Wallet db not set")),
            },
            Err(err) => Err(anyhow!(format!("Wallet db mutex poisoned. {}", err))),
        }
    }

    // serve for send_transaction()
    pub fn get_latest_block_id() -> Result<u32> {
        match WALLET_DB.try_read() {
            Ok(rw_lock) => match rw_lock.as_ref() {
                Some(wallet_db) => {
                    if let Some(block_id) = wallet_db.get_latest_block_id() {
                        Ok(*block_id)
                    } else {
                        Err(anyhow!("Wallet not synchronized"))
                    }
                }
                None => Err(anyhow!("Wallet db not set")),
            },
            Err(err) => Err(anyhow!(format!("Wallet db mutex poisoned. {}", err))),
        }
    }

    // serve for send_transaction()
    pub fn get_latest_block_hash() -> Result<Sha256Hash> {
        match WALLET_DB.try_read() {
            Ok(rw_lock) => match rw_lock.as_ref() {
                Some(wallet_db) => {
                    if let Some(block_hash) = wallet_db.get_latest_block_hash() {
                        Ok(*block_hash)
                    } else {
                        Err(anyhow!("Wallet not synchronized"))
                    }
                }
                None => Err(anyhow!("Wallet db not set")),
            },
            Err(err) => Err(anyhow!(format!("Wallet db mutex poisoned. {}", err))),
        }
    }
}

pub struct KeypairStoreWrapper {}
impl KeypairStoreWrapper {
    pub fn get_address() -> Result<String> {
        match KEYPAIR_STORE.try_read() {
            Ok(rw_lock) => match rw_lock.as_ref() {
                Some(wallet_db) => Ok(wallet_db.get_keypair().get_address()),
                None => Err(anyhow!("Keypair store not set")),
            },
            Err(err) => Err(anyhow!(format!("Keypair mutex poisoned. {}", err))),
        }
    }
}

//TODO: add argument for keypair from dart - not sure if I need it here!
// this fn will be caled from api.rs - setup() fn
//TODO: change the content fn into setup background tasks (force sync, etc.)
// step init keypair store & wallet db already done from earlier - dart setupDevice()
pub async fn run() -> Result<()> {

    Ok(())
}