#!/usr/bin/env bash

############################  SETUP PARAMETERS
app_name='vim_dotfiles'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/vim_dotfiles"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/welkinspring/vim_dotfiles.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='3.0'
debug_mode='1'

# this is vim plugins manager tool which is tiny and agile
[ -z "$PLUG_URL" ] && PLUG_URL="https://raw.githubusercontent.com/welkinspring/vim-plug/master/plug.vim"


############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}


############################ SETUP FUNCTIONS

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ]; then
        msg "Attempting to back up your original vim configuration."
        today=`date +%Y%m%d_%s`
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today";
        done
        ret="$?"
        success "Your original vim configuration has been backed up."
        debug
   fi
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    debug
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    lnif "$source_path/.vimrc" 		"$target_path/.vimrc"
    lnif "$source_path/.vimrc.plugs" 	"$target_path/.vimrc.plugs"
    lnif "$source_path/.vimrc.before" 	"$target_path/.vimrc.before"
    #lnif "$source_path/.vim"           "$target_path/.vim"

    touch  "$target_path/.vimrc.local"

    ret="$?"
    success "Setting up vim symlinks."
    debug
}

install_plug() {
    local plug_path="$1"
    local plug_uri="$2"
    local plug_name="$3"
 
    curl -fLo "$plug_path/plug.vim" --create-dirs "$plug_uri"
    success "Successfully installed $plug_name for vim manager plugins"
    debug
}

setup_vim_plug() {
    local system_shell="$SHELL"
    export SHELL='/bin/sh'

    # TBD
    vim \
        -u "$1" \
        "+set nomore" \
        "+PlugClean" \
        "+PlugInstall" \
        "+qall"

    export SHELL="$system_shell"

    success "Now updating/installing plugins using vim-plug !"
    debug
}

############################ MAIN()
variable_set "$HOME"
program_must_exist "vim"
program_must_exist "git"
program_must_exist "curl"

do_backup       "$HOME/.vim" \
                "$HOME/.vimrc" \

sync_repo       "$APP_PATH" \
                "$REPO_URI" \
                "$REPO_BRANCH" \
                "$app_name"

create_symlinks "$APP_PATH" \
                "$HOME"

install_plug 	"$HOME/.vim/autoload" \
                "$PLUG_URL" \
                "vim-plug"

setup_vim_plug 	"$APP_PATH/.vimrc.plugs.default"

msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` https://github.com/welkinspring/vim_dotfiles"
