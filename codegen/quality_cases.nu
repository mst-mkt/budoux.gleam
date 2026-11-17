use gleam.nu

const out = path self ../test/budoux/quality_cases.gleam

def main [upstream: path] {
    let version = open ($upstream | path join javascript package.json) | get version
    mkdir ($out | path dirname)

    let cases = open --raw ($upstream | path join tests quality ja.tsv)
        | lines
        | where $it != "" and not ($it | str starts-with "#")
        | split column "\t" label sentence
        | each {|row| $"#\(($row.label | gleam string-literal), ($row.sentence | gleam string-literal)\)" }

    [
        $"// Generated from google/budoux v($version) by codegen/quality_cases.nu. Do not edit."
        ""
        $"pub const ja = [($cases | str join ', ')]"
    ]
    | str join "\n"
    | save -f $out

    ^gleam format $out
}
