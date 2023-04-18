# Postgres Migration Library for Haskell

[![Build CI](https://github.com/haskellify/postgresql-migration/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/haskellify/postgresql-migration/actions/workflows/build.yml)
[![License](https://img.shields.io/github/license/haskellify/postgresql-migration)](LICENSE)

### Requirements

 - **Stack** (recommended 2.9.1 or higher)
 - **Postgres & libpq** (recommended 11)
 - **Fourmolu** (recommended 0.8.2.0, optional)
 - **HLint** (recommended 3.4.1, optional)
 
### Build & Run

Run these comands from the root of the project

```bash
$ stack build
```

### Format code

Create a bash script which will do the work for you. Run the script from the root of the project

```bash
$ fourmolu -i (find lib -name '*.hs')
```

## License

This project is licensed under the Apache License v2.0 - see the [LICENSE](LICENSE.md) file for more details.
