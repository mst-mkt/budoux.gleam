import budoux/model.{Model}
import gleam/json

pub fn decodes_model_json_test() {
  let json = "{\"UW4\": {\"a\": 10000}, \"BW2\": {\"ab\": -10}}"

  let result = json.parse(json, model.decoder())

  assert result
    == Ok(Model(..model.empty, uw4: [#("a", 10_000)], bw2: [#("ab", -10)]))
}

pub fn fails_to_decode_non_integer_score_test() {
  let json = "{\"UW4\": {\"a\": \"10000\"}}"

  let result = json.parse(json, model.decoder())

  let assert Error(_) = result
}
