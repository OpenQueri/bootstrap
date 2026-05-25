#!/bin/bash
cd ..

if [ ! -f "model.onnx" ]; then
  echo "Downloading model.onnx..."
  wget https://huggingface.co/intfloat/multilingual-e5-base/resolve/main/onnx/model.onnx
else
  echo "model.onnx already exists, skipping"
fi

if [ ! -f "tokenizer.json" ]; then
  echo "Downloading tokenizer.json..."
  wget https://huggingface.co/intfloat/multilingual-e5-base/resolve/main/onnx/tokenizer.json
else
  echo "tokenizer.json already exists, skipping"
fi