# Default Nushell Environment Config File
# These "sensible defaults" are set before the user's `env.nu` is loaded
#
# version = "0.103.1"

$env.PROMPT_COMMAND = {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

$env.PROMPT_COMMAND_RIGHT = {||
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

$env.path ++= ["/usr/local/bin"]
$env.path ++= ["/opt/homebrew/bin"]
$env.path ++= ["/Users/dimitrios.kaikonidis/.cargo/bin"]
$env.path ++= ["/opt/homebrew/opt/postgresql@15/bin"]
$env.path ++= ["/opt/homebrew/opt/openjdk/bin"]

if not (which fnm | is-empty) {
  ^fnm env --json | from json | load-env
  $env.PATH = ($env.PATH | prepend [
    $"($env.FNM_MULTISHELL_PATH)/bin"
  ])
}

zoxide init nushell | save -f ~/.zoxide.nu

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Set Editor
$env.EDITOR = "nvim"
