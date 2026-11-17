use gleam.nu

const models = [ja, ja_word, th, zh-hans, zh-hant]
const groups = [UW1, UW2, UW3, UW4, UW5, UW6, BW1, BW2, BW3, TW1, TW2, TW3, TW4]
const out = path self ../src/budoux/model

def main [upstream: path] {
    let version = open ($upstream | path join javascript package.json) | get version
    mkdir $out

    for name in $models {
        let model = open ($upstream | path join budoux models $"($name).json")
        let module = $name | str replace '-' '_'

        check $name $model
        $model | render $version | save -f ($out | path join $"($module).gleam")
    }

    ^gleam format $out
}

def check [name: string, model: record] {
    let unknown = $model | columns | where $it not-in $groups
    if ($unknown | is-not-empty) {
        error make { msg: $"($name) has unknown groups: ($unknown | str join ', ')" }
    }

    for group in ($model | columns) {
        let length = { U: 1, B: 2, T: 3 } | get ($group | str substring 0..0)
        let keys = $model | get $group | columns | where ($it | str length --chars) != $length

        for key in $keys {
            print -e $"warning: ($name) ($group) has a key of unexpected length: ($key)"
        }
    }
}

def render [version: string]: record -> string {
    let model = $in
    let fields = $groups | each {|group|
        let entries = $model | get -o $group | default {} | transpose key score | sort-by key
        let items = $entries | each {|entry| $"#\(($entry.key | gleam string-literal), ($entry.score)\)" }

        $"($group | str lowercase): [($items | str join ', ')]"
    }

    [
        $"// Generated from google/budoux v($version) by codegen/models.nu. Do not edit."
        ""
        "import budoux/model.{Model}"
        ""
        $"pub const model = Model\(($fields | str join ', ')\)"
    ]
    | str join "\n"
}
