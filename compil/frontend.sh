

cd FrontEnd/frontend-open-queri

docker build -t openqueri-frontend .
docker create --name tmp openqueri-frontend
docker cp tmp:/app/dist ./../../../dist
docker rm tmp