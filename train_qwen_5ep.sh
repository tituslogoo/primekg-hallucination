python -m mlx_lm.lora \
  --model Qwen/Qwen2.5-3B-Instruct \
  --train \
  --data mlx_data_qwen \
  --iters 4000 \
  --batch-size 1 \
  --num-layers 8 \
  --adapter-path adapters_qwen_5ep \
  --save-every 200 \
  --steps-per-eval 200 2>&1 | tee training_log_qwen_5ep.txt
