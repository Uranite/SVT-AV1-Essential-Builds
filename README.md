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

## License

The encoder is BSD 2-Clause plus the AOMedia Patent License 1.0, as stated in
its [LICENSE.md](https://github.com/nekotrix/SVT-AV1-Essential/blob/Essential-v4.3.0/LICENSE.md).
These binaries are distributed unmodified.

## Credits

Thanks to afed, Emre, Ironclad, Itachi Uchiha, Khaoklong, Miss Ashenlight,
Soda, SwareJonge, Trix, Yiss, and the rest of the community for figuring out how
to build the fastest binary.