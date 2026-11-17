export def string-literal []: string -> string {
    let escaped = $in | str replace -a '\' '\\' | str replace -a '"' '\"'

    $'"($escaped)"'
}
