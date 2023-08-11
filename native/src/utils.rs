use std::io::Write;

use anyhow::{bail, Result};
use flutter_rust_bridge::{StreamSink, handler::{ReportDartErrorHandler, self, ErrorHandler}, support::WireSyncReturn};
use tokio::runtime::Runtime;
use tracing_subscriber::{fmt::MakeWriter, EnvFilter};

pub fn start_runtime() -> anyhow::Result<Runtime> {
    let rt = tokio::runtime::Builder::new_multi_thread()
        .worker_threads(3)
        .enable_all()
        .thread_name("litheum-wallet-client")
        .build()?;
    Ok(rt)
}

#[derive(Debug, Clone, PartialEq)]
pub enum OutputEvent {
    Synced,
    SyncFailed,
    PreAccount,
    PostAccount { acc_view: String },
    Close,
}

struct LogSink {
    sink: StreamSink<String>,
}

impl<'a> Write for &'a LogSink {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let line = String::from_utf8_lossy(buf).to_string();
        self.sink.add(line);
        Ok(buf.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

impl<'a> MakeWriter<'a> for LogSink {
    type Writer = &'a LogSink;

    fn make_writer(&'a self) -> Self::Writer {
        self
    }
}

pub fn setup_logs(sink: StreamSink<String>) -> Result<()> {
    let log_sink = LogSink { sink };

    // Subscribe to tracing events and publish them to the UI
    if let Err(err) = tracing_subscriber::fmt()
        .with_max_level(tracing::Level::TRACE)
        .with_env_filter(EnvFilter::new("info,litheumcommon=trace"))
        .with_writer(log_sink)
        .try_init()
    {
        bail!("{}", err);
    }
    Ok(())
}


#[derive(Copy, Clone)]
pub struct LWErrorHandler(ReportDartErrorHandler);

impl ErrorHandler for LWErrorHandler {
    fn handle_error(&self, port: i64, error: handler::Error) {
        // Here I can handle the error
        self.0.handle_error(port, error)
    }

    fn handle_error_sync(&self, error: handler::Error) -> WireSyncReturn {
        self.0.handle_error_sync(error)
    }
}