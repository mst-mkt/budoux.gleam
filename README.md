# budoux.gleam

A Gleam port of [BudouX](https://github.com/google/budoux), a standalone, small, and language-neutral phrase segmenter that provides beautiful and legible line breaks.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/mst-mkt/budoux.gleam/main/assets/example-dark.png">
  <img src="https://raw.githubusercontent.com/mst-mkt/budoux.gleam/main/assets/example-light.png" alt="Line breaks of a Japanese sentence without and with budoux">
</picture>

## Install

```sh
gleam add budoux
```

Works on both the Erlang and JavaScript targets.

## Usage

```gleam
import budoux

pub fn main() {
  let parser = budoux.ja()

  budoux.parse(parser, "今日は天気です。")
  // -> ["今日は", "天気です。"]
}
```

## API

### `budoux`

| Function                                                  | Description                                                                       |
| --------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `parse(parser: Parser, sentence: String) -> List(String)` | Splits a sentence into phrases.                                                   |
| `ja() -> Parser`                                          | Creates a parser with the Japanese model.                                         |
| `ja_word() -> Parser`                                     | Creates a parser with the Japanese word model, which splits sentences into words. |
| `zh_hans() -> Parser`                                     | Creates a parser with the Simplified Chinese model.                               |
| `zh_hant() -> Parser`                                     | Creates a parser with the Traditional Chinese model.                              |
| `th() -> Parser`                                          | Creates a parser with the Thai model.                                             |
| `new(model: Model) -> Parser`                             | Creates a parser from a model.                                                    |

### `budoux/model`

| Item                                 | Description                                                             |
| ------------------------------------ | ----------------------------------------------------------------------- |
| `Model`                              | The scores of a BudouX model, grouped in the same way as its JSON file. |
| `empty: Model`                       | A model with no scores.                                                 |
| `decoder() -> decode.Decoder(Model)` | Decodes a model from the JSON format used by BudouX.                    |

## Development

The tools are managed in `flake.nix`, and the versions used in CI in `.tool-versions`.

### Generated files

These files are generated from the BudouX release pinned in `flake.nix`, and the update workflow regenerates them.

| Generated file                    | Source in BudouX       | Script                     |
| --------------------------------- | ---------------------- | -------------------------- |
| `src/budoux/model/*.gleam`        | `budoux/models/*.json` | `codegen/models.nu`        |
| `test/budoux/quality_cases.gleam` | `tests/quality/ja.tsv` | `codegen/quality_cases.nu` |

## Acknowledgements

The algorithm, the pretrained models, and the test cases come from [google/budoux](https://github.com/google/budoux).

## License

[Apache License 2.0](./LICENSE)
