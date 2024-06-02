#[tokio::main]
async fn main() {
    // Set up an Axum router that responds to `/`
    let app = axum::Router::new().route("/", axum::routing::get(index));

    // Bind to port 8000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();

    // Print the address we're listening on
    let local_addr = listener.local_addr().unwrap();
    println!("listening on {}", local_addr);

    // Shut down cleanly on Ctrl-C
    let shutdown_signal = async {
        let _ = tokio::signal::ctrl_c()
            .await
            .inspect_err(|error| println!("failed to install signal handler: {error:#}"));
    };

    // Start the server
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal)
        .await
        .unwrap();
}

async fn index() -> &'static str {
    "Hello, world!\n"
}
