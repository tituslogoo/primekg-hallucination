python -m mlx_lm.lora \
  --model Qwen/Qwen2.5-3B-Instruct \
  --train \
  --data mlx_data_qwen \
  --iters 600 \
  --batch-size 1 \
  --num-layers 8 \
  --adapter-path adapters_qwen \
  --save-every 100
