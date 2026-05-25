
cd Engine/OpenQueri-backend/

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

sudo apt install -y pkg-config libssl-dev
sudo apt install -y build-essential

cd OpenQueri-backend/

export SQLX_OFFLINE=true
cargo build --release

mv target/release/OpenQueri-backend ../../..

