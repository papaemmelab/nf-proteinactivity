# 🧬 nf-proteinactivity

[![code formatting][black_badge]][black_base]
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://github.com/askimed/nf-test)
[![nf-proteinactivity CI](https://github.com/papaemmelab/nf-proteinactivity/actions/workflows/ci.yaml/badge.svg)](https://github.com/papaemmelab/nf-proteinactivity/actions/workflows/ci.yaml)

Tool for generating gene expression signature and running viper for protein activity inference.

## Contents

- [🧬 nf-proteinactivity](#-nf-proteinactivity)
  - [Contents](#contents)
  - [🚀 Run Pipeline](#-run-pipeline)
    - [1. ⚡️ Full pipeline](#1-️-full-pipeline)
    - [2. ✏️ Preprocessing Variants](#2-️-preprocessing-variants)
      - [Example](#example)
      - [⚡️ Optional Speed Improvements](#️-optional-speed-improvements)
    - [3. 🔮 Classifying Artifacts](#3--classifying-artifacts)
    - [4. 🧠 Training/Retraining](#4--trainingretraining)
  - [Contributing](#contributing)


## 🚀 Run Pipeline

You need [Nextflow](https://www.nextflow.io/docs/latest/install.html) installed.

```bash
nextflow run papaemmelab/nf-proteinactivity --help
```

Give it a try with a test run if you have docker available:

```bash
nextflow run papaemmelab/nf-proteinactivity -main -profile test,cloud
```

See this example:

```bash
nextflow run papaemmelab/nf-proteinactivity \
    -r main \
    --input {samplesheet.csv} \
    --outdir {results}
```

## Contributing

Contributions are welcome, and they are greatly appreciated, check our [contributing guidelines](.github/CONTRIBUTING.md)!

<!-- References -->
[black_badge]: https://img.shields.io/badge/code%20style-black-000000.svg
[black_base]: https://github.com/ambv/black