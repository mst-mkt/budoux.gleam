import gleam/dict
import gleam/dynamic/decode

pub type Model {
  Model(
    uw1: List(#(String, Int)),
    uw2: List(#(String, Int)),
    uw3: List(#(String, Int)),
    uw4: List(#(String, Int)),
    uw5: List(#(String, Int)),
    uw6: List(#(String, Int)),
    bw1: List(#(String, Int)),
    bw2: List(#(String, Int)),
    bw3: List(#(String, Int)),
    tw1: List(#(String, Int)),
    tw2: List(#(String, Int)),
    tw3: List(#(String, Int)),
    tw4: List(#(String, Int)),
  )
}

pub const empty =
  Model(
    uw1: [],
    uw2: [],
    uw3: [],
    uw4: [],
    uw5: [],
    uw6: [],
    bw1: [],
    bw2: [],
    bw3: [],
    tw1: [],
    tw2: [],
    tw3: [],
    tw4: [],
  )

pub fn decoder() -> decode.Decoder(Model) {
  use uw1 <- group("UW1")
  use uw2 <- group("UW2")
  use uw3 <- group("UW3")
  use uw4 <- group("UW4")
  use uw5 <- group("UW5")
  use uw6 <- group("UW6")
  use bw1 <- group("BW1")
  use bw2 <- group("BW2")
  use bw3 <- group("BW3")
  use tw1 <- group("TW1")
  use tw2 <- group("TW2")
  use tw3 <- group("TW3")
  use tw4 <- group("TW4")

  decode.success(Model(
    uw1:,
    uw2:,
    uw3:,
    uw4:,
    uw5:,
    uw6:,
    bw1:,
    bw2:,
    bw3:,
    tw1:,
    tw2:,
    tw3:,
    tw4:,
  ))
}

fn group(
  name: String,
  next: fn(List(#(String, Int))) -> decode.Decoder(Model),
) -> decode.Decoder(Model) {
  let scores =
    decode.dict(decode.string, decode.int)
    |> decode.map(dict.to_list)

  decode.optional_field(name, [], scores, next)
}
