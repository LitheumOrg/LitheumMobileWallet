use anyhow::{anyhow, Result};  // i used anyhow::Result instead bec https://cjycode.com/flutter_rust_bridge/feature/lang_exceptions.html
use flutter_rust_bridge::StreamSink;
use tokio::{sync::oneshot, runtime::Runtime};
use std::sync::{Arc, Mutex};

use litheumcommon::{
    constants::Constants,
    crypto::decrypt_key_file,
    keypair::Keypair,
    keypair_store::KeypairStore,
    timestamp_generator::{AbstractTimestampGenerator, SystemTimestampGenerator},
    wallet_database::WalletDatabase,
};

use crate::{utils::{start_runtime, OutputEvent}, sdk::{WalletDBWrapper, KeypairStoreWrapper}};

static RUNTIME: Mutex<Option<Runtime>> = Mutex::new(None);


/// Initialize native code and subscribe to the events that native module dispatches.
pub fn setup(
    sink: StreamSink<OutputEvent>,
    // app_support_dir: String,
    // files_dir: String,
    device_name: String,
) -> Result<()> {
    // let db_encryption_key = key_from_slice(b"an example very very secret key.")?;
    let rt = start_runtime()?;

    // TODO: call to sdk.run()
    // let sdk = rt.block_on(sdk::run(
    //     app_support_dir,
    //     files_dir,
    //     device_name,
    //     db_encryption_key,
    // ))?;
    // let mut events = sdk.broadcast_to_subscriber()


    let handle = rt.handle().clone();
    {
        *RUNTIME.lock().expect("Set runtime") = Some(rt);
    }

    let (tx, rx) = oneshot::channel();
    // We are spawning an async task from a thread that is not managed by
    // Tokio runtime. For this to work we need to enter the handle.
    // Ref: https://docs.rs/tokio/latest/tokio/runtime/struct.Handle.html#method.current
    let _guard = handle.enter();
    // tokio::spawn(async move {
    //     while let Ok(e) = events.recv().await {
    //         sink.add(e.into());
    //     }
    //     let _ = tx.send(());
    // });

    let _ = rx.blocking_recv();
    Ok(())
}

pub fn greet() -> String {
    "Hello from Rust!".to_string()
}

pub fn generate_keypair() -> Vec<u8> {
    let (_keypair, encrypted_key) = Keypair::make_encrypted_key_with_password("asdf");
    encrypted_key
}

pub fn verify_keypair_data(cipher_data: Vec<u8>) -> Result<bool> {
    if let Ok(decrypted_buffer) = decrypt_key_file(cipher_data, &String::from("asdf")) {
        if let Ok(keypair) = KeypairStore::new_from_secret_slice(&decrypted_buffer) {
            let mut keypair_store_global = KEYPAIR_STORE.try_write();
            *keypair_store_global = Some(Arc::new(keypair_store));
        } else {
            Err(anyhow!("Could not create keypair from decrypted data"))
        }
    } else {
        Err(anyhow!("Could not decrypt keyfile"))
    }
}

pub fn get_address(slice: Vec<u8>) -> Result<String> {
    KeypairStoreWrapper::get_address()
}

pub fn get_balance() -> Result<u64> {
    WalletDBWrapper::get_balance()
}

pub fn send_tx() -> Result<()> {
    unimplemented!()
}