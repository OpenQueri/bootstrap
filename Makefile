.PHONY: install download-backend download-frontend setup all

install:
	@bash ./install/install.sh

download-backend:
	@bash ./download/download_engine.sh

download-ai:
	@bash ./download/downloa_AI.sh

download-frontend:
	@bash ./download/download_frontend.sh


compil-frontend:
	@bash ./compil/frontend.sh

compil-backend:
	@bash ./compil/backend.sh

nigix:
	@bash ./nigix.sh

backend-background:
	@bash ./backend_background.sh

setup: install download-backend download-frontend

all: setup
	@echo "Everything is ready"