python -m mlx_lm.lora \
  --model mlx-community/Llama-3.1-8B-Instruct-4bit \
  --train \
  --data mlx_data_llama \
  --iters 4000 \
  --batch-size 1 \
  --num-layers 8 \
  --adapter-path adapters_llama_5ep \
  --save-every 200 \
  --steps-per-eval 200 2>&1 | tee training_log_llama_5ep.txt
