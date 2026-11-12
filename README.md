# SVT-AV1-Essential Builds

This repository contains **no encoder source code**. It only holds the GitHub
Actions workflow that builds PGO-optimised binaries of
[SVT-AV1-Essential](https://github.com/Uranite/SVT-AV1-Essential) and publishes
them as Releases.

## Why a separate build-only repo?

The encoder's own repository is a fork of SVT-AV1-Essential. Any change to a
workflow file has to be committed *somewhere*, and if that file lives in the
encoder repository every CI-only edit creates a new commit. Because
`Source/Lib/Codec/ConfigureGitVersion.cmake` derives the version string embedded
in the binary from `git rev-parse --short HEAD` and `git log -1 --format=%cs`,
those CI commits change the encoder version that is baked into
`SvtAv1EncApp --version`, even though no source was touched.

Keeping the build workflow here decouples the two:

* The encoder repository only ever contains source changes, so its commit
  history and the embedded version stay meaningful.
* Every build is pinned to an explicit encoder ref (branch, tag, or commit), so
  you always know exactly which encoder commit produced a given release.

## How it works

1. **Resolve** — the `tag` job checks out the encoder at the ref you choose and
   derives a release tag (`pgo-build-<date>-<shorthash>`) from *that* commit.
2. **Release** — a `pgo-build-tags` branch is used to anchor the release tag,
   exactly like the original workflow. Releases are published in **this**
   repository.
3. **Build** — each platform job checks out the encoder at the resolved commit
   and builds it with [`Akatmks/build-svt-av1@v2`](https://github.com/Akatmks/build-svt-av1),
   producing LTO + PGO builds for:

   | Platform | Architecture | Variants |
   | --- | --- | --- |
   | Windows | x86-64 | `icelake-server`+`znver5`, `znver2`, `x86-64-v3`+`znver2` |
   | Windows | arm64 | `armv8.7-a+crypto+sm4+sha3+fp16+sve+sve2`+`oryon-1` |
   | Linux | x86-64 | `icelake-server`+`znver5`, `znver2`, `x86-64-v3`+`znver2` |
   | macOS | arm64 | `armv8.5-a+simd+crypto`+`apple-m3` |

## Running a build

1. Go to **Actions → pgo-build → Run workflow**.
2. Set **Encoder source repository** (default `Uranite/SVT-AV1-Essential`).
3. Set **Branch, tag, or commit** (default `Essential-v4.3.0`).
4. Click **Run workflow**.

When the build finishes, the binaries appear under **Releases** in this
repository.

## Notes

* The encoder is licensed under the BSD 2-Clause License plus the Alliance for
  Open Media Patent License 1.0. See the
  [encoder repository](https://github.com/Uranite/SVT-AV1-Essential) for the
  full license text. This repository only distributes built binaries.
* If you want the releases to be published back to the encoder repository
  instead, add a `repository:` input to the `softprops/action-gh-release` steps
  and provide a PAT (with `contents: write` on the target repo) via the `token:`
  input, since `github.token` is scoped to this repository.

## Credits

Thanks to studies and contributions from afed, Emre, Ironclad, Itachi Uchiha,
Khaoklong, Miss Ashenlight, Soda, SwareJonge, Trix, Yiss, and other people in the
community for discovering the method to build the fastest binary.