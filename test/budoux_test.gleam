import budoux
import budoux/model.{Model}
import gleam/list
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn separates_before_strong_feature_test() {
  let parser = budoux.new(Model(..model.empty, uw4: [#("a", 10_000)]))

  let result = budoux.parse(parser, "abcdeabcd")

  assert result == ["abcde", "abcd"]
}

pub fn separates_even_if_first_phrase_is_one_character_test() {
  let parser = budoux.new(Model(..model.empty, uw4: [#("b", 10_000)]))

  let result = budoux.parse(parser, "abcdeabcd")

  assert result == ["a", "bcdea", "bcd"]
}

pub fn separates_with_small_positive_score_test() {
  let parser = budoux.new(Model(..model.empty, uw4: [#("a", 100)]))

  let result = budoux.parse(parser, "xyzabc")

  assert result == ["xyz", "abc"]
}

pub fn parses_empty_sentence_test() {
  let parser = budoux.new(model.empty)

  let result = budoux.parse(parser, "")

  assert result == []
}

pub fn does_not_separate_inside_surrogate_pair_test() {
  let separating_everywhere =
    budoux.new(Model(..model.empty, uw4: [#("a", -10_000)]))

  let result = budoux.parse(separating_everywhere, "𠮷野家")

  assert result == ["𠮷", "野", "家"]
}

pub fn matches_features_with_surrogate_pairs_test() {
  let parser =
    budoux.new(Model(..model.empty, uw3: [#("𠮷", 1000)], bw2: [#("𠮷野", 1000)]))

  let result = budoux.parse(parser, "𠮷野家")

  assert result == ["𠮷", "野家"]
}

pub fn tracks_positions_with_multiple_surrogate_pairs_test() {
  let before_last_parser =
    budoux.new(Model(..model.empty, bw2: [#("𠮷家", 1000)]))
  let after_each_parser = budoux.new(Model(..model.empty, uw3: [#("𠮷", 1000)]))

  let before_last_result = budoux.parse(before_last_parser, "𠮷野𠮷家")
  let after_each_result = budoux.parse(after_each_parser, "𠮷野𠮷家")

  assert before_last_result == ["𠮷野𠮷", "家"]
  assert after_each_result == ["𠮷", "野𠮷", "家"]
}

pub fn matches_outer_window_features_across_surrogate_pair_test() {
  let uw2_parser = budoux.new(Model(..model.empty, uw2: [#("あ", 1000)]))
  let uw5_parser = budoux.new(Model(..model.empty, uw5: [#("い", 1000)]))

  let uw2_result = budoux.parse(uw2_parser, "あ𠮷い")
  let uw5_result = budoux.parse(uw5_parser, "あ𠮷い")

  assert uw2_result == ["あ𠮷", "い"]
  assert uw5_result == ["あ", "𠮷い"]
}

pub fn parses_one_character_sentence_test() {
  let parser = budoux.new(Model(..model.empty, uw4: [#("a", 10_000)]))

  let result = budoux.parse(parser, "a")

  assert result == ["a"]
}

pub fn parses_two_character_sentence_test() {
  let parser = budoux.new(Model(..model.empty, uw4: [#("b", 10_000)]))

  let result = budoux.parse(parser, "ab")

  assert result == ["a", "b"]
}

pub fn uses_characters_at_right_positions_for_each_group_test() {
  let cases = [
    #("uw1", Model(..model.empty, uw1: [#("a", 10_000)])),
    #("uw2", Model(..model.empty, uw2: [#("b", 10_000)])),
    #("uw3", Model(..model.empty, uw3: [#("c", 10_000)])),
    #("uw4", Model(..model.empty, uw4: [#("d", 10_000)])),
    #("uw5", Model(..model.empty, uw5: [#("e", 10_000)])),
    #("uw6", Model(..model.empty, uw6: [#("f", 10_000)])),
    #("bw1", Model(..model.empty, bw1: [#("bc", 10_000)])),
    #("bw2", Model(..model.empty, bw2: [#("cd", 10_000)])),
    #("bw3", Model(..model.empty, bw3: [#("de", 10_000)])),
    #("tw1", Model(..model.empty, tw1: [#("abc", 10_000)])),
    #("tw2", Model(..model.empty, tw2: [#("bcd", 10_000)])),
    #("tw3", Model(..model.empty, tw3: [#("cde", 10_000)])),
    #("tw4", Model(..model.empty, tw4: [#("def", 10_000)])),
  ]

  list.each(cases, fn(test_case) {
    let #(group, model) = test_case
    let parser = budoux.new(model)

    let result = budoux.parse(parser, "abcdef")

    assert result == ["abc", "def"] as group
  })
}

pub fn does_not_use_groups_beyond_sentence_edges_test() {
  let cases = [
    #("tw1", Model(..model.empty, tw1: [#("ab", 10_000)])),
    #("bw3", Model(..model.empty, bw3: [#("f", 10_000)])),
    #("tw4", Model(..model.empty, tw4: [#("ef", 10_000)])),
  ]

  list.each(cases, fn(test_case) {
    let #(group, model) = test_case
    let parser = budoux.new(model)

    let result = budoux.parse(parser, "abcdef")

    assert result == ["abcdef"] as group
  })
}

pub fn does_not_separate_when_score_is_exactly_half_of_total_test() {
  let parser =
    budoux.new(Model(..model.empty, uw3: [#("z", 1)], uw4: [#("a", 1)]))

  let result = budoux.parse(parser, "ba")

  assert result == ["ba"]
}

pub fn uses_exact_threshold_with_negative_odd_total_test() {
  let parser =
    budoux.new(Model(..model.empty, uw3: [#("z", -1)], uw4: [#("a", -2)]))

  let result = budoux.parse(parser, "zb")

  assert result == ["z", "b"]
}

pub fn separates_by_code_points_not_graphemes_test() {
  let parser = budoux.new(Model(..model.empty, uw3: [#("ก", 10_000)]))

  let result = budoux.parse(parser, "กี")

  assert result == ["ก", "ี"]
}

pub fn ja_parses_sentence_test() {
  let parser = budoux.ja()

  let result =
    budoux.parse(parser, "Google の使命は、世界中の情報を整理し、世界中の人がアクセスできて使えるようにすることです。")

  assert result
    == [
      "Google の", "使命は、", "世界中の", "情報を", "整理し、", "世界中の", "人が", "アクセスできて",
      "使えるように", "する", "ことです。",
    ]
}

pub fn ja_parses_short_sentence_test() {
  let parser = budoux.ja()

  let result = budoux.parse(parser, "今日は天気です。")

  assert result == ["今日は", "天気です。"]
}

pub fn ja_does_not_separate_around_whitespace_test() {
  let parser = budoux.ja()

  let result = budoux.parse(parser, " 1  \n  2 ")

  assert result == [" 1  \n  2 "]
}

pub fn zh_hans_parses_sentence_test() {
  let parser = budoux.zh_hans()

  let result = budoux.parse(parser, "我们的使命是整合全球信息，供大众使用，让人人受益。")

  assert result
    == [
      "我们", "的", "使命", "是", "整合", "全球", "信息，", "供", "大众", "使用，", "让", "人人",
      "受益。",
    ]
}

pub fn zh_hant_parses_sentence_test() {
  let parser = budoux.zh_hant()

  let result = budoux.parse(parser, "我們的使命是匯整全球資訊，供大眾使用，使人人受惠。")

  assert result
    == [
      "我們", "的", "使命", "是", "匯整", "全球", "資訊，", "供", "大眾", "使用，", "使", "人人",
      "受惠。",
    ]
}

pub fn th_parses_sentence_test() {
  let parser = budoux.th()

  let result = budoux.parse(parser, "วันนี้อากาศดี")

  assert result == ["วัน", "นี้", "อากาศ", "ดี"]
}
