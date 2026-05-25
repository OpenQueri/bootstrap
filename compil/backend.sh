
cd Engine/OpenQueri-backend/

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

sudo apt install -y pkg-config libssl-dev
sudo apt install -y build-essential

cd OpenQueri-backend/
echo "DATABASE_URL=postgres://user:password@127.0.0.1:5432/open_queri" > .env

cargo install sqlx-cli --no-default-features --features postgres

unset SQLX_OFFLINE

cargo sqlx prepare

export SQLX_OFFLINE=true

cargo build --release

mv target/release/OpenQueri-backend ../../..

