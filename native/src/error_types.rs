use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("Wallet db not set")]
    WalletDBNotSet,
    #[error("Keypair store not set")]
    KeypairStoreNotSet,
    #[error("Could not decrypt keyfile")]
    KeyFileDecryptionFailed,
}

#[macro_export]
macro_rules! Err {
    ($err:expr $(,)?) => {{
        let error = $err;
        Err(anyhow::anyhow!(error))
    }};
}
