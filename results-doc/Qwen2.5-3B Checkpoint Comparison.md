# 🧪 Qwen2.5-3B + PrimeKG — Checkpoint Comparison

LoRA fine-tuned on PubMedQA (800 train / 100 val / 100 test), PrimeKG triples injected as context. 4000 iterations (5 epochs) total.

## Results — full 100-sample test set

| Checkpoint | Accuracy | YES recall | NO recall | MAYBE recall |
| --- | --- | --- | --- | --- |
| Iter 400 | 67.0% | 0.89 | 0.50 | 0.00 |
| Iter 2600 | 66.0% | 0.79 | 0.56 | 0.30 |
| Iter 3400 | 59.0% | 0.70 | 0.47 | 0.40 |
| Iter 4000 (final) | 66.0% | 0.98 | 0.32 | 0.00 |

Baseline (always guess YES): 56.0% accuracy — true label mix in test set is 56 YES / 34 NO / 10 MAYBE.

## Recall by class, per checkpoint

YES NO MAYBE

Iter 400 — YES

0.89

Iter 400 — NO

0.50

Iter 400 — MAYBE

0.00

Iter 2600 — YES

0.79

Iter 2600 — NO

0.56

Iter 2600 — MAYBE

0.30

Iter 3400 — YES

0.70

Iter 3400 — NO

0.47

Iter 3400 — MAYBE

0.40

Iter 4000 — YES

0.98

Iter 4000 — NO

0.32

Iter 4000 — MAYBE

0.00

## Key findings

- No checkpoint learned to discriminate well. Every checkpoint leans toward predicting YES — recall on YES is always ≥0.70, while NO recall never exceeds 0.56. Accuracy differences across checkpoints (59–67%) mostly reflect how strongly each one leans on this shortcut, not genuine improvement.
- More training made the YES-bias worse, not better. The final checkpoint (iter 4000, full 5 epochs) has the most extreme imbalance of all: 0.98 YES recall vs. 0.32 NO recall — nearly always guessing YES.
- MAYBE is almost never predicted. 0.00 recall at iterations 400 and 4000; only iterations 2600 and 3400 show any ability to predict it (0.30, 0.40) — likely because MAYBE is rare in training data (\~10% of PubMedQA).
- Validation loss plateaued early and didn't predict test accuracy well. Iter 2600 had the lowest validation loss of the whole run, but iter 400 scored slightly higher on actual test accuracy — val loss alone isn't a reliable guide to which checkpoint generalizes best here.
- All checkpoints beat the 56% majority-class baseline, so the KG-grounded fine-tuning pipeline is doing something — just not yet genuine class discrimination.

## Likely cause & next step

This pattern points to **class imbalance in the training data** (PubMedQA skews toward YES answers) rather than undertraining — since training longer made the bias worse, not better. Next steps worth trying: check the actual YES/NO/MAYBE split in the 800 training examples, and consider class-weighting the loss or oversampling NO/MAYBE examples before the next training run.

Qwen2.5-3B-Instruct + LoRA (rank 8, 8 layers) · PubMedQA (PQA-L) · PrimeKG-grounded context · Evaluated on full 100-sample test split