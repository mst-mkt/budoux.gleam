import budoux/model.{type Model}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub opaque type Parser {
  Parser(
    total: Int,
    uw1: Dict(String, Int),
    uw2: Dict(String, Int),
    uw3: Dict(String, Int),
    uw4: Dict(String, Int),
    uw5: Dict(String, Int),
    uw6: Dict(String, Int),
    bw1: Dict(String, Int),
    bw2: Dict(String, Int),
    bw3: Dict(String, Int),
    tw1: Dict(String, Int),
    tw2: Dict(String, Int),
    tw3: Dict(String, Int),
    tw4: Dict(String, Int),
  )
}

pub fn new(model: Model) -> Parser {
  let total =
    [
      model.uw1,
      model.uw2,
      model.uw3,
      model.uw4,
      model.uw5,
      model.uw6,
      model.bw1,
      model.bw2,
      model.bw3,
      model.tw1,
      model.tw2,
      model.tw3,
      model.tw4,
    ]
    |> list.flatten
    |> list.fold(0, fn(sum, entry) { sum + entry.1 })

  Parser(
    total:,
    uw1: dict.from_list(model.uw1),
    uw2: dict.from_list(model.uw2),
    uw3: dict.from_list(model.uw3),
    uw4: dict.from_list(model.uw4),
    uw5: dict.from_list(model.uw5),
    uw6: dict.from_list(model.uw6),
    bw1: dict.from_list(model.bw1),
    bw2: dict.from_list(model.bw2),
    bw3: dict.from_list(model.bw3),
    tw1: dict.from_list(model.tw1),
    tw2: dict.from_list(model.tw2),
    tw3: dict.from_list(model.tw3),
    tw4: dict.from_list(model.tw4),
  )
}

pub fn parse(parser: Parser, sentence: String) -> List(String) {
  case to_chars(sentence) {
    [] -> []
    [first, ..] as chars -> {
      let window =
        list.flatten([[None, None], list.map(chars, Some), [None, None]])

      do_parse(parser, window, first, [])
    }
  }
}

fn to_chars(sentence: String) -> List(String) {
  sentence
  |> string.to_utf_codepoints
  |> list.map(fn(codepoint) { string.from_utf_codepoints([codepoint]) })
}

fn do_parse(
  parser: Parser,
  window: List(Option(String)),
  phrase: String,
  phrases: List(String),
) -> List(String) {
  case window {
    [prev3, prev2, prev1, Some(char) as current, next1, next2, ..rest] -> {
      let score = score(parser, prev3, prev2, prev1, current, next1, next2)

      let #(phrase, phrases) = case 2 * score > parser.total {
        True -> #(char, [phrase, ..phrases])
        False -> #(phrase <> char, phrases)
      }

      do_parse(
        parser,
        [prev2, prev1, current, next1, next2, ..rest],
        phrase,
        phrases,
      )
    }
    _ -> list.reverse([phrase, ..phrases])
  }
}

fn score(
  parser: Parser,
  prev3: Option(String),
  prev2: Option(String),
  prev1: Option(String),
  current: Option(String),
  next1: Option(String),
  next2: Option(String),
) -> Int {
  unigram(parser.uw1, prev3)
  + unigram(parser.uw2, prev2)
  + unigram(parser.uw3, prev1)
  + unigram(parser.uw4, current)
  + unigram(parser.uw5, next1)
  + unigram(parser.uw6, next2)
  + bigram(parser.bw1, prev2, prev1)
  + bigram(parser.bw2, prev1, current)
  + bigram(parser.bw3, current, next1)
  + trigram(parser.tw1, prev3, prev2, prev1)
  + trigram(parser.tw2, prev2, prev1, current)
  + trigram(parser.tw3, prev1, current, next1)
  + trigram(parser.tw4, current, next1, next2)
}

fn unigram(group: Dict(String, Int), a: Option(String)) -> Int {
  case a {
    Some(a) -> lookup(group, a)
    None -> 0
  }
}

fn bigram(
  group: Dict(String, Int),
  a: Option(String),
  b: Option(String),
) -> Int {
  case a, b {
    Some(a), Some(b) -> lookup(group, a <> b)
    _, _ -> 0
  }
}

fn trigram(
  group: Dict(String, Int),
  a: Option(String),
  b: Option(String),
  c: Option(String),
) -> Int {
  case a, b, c {
    Some(a), Some(b), Some(c) -> lookup(group, a <> b <> c)
    _, _, _ -> 0
  }
}

fn lookup(group: Dict(String, Int), key: String) -> Int {
  dict.get(group, key) |> result.unwrap(0)
}
