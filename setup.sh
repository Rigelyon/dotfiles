#!/bin/bash
# setup.sh — Dotfiles manager using GNU Stow
# https://github.com/Rigelyon/dotfiles
set -uo pipefail

# ──────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────

readonly VERSION="2.0.0"
readonly BACKUP_SUFFIX=".dotfiles-backup"
readonly DOTFILES_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
readonly LOCK_FILE="/tmp/dotfiles-setup-$(id -u).lock"

# Colors (disabled when piped / not a terminal)
if [[ -t 1 ]]; then
    readonly RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m'
    readonly BLUE=$'\033[0;34m' BOLD=$'\033[1m' DIM=$'\033[2m' NC=$'\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' BOLD='' DIM='' NC=''
fi

# Directories that are safe to exist in $HOME (not treated as stow conflicts)
readonly SAFE_DIRS=("." ".config" ".local" ".local/share" ".local/bin"
                    ".local/state" ".cache" ".ssh" ".gnupg" "bin")

# ──────────────────────────────────────────────
# Mutable State
# ──────────────────────────────────────────────

REPORT=()
DRY_RUN=0
GLOBAL_CONFLICT_ACTION=""
GLOBAL_LINK_ACTION=""
GLOBAL_RESTOW_ACTION=""
GLOBAL_RESTORE_ACTION=""

# ──────────────────────────────────────────────
# Utilities
# ──────────────────────────────────────────────

log_info()    { printf "%s%s%s\n" "$BLUE"   "$*" "$NC"; }
log_success() { printf "%s%s%s\n" "$GREEN"  "$*" "$NC"; }
log_warn()    { printf "%s%s%s\n" "$YELLOW" "$*" "$NC"; }
log_error()   { printf "%s%s%s\n" "$RED"    "$*" "$NC" >&2; }

add_report() { REPORT+=("$1"); }

command_exists() { command -v "$1" >/dev/null 2>&1; }

resolve_path() { readlink -f "$1" 2>/dev/null || printf '%s' "$1"; }

is_safe_dir() {
    local rel_path="$1"
    local w
    for w in "${SAFE_DIRS[@]}"; do
        [[ "$rel_path" == "$w" ]] && return 0
    done
    return 1
}

print_header() {
    printf "%s" "$BLUE"
    cat <<'BANNER'
     ____       __  _____ __
    / __ \____ / /_/ __(_) /__  _____
   / / / / __ \/ __/ /_/ / / _ \/ ___/
  / /_/ / /_/ / /_/ __/ / /  __(__  )
 /_____/\____/\__/_/ /_/_/\___/____/
BANNER
    printf "     Setup Script v%s\n%s\n" "$VERSION" "$NC"
}

# ──────────────────────────────────────────────
# Lock & Cleanup
# ──────────────────────────────────────────────

cleanup() {
    rm -f "$LOCK_FILE"
    find "$DOTFILES_DIR" -maxdepth 1 \( -name '*.tmp' -o -name '*.new' \) -delete 2>/dev/null || true
    printf "\n%sInterrupted. Cleaned up.%s\n" "$YELLOW" "$NC"
    exit 130
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid="$(cat "$LOCK_FILE" 2>/dev/null || true)"
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_error "Another instance is running (PID $pid). Exiting."
            exit 1
        fi
        rm -f "$LOCK_FILE"
    fi
    printf '%s' $$ > "$LOCK_FILE"
    trap cleanup INT TERM
}

release_lock() {
    rm -f "$LOCK_FILE"
    trap - INT TERM
}

# ──────────────────────────────────────────────
# Package Helpers
# ──────────────────────────────────────────────

