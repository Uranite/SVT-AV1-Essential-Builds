# SVT-AV1-Essential Builds

Prebuilt, PGO-optimised binaries of
[SVT-AV1-Essential](https://github.com/nekotrix/SVT-AV1-Essential), published as
GitHub Releases.

## Downloads

Every release is tagged `pgo-build-<date>-<shorthash>`, where the short hash is
the encoder commit it was built from. Builds are LTO + PGO:

| Platform | Architecture | Variants |
| --- | --- | --- |
| Windows | x86-64 | `icelake-server`+`znver5`, `znver2`, `x86-64-v3`+`znver2` |
| Windows | arm64 | `armv8.7-a+crypto+sm4+sha3+fp16+sve+sve2`+`oryon-1` |
| Linux | x86-64 | `icelake-server`+`znver5`, `znver2`, `x86-64-v3`+`znver2` |
| macOS | arm64 | `armv8.5-a+simd+crypto`+`apple-m3` |

Pick the variant that matches your CPU. If you are unsure, use `x86-64-v3` on
x86-64.

Availability varies per release. Not every variant in the table is guaranteed to
be present, because builds are produced by whatever GitHub Actions runner the
workflow is assigned to, and a variant is only built when that runner's CPU
supports its required features. If the runner doesn't have a given feature set,
that variant is skipped and no file is uploaded for it. For example, a runner
without `icelake-server` support means there is no `icelake-server` build for
that run. Always check the release assets to see what is actually available.

## Automated updates

The `Update SVT-AV1-Essential` workflow runs daily (and on manual dispatch). It
follows the latest `Essential-v*` branch of the upstream repository, records the
newest commit in `upstream-pin.json`, and automatically starts a `pgo-build`
run whenever upstream has a new commit. A specific branch, tag, or commit can
be forced via the workflow's `ref` input.

## License

The encoder is BSD 2-Clause plus the AOMedia Patent License 1.0. See
[LICENSE.md](https://github.com/nekotrix/SVT-AV1-Essential/blob/Essential-v4.3.0/LICENSE.md)
for more details.
These binaries are distributed unmodified.

## Credits

Thanks to afed, Emre, Ironclad, Itachi Uchiha, Khaoklong, Miss Ashenlight,
Soda, SwareJonge, Trix, Yiss, and the rest of the community for figuring out how
to build the fastest binary.