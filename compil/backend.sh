#!/bin/bash
set -e

echo "=== 1. SYSTEM DEPENDENCIES ==="
sudo apt update
sudo apt install -y pkg-config libssl-dev build-essential git curl

echo "=== 2. RUST INSTALL ==="
if ! command -v cargo &> /dev/null
then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
fi

export PATH="$HOME/.cargo/bin:$PATH"

echo "=== 3. GO TO BACKEND ==="
cd Engine/OpenQueri-backend

echo "=== 4. CREATE ENV ==="
cat > .env <<EOF
DATABASE_URL=postgres://user:password@127.0.0.1:5432/open_queri
EOF

echo "=== 5. START DOCKER DB ==="
sudo docker compose up -d

echo "=== 6. WAIT DB START ==="
sleep 5

echo "=== 7. INSTALL SQLX CLI ==="
cargo install sqlx-cli --no-default-features --features postgres

echo "=== 8. GENERATE SQLX CACHE (IMPORTANT) ==="
unset SQLX_OFFLINE
cargo sqlx prepare

echo "=== 9. BUILD BACKEND (OFFLINE MODE) ==="
export SQLX_OFFLINE=true
cargo build --release

echo "=== 10. MOVE BINARY ==="
mv target/release/OpenQueri-backend ../../

echo "=== DONE ==="