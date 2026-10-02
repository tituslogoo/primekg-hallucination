# PrimeKG Hallucination Study

Does grounding an LLM with knowledge-graph context reduce hallucination on biomedical QA — and does it help a small model more than a strong one?

## Goal

A 2×2 comparison on [PubMedQA](https://pubmedqa.github.io/) (labeled subset, PQA-L):

|               | No KG | With KG |
|---------------|-------|---------|
| **Small LLM** (Qwen2.5-3B-Instruct)   | arm 1 | arm 2 |
| **Strong LLM** (Llama-3.1-8B-Instruct) | arm 3 | arm 4 |

KG context is retrieved from [PrimeKG](https://github.com/mims-harvard/PrimeKG) (~8.1M edges: diseases, genes/proteins, drugs) as a proof-of-concept, with OptimusKG planned as a follow-up once compute allows.

## Status

- [x] PrimeKG loaded into Kuzu DB with a full-text search index
- [x] Retrieval pipeline built (scispaCy entity extraction → Kuzu FTS → cosine-similarity reranking of triples)
- [x] PubMedQA split 80/10/10 (train/val/test, seed=42), formatted into KG-infused instruction prompts
- [x] Qwen2.5-3B-Instruct fine-tuned via MLX LoRA (arm 2) — 600 iterations, best val loss at iter 400
- [x] Evaluate Qwen checkpoints (iter 400 vs. final) on held-out test set
- [ ] Llama-3.1-8B-Instruct fine-tuning (arm 4)
- [ ] No-KG baselines (arms 1 and 3)
- [ ] Hallucination metric beyond accuracy (unsupported-claim rate, contradiction rate)

## Architecture

```
PrimeKG kg.csv
      │
      ▼ (01_build_kg.ipynb)
Kuzu DB (Entity nodes, RELATES_TO edges, entity_fts index)
      │
      ▼ (02_build_dataset.ipynb)
PubMedQA question
  → scispaCy entity extraction
  → Kuzu full-text search per entity
  → connected triples pulled from matched nodes
  → cosine-similarity reranking (top 5, threshold 0.20)
  → formatted as KG-infused instruction prompt
      │
      ▼ (03_train_*.ipynb + MLX LoRA)
Fine-tuned adapter (small weight delta on top of the base model)
      │
      ▼ (04_evaluate_*.ipynb)
Accuracy / ROUGE / classification report on held-out test set
```

## Repo structure

```
primekg-hallucination/
├── 01_build_kg.ipynb           # Load PrimeKG into Kuzu, build FTS index
├── 02_build_dataset.ipynb      # Retrieval pipeline + PubMedQA instruction dataset
├── 03_train_qwen.ipynb         # MLX LoRA fine-tuning setup (Qwen arm)
├── train_qwen.sh               # Training run command (terminal, long-running)
├── 04_evaluate_qwen.ipynb      # Checkpoint comparison + test-set evaluation
├── data/
│   ├── raw/                    # PrimeKG kg.csv (not tracked — see Setup)
│   └── processed/              # entities.csv, edges.csv (generated)
├── primekg_kuzu                # Kuzu database file (not tracked, ~200MB)
├── PubMedQA_Split/             # raw_train/val/test.json (generated)
├── v1_{train,validation,test}_primekg_instructions.jsonl  # generated
├── adapters_qwen/              # LoRA checkpoints for Qwen (not tracked)
├── .gitignore
└── README.md
```

## Setup

```bash
conda create -n primekg python=3.11 -y
conda activate primekg

pip install kuzu pandas scikit-learn sentence-transformers
pip install spacy scispacy
pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_core_sci_sm-0.5.4.tar.gz
pip install mlx mlx-lm datasets tqdm evaluate rouge_score
pip install jupyterlab ipykernel
python -m ipykernel install --user --name primekg --display-name "Python (primekg)"
```

Download PrimeKG's `kg.csv` and place it at `data/raw/kg.csv` (not included in this repo — see [PrimeKG's repo](https://github.com/mims-harvard/PrimeKG) for access).

Run the notebooks in order: `01_build_kg.ipynb` → `02_build_dataset.ipynb` → `03_train_qwen.ipynb` (+ `bash train_qwen.sh`) → `04_evaluate_qwen.ipynb`.

> **Note (Apple Silicon / iCloud):** if this repo lives inside an iCloud-synced folder (e.g. Desktop with Desktop & Documents sync enabled), Kuzu may fail with `Could not set lock on file`. Move the repo outside synced folders, or disable iCloud sync for it.

## Design notes

- **Prompt format follows [meta-llama/Llama-3.1-8B-Instruct's](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct) chat template** (`<|begin_of_text|>`, `<|start_header_id|>`, etc.) for all arms, including Qwen — kept consistent with the original pipeline this project is based on. This is a known mismatch for the Qwen arm (which natively expects ChatML) and will be noted as a limitation.
- **Kuzu schema:** a single `Entity` node table (columns: `node_index`, `id`, `name`, `type`, `source`) and a single `RELATES_TO` edge table (`relation`, `display_relation`), both directions of each PrimeKG edge kept as separate rows.
- **Retrieval cutoffs:** FTS match score ≥ 1.0, cosine similarity ≥ 0.20, top 5 triples per question. ~19% of PubMedQA test questions return no KG context — expected, since many PubMedQA questions (health policy, trial design) fall outside PrimeKG's biomedical entity scope.

## References

- Jin, Q. et al. *PubMedQA: A Dataset for Biomedical Research Question Answering.* EMNLP 2019.
- Chandak, P. et al. *Building a knowledge graph to enable precision medicine* (PrimeKG). Scientific Data, 2023.
- Meta AI. *The Llama 3 Herd of Models.* arXiv:2407.21783, 2024.
- Qwen Team. *Qwen2.5 Technical Report.* 2024.