# Print sorted stow-package directory names (one per line)
get_package_dirs() {
    local dirs=()
    for d in "$DOTFILES_DIR"/*/; do
        [[ -d "$d" ]] || continue
        local name
        name="$(basename "$d")"
        [[ "$name" == ".git" ]] && continue
        dirs+=("$name")
    done
    printf '%s\n' "${dirs[@]}" | sort
}

# Populate: _linked  _total  _status   for a package
get_link_status() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    _linked=0; _total=0

    while IFS= read -r file; do
        _total=$((_total + 1))
        local real_target real_source
        real_target="$(resolve_path "$HOME/${file#"$pkg_dir/"}")"
        real_source="$(resolve_path "$file")"
        [[ "$real_target" == "$real_source" ]] && _linked=$((_linked + 1))
    done < <(find "$pkg_dir" -type f 2>/dev/null)

    if   (( _total == 0 ));            then _status="EMPTY"
    elif (( _linked == _total ));      then _status="LINKED"
    elif (( _linked > 0 ));            then _status="PARTIAL"
    else                                    _status="NOT LINKED"
    fi
}

# ──────────────────────────────────────────────
# Dependencies  (dependencies.conf)
# ──────────────────────────────────────────────
# Format:  package:command[,alt_command,...]
#   • Comma-separated = alternatives  (any match → installed)
#   • Empty command   → no CLI check available

declare -A PACKAGE_MAP

read_dependencies() {
    local config_file="$DOTFILES_DIR/dependencies.conf"
    PACKAGE_MAP=()
    [[ -f "$config_file" ]] || { log_warn "dependencies.conf not found."; return; }

    while IFS=: read -r pkg cmds; do
        [[ "$pkg" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${pkg// }" ]]           && continue
        # Trim whitespace (pure bash, no xargs)
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"; pkg="${pkg%"${pkg##*[![:space:]]}"}"
        cmds="${cmds#"${cmds%%[![:space:]]*}"}"; cmds="${cmds%"${cmds##*[![:space:]]}"}"
        PACKAGE_MAP["$pkg"]="$cmds"
    done < "$config_file"
}

# Return 0 if ANY of the comma-separated commands exists
check_commands() {
    local cmds="$1" cmd
    IFS=',' read -ra arr <<< "$cmds"
    for cmd in "${arr[@]}"; do
        cmd="${cmd#"${cmd%%[![:space:]]*}"}"; cmd="${cmd%"${cmd##*[![:space:]]}"}"
        [[ -n "$cmd" ]] && command_exists "$cmd" && return 0
    done
    return 1
}

# Add or remove an entry in dependencies.conf
update_deps_conf() {
    local action="$1" pkg="$2" cmd="${3:-}"
    local deps_file="$DOTFILES_DIR/dependencies.conf"

    case "$action" in
        add)
            [[ ! -f "$deps_file" ]] && { echo "$pkg:$cmd" > "$deps_file"; return 0; }
            if grep -q "^${pkg}:" "$deps_file" 2>/dev/null; then
                log_warn "'$pkg' already in dependencies.conf"
                return 1
            fi
            {
                grep '^#' "$deps_file" 2>/dev/null || true
                { grep -v '^#' "$deps_file" | grep -v '^[[:space:]]*$' || true
                  echo "$pkg:$cmd"
                } | sort
            } > "$deps_file.tmp"
            mv "$deps_file.tmp" "$deps_file"
            ;;
        remove)
            [[ -f "$deps_file" ]] && sed -i "/^${pkg}:/d" "$deps_file"
            ;;
    esac
}

# ──────────────────────────────────────────────
# Status Display
# ──────────────────────────────────────────────

init_submodules() {
    log_info "Checking git submodules..."

    [[ ! -f "$DOTFILES_DIR/.gitmodules" ]] && { log_info "No submodules configured."; echo; return; }

    if ! command_exists git; then
        log_error "git not installed — cannot initialise submodules."
        add_report "ERROR: git not found"
        echo; return
    fi

    if git -C "$DOTFILES_DIR" submodule status 2>/dev/null | grep -q '^-'; then
        log_info "Initialising submodules..."
        if git -C "$DOTFILES_DIR" submodule update --init --recursive; then
            log_success "Submodules initialised."
            add_report "OK: git submodules initialised"
        else
            log_error "Failed to initialise submodules."
            add_report "ERROR: git submodule init failed"
        fi
    else
        log_success "All submodules up-to-date."
    fi
    echo
}

show_status() {
    read_dependencies

    # Merge package-dirs + dependency entries
    local -A all_pkgs
    local pkg
    for pkg in "${!PACKAGE_MAP[@]}"; do all_pkgs["$pkg"]=1; done
    while IFS= read -r pkg; do all_pkgs["$pkg"]=1; done < <(get_package_dirs)

    local sorted=()
    while IFS= read -r pkg; do sorted+=("$pkg"); done \
        < <(printf '%s\n' "${!all_pkgs[@]}" | sort)

    local config_pkgs=() dep_pkgs=()
    for pkg in "${sorted[@]}"; do
        [[ -d "$DOTFILES_DIR/$pkg" ]] && config_pkgs+=("$pkg") || dep_pkgs+=("$pkg")
    done


    # ── Config packages ──
    echo
    printf "  %s📦 Package Config Status%s\n" "$BOLD$BLUE" "$NC"
    printf "  %s╭───────────────────────────┬─────────────────┬─────────────────┬────────────╮%s\n" "$DIM" "$NC"
    
    local hdr
    hdr="$(printf "│ %-25s │ %-15s │ %-15s │ %-10s │" "Package" "Command" "Binary Found" "Linked")"
    printf "  %s%s%s\n" "$BOLD" "$hdr" "$NC"
    printf "  %s├───────────────────────────┼─────────────────┼─────────────────┼────────────┤%s\n" "$DIM" "$NC"

    for pkg in "${config_pkgs[@]}"; do
        local cmds="${PACKAGE_MAP[$pkg]:-$pkg}" found linked_str color found_str
        # found?
        if [[ -z "$cmds" ]]; then 
            found="N/A"
            found_str="N/A            "
        elif check_commands "$cmds";  then 
            found="✓"
            found_str="✓              "
        else 
            found="✗"
            found_str="✗              "
        fi
        # linked?
        get_link_status "$pkg"
        linked_str="$_status"
        # colour
        if [[ "$found" == "✗" || "$_status" == "NOT LINKED" ]]; then color="$RED"
        elif [[ "$_status" == "PARTIAL" ]]; then color="$YELLOW"
        else color="$GREEN"; fi
        # truncate long command lists for display
        local cdisplay="${cmds:0:13}"
        (( ${#cmds} > 13 )) && cdisplay="${cdisplay}.."

        local line
        line="$(printf "│ %-25s │ %-15s │ %s │ %-10s │" "$pkg" "$cdisplay" "$found_str" "$linked_str")"
        printf "  %s%s%s\n" "$color" "$line" "$NC"
        add_report "STATUS: $pkg  found=$found  linked=$_status"
    done
    printf "  %s╰───────────────────────────┴─────────────────┴─────────────────┴────────────╯%s\n" "$DIM" "$NC"

    # ── Dependency-only packages ──
    if (( ${#dep_pkgs[@]} > 0 )); then
        echo
        printf "  %s⚙️  Package Without Config%s\n" "$BOLD$BLUE" "$NC"
        printf "  %s╭───────────────────────────┬─────────────────┬─────────────────╮%s\n" "$DIM" "$NC"
        hdr="$(printf "│ %-25s │ %-15s │ %-15s │" "Package" "Command" "Binary Found")"
        printf "  %s%s%s\n" "$BOLD" "$hdr" "$NC"
        printf "  %s├───────────────────────────┼─────────────────┼─────────────────┤%s\n" "$DIM" "$NC"

        for pkg in "${dep_pkgs[@]}"; do
            local cmds="${PACKAGE_MAP[$pkg]:-$pkg}" found color="$NC" found_str
            if [[ -z "$cmds" ]]; then 
                found="N/A"
                found_str="N/A            "
            elif check_commands "$cmds"; then 
                found="✓"; color="$GREEN"
                found_str="✓              "
            else 
                found="✗"; color="$RED"
                found_str="✗              "
            fi

            local line
            line="$(printf "│ %-25s │ %-15s │ %s │" "$pkg" "$cmds" "$found_str")"
            printf "  %s%s%s\n" "$color" "$line" "$NC"
        done
        printf "  %s╰───────────────────────────┴─────────────────┴─────────────────╯%s\n" "$DIM" "$NC"
    fi
    echo
    printf "  %s💡 Note: Package mappings and command checks are loaded from %sdependencies.conf%s\n" "$DIM" "$BOLD" "$NC"
    printf "  %s   There might be some packages available in your OS but not yet mapped%s\n" "$DIM" "$NC"
    echo
}

# ──────────────────────────────────────────────
# Link
# ──────────────────────────────────────────────

link_config() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    local conflicts=() linked=0 total=0 ready=0

    log_info "[$pkg]"

    # ── directory conflicts ──
    while IFS= read -r dir; do
        local rel="${dir#"$pkg_dir/"}"
        [[ -z "$rel" ]] && continue
        is_safe_dir "$rel" && continue
        local target="$HOME/$rel"
        if [[ -d "$target" && ! -L "$target" ]]; then
            local rt rs
            rt="$(resolve_path "$target")"; rs="$(resolve_path "$dir")"
            [[ "$rt" == "$rs" ]] && continue
            conflicts+=("$rel/ (existing directory)")
        fi
    done < <(find "$pkg_dir" -type d 2>/dev/null)

    # ── file status ──
    while IFS= read -r file; do
        total=$((total + 1))
        local rel="${file#"$pkg_dir/"}"
        local target="$HOME/$rel"
        local rt rs
        rt="$(resolve_path "$target")"; rs="$(resolve_path "$file")"
        if   [[ "$rt" == "$rs" ]];                          then linked=$((linked + 1))
        elif [[ -e "$target" || -L "$target" ]];            then conflicts+=("$rel")
        else                                                     ready=$((ready + 1))
        fi
    done < <(find "$pkg_dir" -type f 2>/dev/null)

    # ── decide action ──
    local action=""

    if (( ${#conflicts[@]} > 0 )); then
        log_warn "  Conflicts: ${#conflicts[@]} file(s)"
        local c; for c in "${conflicts[@]:0:3}"; do echo "    - $c"; done
        (( ${#conflicts[@]} > 3 )) && echo "    … and $((${#conflicts[@]} - 3)) more"

        if [[ -n "$GLOBAL_CONFLICT_ACTION" ]]; then
            action="$GLOBAL_CONFLICT_ACTION"
            echo "  → Global: $action"
        else
            echo "  1) Backup & link      2) Overwrite   3) Skip"
            echo "  4) Backup ALL         5) Overwrite ALL   6) Skip ALL"
            read -rp "  Select [1-6]: " choice
            case "${choice:-3}" in
                1) action="BACKUP" ;;
                2) action="OVERWRITE" ;;
                4) action="BACKUP";     GLOBAL_CONFLICT_ACTION="BACKUP" ;;
                5) action="OVERWRITE";  GLOBAL_CONFLICT_ACTION="OVERWRITE" ;;
                6) action="SKIP";       GLOBAL_CONFLICT_ACTION="SKIP" ;;
                *) action="SKIP" ;;
            esac
        fi

    elif (( linked == total && total > 0 )); then
        if [[ -n "$GLOBAL_RESTOW_ACTION" ]]; then
            [[ "$GLOBAL_RESTOW_ACTION" == "YES" ]] && action="RESTOW" || action="SKIP"
        else
            read -rp "  Already linked. Re-stow? [y/N/a=all/s=skip all]: " choice
            case "${choice:-n}" in
                [Yy]) action="RESTOW" ;;
                [Aa]) action="RESTOW"; GLOBAL_RESTOW_ACTION="YES" ;;
                [Ss]) action="SKIP";   GLOBAL_RESTOW_ACTION="SKIP" ;;
                *)    action="SKIP" ;;
            esac
        fi

    else
        echo "  Ready: $ready new, $linked linked, $total total"
        if [[ -n "$GLOBAL_LINK_ACTION" ]]; then
            [[ "$GLOBAL_LINK_ACTION" == "YES" ]] && action="LINK" || action="SKIP"
        else
            read -rp "  Link? [y/N/a=all/s=skip all]: " choice
            case "${choice:-n}" in
                [Yy]) action="LINK" ;;
                [Aa]) action="LINK"; GLOBAL_LINK_ACTION="YES" ;;
                [Ss]) action="SKIP";    GLOBAL_LINK_ACTION="SKIP" ;;
                *)    action="SKIP" ;;
            esac
        fi
    fi

    # ── execute ──
    case "$action" in
        BACKUP)
            if (( DRY_RUN )); then
                log_info "  [DRY RUN] Would backup & link $pkg"
                add_report "DRY RUN: $pkg (backup)"; return
            fi
            while IFS= read -r file; do
                local rel="${file#"$pkg_dir/"}"
                local target="$HOME/$rel"
                if [[ -e "$target" || -L "$target" ]]; then
                    local rt rs
                    rt="$(resolve_path "$target")"; rs="$(resolve_path "$file")"
                    if [[ "$rt" != "$rs" ]]; then
                        echo "  Backup: $rel"
                        mv "$target" "${target}${BACKUP_SUFFIX}"
                        add_report "BACKED UP: $target"
                    fi
                fi
            done < <(find "$pkg_dir" -type f 2>/dev/null)
            stow -d "$DOTFILES_DIR" -t "$HOME" -v "$pkg"
            log_success "  ✓ Linked (with backups)"
            add_report "LINKED: $pkg (with backups)"
            ;;
        OVERWRITE)
            if (( DRY_RUN )); then
                log_info "  [DRY RUN] Would overwrite & link $pkg"
                add_report "DRY RUN: $pkg (overwrite)"; return
            fi
            # remove conflicting directories
            while IFS= read -r dir; do
                local rel="${dir#"$pkg_dir/"}"
                [[ -z "$rel" || "$rel" == /* ]] && continue
                is_safe_dir "$rel" && continue
                local target="$HOME/$rel"
                local rt; rt="$(resolve_path "$target")"
                [[ "$rt" == "$DOTFILES_DIR"* ]] && continue
                if [[ -d "$target" && ! -L "$target" ]]; then
                    echo "  Remove dir: $rel"
                    rm -rf "$target"
                    add_report "DELETED DIR: $target"
                fi
            done < <(find "$pkg_dir" -mindepth 1 -type d 2>/dev/null)
            # remove conflicting files
            while IFS= read -r file; do
                local rel="${file#"$pkg_dir/"}"
                [[ -z "$rel" || "$rel" == /* ]] && continue
                local target="$HOME/$rel"
                local rt rs
                rt="$(resolve_path "$target")"; rs="$(resolve_path "$file")"
                [[ "$rt" == "$DOTFILES_DIR"* ]] && continue
                if [[ (-e "$target" || -L "$target") && "$rt" != "$rs" ]]; then
                    echo "  Remove: $rel"
                    rm -f "$target"
                    add_report "DELETED: $target"
                fi
            done < <(find "$pkg_dir" -mindepth 1 -type f 2>/dev/null)
            stow -d "$DOTFILES_DIR" -t "$HOME" -R -v "$pkg"
            log_success "  ✓ Linked (overwrite)"
            add_report "LINKED: $pkg (overwrite)"
            ;;
        LINK)
            if (( DRY_RUN )); then
                log_info "  [DRY RUN] Would link $pkg"
                add_report "DRY RUN: $pkg"; return
            fi
            stow -d "$DOTFILES_DIR" -t "$HOME" -v "$pkg"
            log_success "  ✓ Linked"
            add_report "LINKED: $pkg"
            ;;
        RESTOW)
            if (( DRY_RUN )); then
                log_info "  [DRY RUN] Would restow $pkg"
                add_report "DRY RUN: $pkg (restow)"; return
            fi
            stow -d "$DOTFILES_DIR" -t "$HOME" -R -v "$pkg"
            log_success "  ✓ Re-stowed"
            add_report "RESTOWED: $pkg"
            ;;
        SKIP)
            echo "  Skipped"
            add_report "SKIPPED: $pkg"
            ;;
    esac
}

# ──────────────────────────────────────────────
# Restore
# ──────────────────────────────────────────────

restore_config() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    local backup_entries=()

    while IFS= read -r file; do
        local rel="${file#"$pkg_dir/"}"
        local bp="$HOME/${rel}${BACKUP_SUFFIX}"
        [[ -e "$bp" ]] && backup_entries+=("$bp|$HOME/$rel")
    done < <(find "$pkg_dir" -type f 2>/dev/null)

    (( ${#backup_entries[@]} == 0 )) && return

    log_info "[$pkg] ${#backup_entries[@]} backup(s)"

    local action=""
    if [[ -n "$GLOBAL_RESTORE_ACTION" ]]; then
        action="$GLOBAL_RESTORE_ACTION"
    else
        read -rp "  Restore? [y/N/a=all/s=skip all]: " choice
        case "${choice:-n}" in
            [Yy]) action="RESTORE" ;;
            [Aa]) action="RESTORE"; GLOBAL_RESTORE_ACTION="RESTORE" ;;
            [Ss]) action="SKIP";    GLOBAL_RESTORE_ACTION="SKIP" ;;
            *)    action="SKIP" ;;
        esac
    fi

    if [[ "$action" == "RESTORE" ]]; then
        if (( DRY_RUN )); then
            log_info "  [DRY RUN] Would restore $pkg"
            add_report "DRY RUN: restore $pkg"; return
        fi
        local entry
        for entry in "${backup_entries[@]}"; do
            local bp="${entry%|*}" tp="${entry#*|}"
            [[ -e "$tp" || -L "$tp" ]] && rm -rf "$tp"
            mv "$bp" "$tp"
            log_success "  ✓ Restored $(basename "$tp")"
            add_report "RESTORED: $tp"
        done
        stow -d "$DOTFILES_DIR" -t "$HOME" -D -v "$pkg" 2>/dev/null || true
        add_report "UNSTOWED: $pkg"
    else
        add_report "SKIPPED RESTORE: $pkg"
    fi
}

# ──────────────────────────────────────────────
# Add New Config
# ──────────────────────────────────────────────

add_new_config() {
    log_info "=== Add New Config Package ==="
    echo

    # ── package name ──
    local pkg_name
    while true; do
        read -rp "Package name: " pkg_name
        [[ -z "$pkg_name" ]]              && { log_error "Cannot be empty."; continue; }
        [[ "$pkg_name" =~ ^[a-zA-Z0-9_-]+$ ]] || { log_error "Only [a-zA-Z0-9_-] allowed."; continue; }
        break
    done

    # ── existing dir? ──
    if [[ -d "$DOTFILES_DIR/$pkg_name" ]]; then
        log_warn "'$pkg_name' already exists as a directory."
        read -rp "Register in dependencies.conf only? [y/N]: " ch
        [[ ! "$ch" =~ ^[Yy]$ ]] && { echo "Cancelled."; return; }

        read -rp "Command to check (default: $pkg_name): " cmd_check
        cmd_check="${cmd_check:-$pkg_name}"
        update_deps_conf "add" "$pkg_name" "$cmd_check" && \
            log_success "✓ Registered '$pkg_name'"

        read -rp "Link now? [y/N]: " ch
        [[ "$ch" =~ ^[Yy]$ ]] && link_config "$pkg_name"
        add_report "REGISTERED: $pkg_name ($cmd_check)"
        return
    fi

    # ── command ──
    read -rp "Command to check (default: $pkg_name): " cmd_check
    cmd_check="${cmd_check:-$pkg_name}"

    # ── config path ──
    local rel_path
    while true; do
        echo
        echo "Examples:"
        echo "  (Press Enter)            → .config/$pkg_name/"
        echo "  .bashrc                  → $pkg_name/.bashrc"
        echo "  .config/tmux/tmux.conf   → $pkg_name/.config/tmux/tmux.conf"
        echo
        read -rp "Path relative to \$HOME (default: .config/$pkg_name): " rel_path
        rel_path="${rel_path:-.config/$pkg_name}"
        [[ "$rel_path" =~ ^[/~] ]] && { log_error "No / or ~ prefix.";  continue; }
        break
    done

    local home_path="$HOME/$rel_path"
    local pkg_path="$DOTFILES_DIR/$pkg_name/$rel_path"
    local parent_dir
    parent_dir="$(dirname "$pkg_path")"

    if [[ -e "$home_path" || -L "$home_path" ]]; then
        # ── import existing ──
        log_warn "Found existing: $home_path"
        echo "  1) Import to repository   2) Cancel"
        read -rp "  Select [1-2]: " ch
        [[ "$ch" != "1" ]] && { echo "Cancelled."; return; }

        mkdir -p "$parent_dir"
        if [[ -d "$home_path" && ! -L "$home_path" ]]; then
            cp -r "$home_path" "$parent_dir/"
            log_success "✓ Imported directory: $rel_path"
        else
            cp "$home_path" "$pkg_path"
            log_success "✓ Imported file: $rel_path"
        fi
    else
        # ── create new ──
        mkdir -p "$parent_dir"
        if [[ "$rel_path" == *.* || "$rel_path" =~ (rc|conf|profile|env)$ ]]; then
            printf "# %s configuration\n" "$pkg_name" > "$pkg_path"
            log_success "✓ Created file: $pkg_name/$rel_path"
        else
            mkdir -p "$pkg_path"
            log_success "✓ Created directory: $pkg_name/$rel_path"
        fi
    fi

    update_deps_conf "add" "$pkg_name" "$cmd_check"
    log_success "✓ Updated dependencies.conf"
    echo

    log_success "Package '$pkg_name' added!"
    read -rp "Link now? [y/N]: " ch
    [[ "$ch" =~ ^[Yy]$ ]] && link_config "$pkg_name"

    add_report "ADDED: $pkg_name ($cmd_check, $rel_path)"
}

# ──────────────────────────────────────────────
# Delete Config
# ──────────────────────────────────────────────

delete_config() {
    while true; do
        log_info "=== Delete Config Package ==="
        echo

        # build selection list
        local packages=()
        while IFS= read -r pkg; do packages+=("$pkg"); done < <(get_package_dirs)

        read_dependencies
        local orphans=()
        for pkg in "${!PACKAGE_MAP[@]}"; do
            [[ ! -d "$DOTFILES_DIR/$pkg" ]] && orphans+=("$pkg")
        done

        if (( ${#packages[@]} == 0 && ${#orphans[@]} == 0 )); then
            log_warn "No packages found."
            return
        fi

        local items=()
        for pkg in "${packages[@]}"; do
            get_link_status "$pkg"
            local color="$NC"
            case "$_status" in
                LINKED)       color="$GREEN" ;;
                PARTIAL)      color="$YELLOW" ;;
                "NOT LINKED") color="$RED" ;;
            esac
            items+=("dir:$pkg")
            local line
            line="$(printf "  %2d) %-25s [%s]" "${#items[@]}" "$pkg" "$_status")"
            printf "%s%s%s\n" "$color" "$line" "$NC"
        done
        for o in "${orphans[@]}"; do
            items+=("orphan:$o")
            local line
            line="$(printf "  %2d) %-25s [ORPHAN]" "${#items[@]}" "$o")"
            printf "%s%s%s\n" "$YELLOW" "$line" "$NC"
        done

        echo
        read -rp "Select (0 to cancel): " num
        [[ ! "$num" =~ ^[0-9]+$ || "$num" -eq 0 ]] && return
        local idx=$((num - 1))
        (( idx >= ${#items[@]} )) && { log_error "Invalid."; continue; }

        local sel="${items[$idx]}"
        local kind="${sel%%:*}" name="${sel#*:}"

        if [[ "$kind" == "orphan" ]]; then
            read -rp "Remove orphan '$name' from deps? [y/N]: " ch
            if [[ "$ch" =~ ^[Yy]$ ]]; then
                update_deps_conf "remove" "$name"
                log_success "✓ Cleaned: $name"
                add_report "CLEANED ORPHAN: $name"
            fi
        else
            echo
            echo "  1) Unlink only (remove symlinks)"
            echo "  2) Full remove (unlink + delete from repo)"
            echo "  3) Cancel"
            read -rp "  Select [1-3]: " ch

            case "${ch:-3}" in
                1)
                    get_link_status "$name"
                    if (( _linked == 0 )); then
                        log_warn "  '$name' is not linked."
                        add_report "SKIP UNLINK: $name"
                    else
                        if (( DRY_RUN )); then
                            log_info "  [DRY RUN] Would unlink $name"
                        else
                            stow -d "$DOTFILES_DIR" -t "$HOME" -D -v "$name"
                            log_success "  ✓ Unlinked $name"
                            add_report "UNLINKED: $name"
                        fi
                    fi
                    ;;
                2)
                    printf "  %sWARNING: Permanently deletes '%s'!%s\n" "$RED" "$name" "$NC"
                    read -rp "  Confirm? [y/N]: " ch
                    [[ ! "$ch" =~ ^[Yy]$ ]] && { echo "  Cancelled."; continue; }

                    if (( DRY_RUN )); then
                        log_info "  [DRY RUN] Would fully remove $name"
                    else
                        get_link_status "$name"
                        (( _linked > 0 )) && {
                            stow -d "$DOTFILES_DIR" -t "$HOME" -D -v "$name" 2>/dev/null || true
                            add_report "UNLINKED: $name"
                        }
                        rm -rf "$DOTFILES_DIR/$name"
                        update_deps_conf "remove" "$name"
                        log_success "  ✓ Fully removed $name"
                        add_report "REMOVED: $name"
                    fi
                    ;;
                *) echo "  Cancelled." ;;
            esac
        fi

        echo
        read -rp "Delete another? [y/N]: " ch
        [[ ! "$ch" =~ ^[Yy]$ ]] && break
    done
}

# ──────────────────────────────────────────────
# Report
# ──────────────────────────────────────────────

print_report() {
    (( ${#REPORT[@]} == 0 )) && return

    echo
    echo "════════════════ REPORT ════════════════"
    local item
    for item in "${REPORT[@]}"; do
        [[ -n "$item" ]] && echo "  $item"
    done
    echo "════════════════════════════════════════"

    read -rp "Save report? [y/N]: " ch
    if [[ "$ch" =~ ^[Yy]$ ]]; then
        local file="dotfiles_report_$(date +%Y%m%d_%H%M%S).txt"
        printf "%s\n" "${REPORT[@]}" > "$DOTFILES_DIR/$file"
        log_success "Saved: $file"
    fi
}

# ──────────────────────────────────────────────
# CLI Commands
# ──────────────────────────────────────────────

cmd_link() {
    local link_all=0 specific=()
    local arg
    for arg in "$@"; do
        case "$arg" in
            --all) link_all=1 ;;
            *)     specific+=("$arg") ;;
        esac
    done

    init_submodules
    show_status

    local pkgs=()
    if (( ${#specific[@]} > 0 )); then
        pkgs=("${specific[@]}")
    else
        while IFS= read -r p; do pkgs+=("$p"); done < <(get_package_dirs)
    fi

    if (( link_all )); then
        GLOBAL_LINK_ACTION="YES"
        GLOBAL_RESTOW_ACTION="YES"
        GLOBAL_CONFLICT_ACTION="BACKUP"
    fi

    echo "Starting linking process…"
    echo

    local i=0
    for pkg in "${pkgs[@]}"; do
        i=$((i + 1))
        if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
            log_error "Package '$pkg' not found."
            continue
        fi
        printf "%s[%d/%d]%s " "$DIM" "$i" "${#pkgs[@]}" "$NC"
        link_config "$pkg"
    done
}

cmd_restore() {
    local restore_all=0 specific=()
    local arg
    for arg in "$@"; do
        case "$arg" in
            --all) restore_all=1 ;;
            *)     specific+=("$arg") ;;
        esac
    done

    (( restore_all )) && GLOBAL_RESTORE_ACTION="RESTORE"

    local pkgs=()
    if (( ${#specific[@]} > 0 )); then
        pkgs=("${specific[@]}")
    else
        while IFS= read -r p; do pkgs+=("$p"); done < <(get_package_dirs)
    fi

    log_info "Restoring backups…"
    echo

    local i=0
    for pkg in "${pkgs[@]}"; do
        i=$((i + 1))
        if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
            log_error "Package '$pkg' not found."
            continue
        fi
        printf "%s[%d/%d]%s " "$DIM" "$i" "${#pkgs[@]}" "$NC"
        restore_config "$pkg"
    done
}

# ──────────────────────────────────────────────
# Interactive Menu
# ──────────────────────────────────────────────

interactive_menu() {
    while true; do
        print_header

        if ! command_exists stow; then
            log_error "GNU Stow is not installed. Please install it first."
            exit 1
        fi

        echo "  1) Link / Update Configs"
        echo "  2) Restore Backups"
        echo "  3) Add New Config"
        echo "  4) Delete Config"
        echo "  5) Show Status"
        echo "  6) Exit"
        echo
        read -rp "Select [1-6]: " opt

        # Reset per-run state
        REPORT=()
        GLOBAL_CONFLICT_ACTION=""
        GLOBAL_LINK_ACTION=""
        GLOBAL_RESTOW_ACTION=""
        GLOBAL_RESTORE_ACTION=""

        case "${opt:-6}" in
            1) cmd_link ;;
            2) cmd_restore ;;
            3) add_new_config ;;
            4) delete_config ;;
            5) show_status ;;
            6) exit 0 ;;
            *) log_error "Invalid option." ;;
        esac

        print_report
        echo
        read -rp "Press Enter to continue…"
    done
}

# ──────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: $(basename "$0") [command] [options]

Commands:
  link [--all] [pkg …]      Link / update configs
  restore [--all] [pkg …]   Restore backed-up configs
  add                        Add a new config package (interactive)
  delete                     Delete a config package (interactive)
  status                     Show package & link status
  help                       Show this help

Options:
  --dry-run   Show what would happen without making changes
  --version   Print version and exit

Examples:
  ./setup.sh                   Interactive menu
  ./setup.sh link --all        Link everything (backup on conflicts)
  ./setup.sh link nvim zsh     Link specific packages
  ./setup.sh status            Show overview
  ./setup.sh --dry-run link    Link with dry-run
EOF
}

# ──────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────

main() {
    local args=()
    local arg
    for arg in "$@"; do
        case "$arg" in
            --dry-run)  DRY_RUN=1 ;;
            --version)  echo "setup.sh v${VERSION}"; exit 0 ;;
            *)          args+=("$arg") ;;
        esac
    done

    acquire_lock

    if (( ${#args[@]} == 0 )); then
        interactive_menu
        # interactive_menu loops forever; unreachable
    fi

    local cmd="${args[0]}"
    local cmd_args=("${args[@]:1}")

    case "$cmd" in
        link)                cmd_link "${cmd_args[@]+"${cmd_args[@]}"}" ;;
        restore)             cmd_restore "${cmd_args[@]+"${cmd_args[@]}"}" ;;
        add)                 add_new_config ;;
        delete)              delete_config ;;
        status)              show_status ;;
        help|-h|--help)      usage ;;
        *)                   log_error "Unknown command: $cmd"; echo; usage; exit 1 ;;
    esac

    print_report
    release_lock
}

main "$@"
