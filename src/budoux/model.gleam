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
