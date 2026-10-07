# ⚖️ Qwen2.5-3B vs Llama-3.1-8B — Checkpoint Comparison

Both LoRA fine-tuned on identical data: PubMedQA (800 train / 100 val / 100 test) + PrimeKG-injected context. Same iteration schedule (4000 iters / 5 epochs), same checkpoints evaluated (400, 2600, 3400, 4000-final) on the full 100-sample test set.

## Results — accuracy by checkpoint

| Checkpoint | QWENAccuracy | LLAMAAccuracy |
| --- | --- | --- |
| Iter 400 | 67.0% | 56.0% |
| Iter 2600 | 66.0% | 60.0% |
| Iter 3400 | 59.0% | **70.0%** |
| Iter 4000 (final) | 66.0% | 58.0% |

Baseline (always guess YES): 56.0% accuracy — true label mix in test set is 56 YES / 34 NO / 10 MAYBE.

## Recall by class — NO and MAYBE (the harder classes)

QWENNO recall by checkpoint

Iter 400

0.50

Iter 2600

0.56

Iter 3400

0.47

Iter 4000

0.32

LLAMANO recall by checkpoint

Iter 400

0.00

Iter 2600

0.18

Iter 3400

0.53

Iter 4000

0.09

MAYBE recall — both models

QIter 2600

0.30

QIter 3400

0.40

LAll checkpoints

0.00

## Key findings

- The bigger model is not clearly better. Llama-8B's best checkpoint (iter 3400, 70%) edges out Qwen-3B's best (iter 400, 67%) — but Llama's *other three* checkpoints (56–60%) are all worse than every Qwen checkpoint (59–67%). Model size alone didn't produce a consistent advantage here.
- Llama is more YES-biased than Qwen overall. At iterations 400 and 4000, Llama's YES recall is near-perfect (1.00, 0.98) while NO recall collapses to near-zero (0.00, 0.09) — more extreme than Qwen showed at the same checkpoints.
- Neither model ever learned to predict MAYBE. Llama scored 0.00 MAYBE recall at *every single checkpoint* tested — worse than Qwen, which reached 0.30–0.40 at iterations 2600 and 3400. This is a real asymmetry between the two models on this data.
- Llama's one strong checkpoint (iter 3400) lands right where Qwen started overfitting. For Qwen, iter 3400 was already past the healthy plateau and degrading (val loss rising). For Llama, that same iteration was its best test result — the two models' "sweet spots" don't line up at the same training point, which argues against assuming a shared "best iteration" across different models.
- Validation loss was a weak predictor of test accuracy for both models. Neither model's lowest-val-loss checkpoint (iter 2600 for both) was its best-accuracy checkpoint — reinforcing that val loss alone isn't a reliable way to pick a final checkpoint here.

## What this means for the hallucination question

Neither model shows evidence of genuine, balanced reasoning yet — both lean heavily on a YES-guessing shortcut, and Llama does so more severely despite being the larger, "stronger" model in this study's design. This is itself a useful finding: **bigger does not automatically mean better-grounded** on this task, at least not without addressing the underlying class imbalance in training data first. Before drawing conclusions about KG grounding reducing hallucination, this imbalance issue likely needs to be addressed, since right now accuracy differences mostly reflect which answer each checkpoint defaults to, not genuine fact-grounded reasoning.

Qwen2.5-3B-Instruct & Llama-3.1-8B-Instruct (4-bit) · LoRA (rank 8, 8 layers) · PubMedQA (PQA-L) · PrimeKG-grounded context · Evaluated on full 100-sample test split