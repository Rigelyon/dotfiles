#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_SUFFIX=".dotfiles-backup"

GLOBAL_CONFLICT_ACTION=""
GLOBAL_INSTALL_ACTION=""
GLOBAL_RESTOW_ACTION=""
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
    ____       __  _____ __
   / __ \____ / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/
    Setup Script
EOF
    echo -e "${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}
REPORT=()

add_report() {
    REPORT+=("$1")
}

declare -A PACKAGE_MAP
read_dependencies() {
    local config_file="$DOTFILES_DIR/dependencies.conf"
    if [ -f "$config_file" ]; then
        while IFS=':' read -r pkg cmd; do
            [[ "$pkg" =~ ^#.*$ ]] && continue
            [[ -z "$pkg" ]] && continue
            pkg=$(echo "$pkg" | xargs)
            cmd=$(echo "$cmd" | xargs)
            PACKAGE_MAP["$pkg"]="$cmd"
        done < "$config_file"
    else
        echo -e "${YELLOW}Warning: dependencies.conf not found. Using default package names as commands.${NC}"
    fi
}

check_installed_packages() {
    echo -e "${YELLOW}Checking installed packages...${NC}"
    
    PACKAGE_MAP=()
    read_dependencies
    
    printf "%-30s %-20s %-10s\n" "Package" "Command" "Status"
    printf "%-30s %-20s %-10s\n" "-------" "-------" "------"
    
    add_report ""
    
    local -A all_packages
    
    for pkg in "${!PACKAGE_MAP[@]}"; do
        all_packages["$pkg"]=1
    done
    
    for pkg in */ ; do
        pkg=${pkg%/}
        if [[ "$pkg" == "setup.sh" || "$pkg" == "README.md" || "$pkg" == "LICENSE" || "$pkg" == ".git" || "$pkg" == "dependencies.conf" ]]; then
            continue
        fi
        all_packages["$pkg"]=1
    done
    
    IFS=$'\n' sorted_packages=($(sort <<<"${!all_packages[*]}"))
    unset IFS

    for pkg in "${sorted_packages[@]}"; do
        cmd_check="${PACKAGE_MAP[$pkg]}"
        
        if [ -z "$cmd_check" ] && [ -z "${PACKAGE_MAP[$pkg]+exists}" ]; then
             cmd_check="$pkg"
        fi

        if [ -z "$cmd_check" ] && [ "${PACKAGE_MAP[$pkg]+exists}" ]; then
            printf "%-30s %-20s %-10s\n" "$pkg" "(none)" "UNKNOWN"
            add_report "UNKNOWN: $pkg (no command specified)"
            continue
        fi

        if command_exists "$cmd_check"; then
            printf "${GREEN}%-30s %-20s %-10s${NC}\n" "$pkg" "$cmd_check" "INSTALLED"
            add_report "OK: $pkg ($cmd_check installed)"
        else
            printf "${RED}%-30s %-20s %-10s${NC}\n" "$pkg" "$cmd_check" "MISSING"
            add_report "MISSING: $pkg ($cmd_check not found)"
        fi
    done
    echo ""
}

init_submodules() {
    echo -e "${YELLOW}Checking git submodules...${NC}"
    
    if [ ! -f ".gitmodules" ]; then
        echo -e "${BLUE}No submodules configured.${NC}"
        return
    fi
    
    # Check if git is available
    if ! command_exists git; then
        echo -e "${RED}Warning: git is not installed. Cannot initialize submodules.${NC}"
        add_report "WARNING: git not found, skipping submodule initialization"
        return
    fi
    
    # Check if any submodule is not initialized (starts with -)
    if git submodule status 2>/dev/null | grep -q '^-'; then
        echo -e "${BLUE}Initializing submodules...${NC}"
        if git submodule update --init --recursive; then
            echo -e "${GREEN}Submodules initialized successfully${NC}"
            add_report "INITIALIZED: Git submodules"
        else
            echo -e "${RED}Failed to initialize submodules${NC}"
            add_report "ERROR: Failed to initialize git submodules"
        fi
    else
        echo -e "${GREEN}All submodules already initialized${NC}"
    fi
    echo ""
}

resolve_path() {
    readlink -f "$1" 2>/dev/null || echo "$1"
}

DOTFILES_DIR=$(resolve_path "$DOTFILES_DIR")

install_config() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    
    echo -e "${BLUE}Processing $pkg...${NC}"
    
    local conflicts=()
    local linked=0
    local total=0
    local ready=0
    
    local conflicts=()
    local linked=0
    local total=0
    local ready=0
    
    local whitelist=(
        "."
        ".config"
        ".local"
        ".local/share"
        ".local/bin"
        ".local/state"
        ".cache"
        ".ssh"
        ".gnupg"
        "bin"
        "Library" # macOS
        "Applications" # macOS
    )
    
    while IFS= read -r dir; do
        local rel_path="${dir#$pkg_dir/}"
        if [ -z "$rel_path" ]; then continue; fi
        
        local target_path="$HOME/$rel_path"
        
        local safe=0
        for w in "${whitelist[@]}"; do
            if [ "$rel_path" == "$w" ]; then
                safe=1
                break
            fi
        done
        if [ "$safe" -eq 1 ]; then continue; fi
        
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            local real_target
            real_target=$(resolve_path "$target_path")
            local real_source
            real_source=$(resolve_path "$dir")

            if [ "$real_target" == "$real_source" ]; then
                 continue
            fi

            conflicts+=("$rel_path/ (Existing Directory - prevents clean symlink)")
        fi
    done < <(find "$pkg_dir" -type d)

    while IFS= read -r file; do
        total=$((total+1))
        local rel_path="${file#$pkg_dir/}"
        local target_path="$HOME/$rel_path"
        
        local real_target
        real_target=$(resolve_path "$target_path")
        local real_source
        real_source=$(resolve_path "$file")
        
        if [ "$real_target" == "$real_source" ]; then
             linked=$((linked+1))
        elif [ -e "$target_path" ] || [ -L "$target_path" ]; then
             conflicts+=("$rel_path")
        else
             ready=$((ready+1))
        fi
    done < <(find "$pkg_dir" -type f )

    local action=""
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        echo -e "${RED}Conflicts detected for $pkg (${#conflicts[@]} files):${NC}"
        for c in "${conflicts[@]:0:5}"; do
            echo "  - $c"
        done
        if [ ${#conflicts[@]} -gt 5 ]; then echo "  ... and others"; fi
        
        if [ -n "$GLOBAL_CONFLICT_ACTION" ]; then
             action="$GLOBAL_CONFLICT_ACTION"
             echo "Using global conflict resolution: $action"
        else
            echo -e "Choose action for $pkg:"
            echo "1) Backup existing files (rename with $BACKUP_SUFFIX) and Stow"
            echo "2) Overwrite existing files (Delete) and Stow"
            echo "3) Skip"
            echo "4) Backup ALL (Apply to all future conflicts)"
            echo "5) Overwrite ALL (Apply to all future conflicts)"
            echo "6) Skip ALL (Apply to all future conflicts)"
            read -p "Select (1-6): " choice
            
            case $choice in
                1) action="BACKUP" ;;
                2) action="OVERWRITE" ;;
                3) action="SKIP" ;;
                4) 
                   action="BACKUP"
                   GLOBAL_CONFLICT_ACTION="BACKUP"
                   ;;
                5) 
                   action="OVERWRITE"
                   GLOBAL_CONFLICT_ACTION="OVERWRITE"
                   ;;
                6) 
                   action="SKIP"
                   GLOBAL_CONFLICT_ACTION="SKIP"
                   ;;
                *) action="SKIP" ;;
            esac
        fi
    elif [ "$linked" -eq "$total" ] && [ "$total" -gt 0 ]; then
        if [ -n "$GLOBAL_RESTOW_ACTION" ]; then
             if [ "$GLOBAL_RESTOW_ACTION" == "YES_ALL" ]; then
                 action="RESTOW"
             else
                 action="SKIP"
             fi
        else
            read -p "Re-stow (refresh links) $pkg? (y/N/a/s): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                action="RESTOW"
            elif [[ "$choice" =~ ^[Aa]$ ]]; then
                action="RESTOW"
                GLOBAL_RESTOW_ACTION="YES_ALL"
            elif [[ "$choice" =~ ^[Ss]$ ]]; then
                action="SKIP"
                GLOBAL_RESTOW_ACTION="SKIP_ALL"
            else
                action="SKIP"
            fi
        fi
    else
        echo -e "${YELLOW}Ready to install (New: $ready, Linked: $linked).${NC}"
        
        if [ -n "$GLOBAL_INSTALL_ACTION" ]; then
             if [ "$GLOBAL_INSTALL_ACTION" == "YES_ALL" ]; then
                 action="INSTALL"
             else
                 action="SKIP"
             fi
        else
            read -p "Install config for $pkg? (y/N/a/s): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                action="INSTALL"
            elif [[ "$choice" =~ ^[Aa]$ ]]; then
                action="INSTALL"
                GLOBAL_INSTALL_ACTION="YES_ALL"
            elif [[ "$choice" =~ ^[Ss]$ ]]; then
                action="SKIP"
                GLOBAL_INSTALL_ACTION="SKIP_ALL"
            else
                action="SKIP"
            fi
        fi
    fi
    
    case $action in
        BACKUP)
            echo -e "${YELLOW}Backing up conflicting files...${NC}"
             while IFS= read -r file; do
                local rel_path="${file#$pkg_dir/}"
                local target_path="$HOME/$rel_path"
                local real_target
                real_target=$(resolve_path "$target_path")
                local real_source
                real_source=$(resolve_path "$file")
                
                if [ -e "$target_path" ] || [ -L "$target_path" ]; then
                    if [ "$real_target" != "$real_source" ]; then
                         echo "Backing up $target_path"
                         mv "$target_path" "$target_path$BACKUP_SUFFIX"
                         add_report "BACKED UP: $target_path"
                    fi
                fi
            done < <(find "$pkg_dir" -type f)
            
            stow -t "$HOME" -v "$pkg"
            add_report "INSTALLED: $pkg (with backups)"
            ;;
        OVERWRITE)
            echo -e "${RED}Overwriting files...${NC}"
            
            while IFS= read -r dir; do
                local rel_path="${dir#$pkg_dir/}"
                if [ -z "$rel_path" ]; then continue; fi
                
                if [[ "$rel_path" == /* ]]; then 
                    echo "Debug target safety: rel_path is absolute ($rel_path). Skipping."
                    continue 
                fi

                local target_path="$HOME/$rel_path"
                
                local real_target
                real_target=$(resolve_path "$target_path")
                if [[ "$real_target" == "$DOTFILES_DIR"* ]]; then
                     echo "SAFETY GUARD: Skipping deletion of $real_target (inside repository via symlink)"
                     continue
                fi
                
                local safe=0
                for w in "${whitelist[@]}"; do
                    if [ "$rel_path" == "$w" ]; then safe=1; break; fi
                done
                if [ "$safe" -eq 1 ]; then continue; fi
                
                if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
                     echo "Removing directory $target_path"
                     rm -rf "$target_path"
                     add_report "DELETED DIR: $target_path"
                fi
            done < <(find "$pkg_dir" -mindepth 1 -type d)

             while IFS= read -r file; do
                local rel_path="${file#$pkg_dir/}"
                 if [ -z "$rel_path" ]; then continue; fi

                if [[ "$rel_path" == /* ]]; then 
                    echo "Debug target safety: rel_path is absolute ($rel_path). Skipping."
                    continue 
                fi

                local target_path="$HOME/$rel_path"
                
                local real_target
                real_target=$(resolve_path "$target_path")
                if [[ "$real_target" == "$DOTFILES_DIR"* ]]; then
                     echo "SAFETY GUARD: Skipping deletion of $real_target (inside repository via symlink)"
                     continue
                fi

                local real_source
                real_source=$(resolve_path "$file")
                
                if [ -e "$target_path" ] || [ -L "$target_path" ]; then
                    if [ "$real_target" != "$real_source" ]; then
                         echo "Removing $target_path"
                         rm -rf "$target_path"
                         add_report "DELETED: $target_path"
                    fi
                fi
            done < <(find "$pkg_dir" -mindepth 1 -type f)
            
            stow -t "$HOME" -R -v "$pkg"
            add_report "INSTALLED: $pkg (overwrite)"
            ;;
        INSTALL)
            stow -t "$HOME" -v "$pkg"
            add_report "INSTALLED: $pkg"
            ;;
        RESTOW)
            stow -t "$HOME" -R -v "$pkg"
            add_report "RESTOWED: $pkg"
            ;;
        SKIP)
            echo "Skipping $pkg"
            add_report "SKIPPED: $pkg"
            ;;
    esac
}

restore_config() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    echo -e "${BLUE}Checking backups for $pkg...${NC}"
    
    local found_backups=0
    
    while IFS= read -r file; do
        local rel_path="${file#$pkg_dir/}"
        local target_path="$HOME/$rel_path"
        local backup_path="$target_path$BACKUP_SUFFIX"
        
        if [ -f "$backup_path" ] || [ -d "$backup_path" ]; then
            echo -e "Found backup: $backup_path"
            found_backups=1
            read -p "Restore this backup (overwrite current)? (y/N): " choice < /dev/tty
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                if [ -e "$target_path" ] || [ -L "$target_path" ]; then
                    rm -rf "$target_path"
                fi
                mv "$backup_path" "$target_path"
                echo -e "${GREEN}Restored $target_path${NC}"
                add_report "RESTORED: $target_path"
            else
                 add_report "SKIPPED RESTORE: $backup_path"
            fi
        fi
    done < <(find "$pkg_dir" -type f)
    
    if [ "$found_backups" -eq 0 ]; then
        echo "No backups found for $pkg."
    else
        read -p "Unstow $pkg packages (remove existing symlinks)? (y/N): " choice < /dev/tty
        if [[ "$choice" =~ ^[Yy]$ ]]; then
             stow -t "$HOME" -D -v "$pkg"
             add_report "UNSTOWED: $pkg"
        fi
    fi
}

add_new_config() {
    echo -e "${BLUE}=== Add New Config Package ===${NC}"
    echo ""
    
    while true; do
        read -p "Enter package name: " pkg_name
        
        if [ -z "$pkg_name" ]; then
            echo -e "${RED}Error: Package name cannot be empty${NC}"
            continue
        fi
        
        if [[ ! "$pkg_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo -e "${RED}Error: Package name can only contain letters, numbers, hyphens, and underscores${NC}"
            continue
        fi
        
        
        if [ -d "$DOTFILES_DIR/$pkg_name" ]; then
            echo -e "${YELLOW}Package '$pkg_name' already exists in the repository${NC}"
            echo ""
            echo "What would you like to do?"
            echo "1) Add to dependencies.conf and README.md only (symlink existing package)"
            echo "2) Try a different package name"
            echo "3) Cancel"
            read -p "Select (1-3): " choice
            
            case $choice in
                1)
                    read -p "Enter command to check installation (default: $pkg_name): " cmd_check
                    if [ -z "$cmd_check" ]; then
                        cmd_check="$pkg_name"
                    fi
                    
                    local deps_file="$DOTFILES_DIR/dependencies.conf"
                    local new_entry="$pkg_name:$cmd_check"
                    
                    if grep -q "^$pkg_name:" "$deps_file" 2>/dev/null; then
                        echo -e "${YELLOW}Package already exists in dependencies.conf${NC}"
                    else
                        {
                            grep -v "^#" "$deps_file" | grep -v "^$" || true
                            echo "$new_entry"
                        } | sort -u > "$deps_file.tmp"
                        
                        if grep -q "^#" "$deps_file" 2>/dev/null; then
                            grep "^#" "$deps_file" > "$deps_file.new"
                            cat "$deps_file.tmp" >> "$deps_file.new"
                        else
                            mv "$deps_file.tmp" "$deps_file.new"
                        fi
                        
                        mv "$deps_file.new" "$deps_file"
                        rm -f "$deps_file.tmp"
                        echo -e "${GREEN}✓ Updated dependencies.conf${NC}"
                    fi
                    
                    local readme_file="$DOTFILES_DIR/README.md"
                    local new_readme_entry="- **$pkg_name**"
                    
                    if [ "$cmd_check" != "$pkg_name" ]; then
                        new_readme_entry="- **$pkg_name** ($cmd_check)"
                    fi
                    
                    if grep -q "^- \*\*$pkg_name\*\*" "$readme_file" 2>/dev/null; then
                        echo -e "${YELLOW}Package already exists in README.md${NC}"
                    else
                        local pkg_check_line=$(grep -n "Package to check:" "$readme_file" | cut -d: -f1)
                        
                        if [ -n "$pkg_check_line" ]; then
                            local start_line=$((pkg_check_line + 2))
                            local end_line=$(tail -n +$start_line "$readme_file" | grep -n "^$\|^#" | head -1 | cut -d: -f1)
                            
                            if [ -n "$end_line" ]; then
                                end_line=$((start_line + end_line - 2))
                            else
                                end_line=$(wc -l < "$readme_file")
                            fi
                            
                            {
                                sed -n "${start_line},${end_line}p" "$readme_file"
                                echo "$new_readme_entry"
                            } | sort -u > "$readme_file.tmp"
                            
                            {
                                head -n $((start_line - 1)) "$readme_file"
                                cat "$readme_file.tmp"
                                tail -n +$((end_line + 1)) "$readme_file"
                            } > "$readme_file.new"
                            
                            mv "$readme_file.new" "$readme_file"
                            rm -f "$readme_file.tmp"
                            
                            echo -e "${GREEN}✓ Updated README.md${NC}"
                        fi
                    fi
                    
                    echo ""
                    echo -e "${GREEN}Package '$pkg_name' registered successfully!${NC}"
                    add_report "REGISTERED EXISTING PACKAGE: $pkg_name (command: $cmd_check)"
                    return
                    ;;
                2)
                    continue
                    ;;
                3)
                    return
                    ;;
                *)
                    echo -e "${RED}Invalid choice${NC}"
                    return
                    ;;
            esac
        fi
        
        break
    done
    
    read -p "Enter command to check installation (default: $pkg_name): " cmd_check
    if [ -z "$cmd_check" ]; then
        cmd_check="$pkg_name"
    fi
    
    while true; do
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  .config/yazi       → Creates: $pkg_name/.config/yazi/"
        echo "  .bashrc            → Creates: $pkg_name/.bashrc"
        echo "  .config/tmux/tmux.conf → Creates: $pkg_name/.config/tmux/tmux.conf"
        echo ""
        read -p "Enter path relative to \$HOME: " rel_path
        
        if [ -z "$rel_path" ]; then
            echo -e "${RED}Error: Path cannot be empty${NC}"
            continue
        fi
        
        if [[ "$rel_path" =~ ^[/~] ]]; then
            echo -e "${RED}Error: Path should be relative (don't start with / or ~)${NC}"
            continue
        fi
        
        local home_path="$HOME/$rel_path"
        if [ -e "$home_path" ] || [ -L "$home_path" ]; then
            echo ""
            echo -e "${YELLOW}File/directory already exists: $home_path${NC}"
            echo ""
            echo "What would you like to do?"
            echo "1) Import existing file/directory to repository"
            echo "2) Try a different path"
            echo "3) Cancel"
            read -p "Select (1-3): " choice
            
            case $choice in
                1)
                    echo -e "${BLUE}Importing existing file/directory...${NC}"
                    
                    local pkg_path="$DOTFILES_DIR/$pkg_name/$rel_path"
                    local parent_dir=$(dirname "$pkg_path")
                    mkdir -p "$parent_dir"
                    
                    if [ -d "$home_path" ] && [ ! -L "$home_path" ]; then
                        cp -r "$home_path" "$parent_dir/"
                        echo -e "${GREEN}✓ Imported directory: $rel_path${NC}"
                    else
                        cp "$home_path" "$pkg_path"
                        echo -e "${GREEN}✓ Imported file: $rel_path${NC}"
                    fi
                    
                    local deps_file="$DOTFILES_DIR/dependencies.conf"
                    local new_entry="$pkg_name:$cmd_check"
                    
                    {
                        grep -v "^#" "$deps_file" | grep -v "^$" || true
                        echo "$new_entry"
                    } | sort -u > "$deps_file.tmp"
                    
                    if grep -q "^#" "$deps_file" 2>/dev/null; then
                        grep "^#" "$deps_file" > "$deps_file.new"
                        cat "$deps_file.tmp" >> "$deps_file.new"
                    else
                        mv "$deps_file.tmp" "$deps_file.new"
                    fi
                    
                    mv "$deps_file.new" "$deps_file"
                    rm -f "$deps_file.tmp"
                    
                    echo -e "${GREEN}✓ Updated dependencies.conf${NC}"
                    
                    local readme_file="$DOTFILES_DIR/README.md"
                    local new_readme_entry="- **$pkg_name**"
                    
                    if [ "$cmd_check" != "$pkg_name" ]; then
                        new_readme_entry="- **$cmd_check** ($pkg_name)"
                    fi
                    
                    local pkg_check_line=$(grep -n "Package to check:" "$readme_file" | cut -d: -f1)
                    
                    if [ -n "$pkg_check_line" ]; then
                        local start_line=$((pkg_check_line + 2))
                        local end_line=$(tail -n +$start_line "$readme_file" | grep -n "^$\|^#" | head -1 | cut -d: -f1)
                        
                        if [ -n "$end_line" ]; then
                            end_line=$((start_line + end_line - 2))
                        else
                            end_line=$(wc -l < "$readme_file")
                        fi
                        
                        {
                            sed -n "${start_line},${end_line}p" "$readme_file"
                            echo "$new_readme_entry"
                        } | sort -u > "$readme_file.tmp"
                        
                        {
                            head -n $((start_line - 1)) "$readme_file"
                            cat "$readme_file.tmp"
                            tail -n +$((end_line + 1)) "$readme_file"
                        } > "$readme_file.new"
                        
                        mv "$readme_file.new" "$readme_file"
                        rm -f "$readme_file.tmp"
                        
                        echo -e "${GREEN}✓ Updated README.md${NC}"
                    fi
                    
                    echo ""
                    echo -e "${GREEN}Package '$pkg_name' imported successfully!${NC}"
                    echo ""
                    echo -e "${BLUE}Next steps:${NC}"
                    echo "1. Review imported files at: $DOTFILES_DIR/$pkg_name/"
                    echo "2. Run './setup.sh' and select 'Install/Update Configs' to create symlinks"
                    echo "   (The original file will be backed up)"
                    echo ""
                    
                    add_report "IMPORTED PACKAGE: $pkg_name (command: $cmd_check, path: $rel_path)"
                    return
                    ;;
                2)
                    continue
                    ;;
                3)
                    return
                    ;;
                *)
                    echo -e "${RED}Invalid choice${NC}"
                    return
                    ;;
            esac
        fi
        
        break
    done
    
    local pkg_path="$DOTFILES_DIR/$pkg_name/$rel_path"
    local is_file=0
    
    if [[ "$rel_path" =~ \.[a-zA-Z0-9]+$ ]] || [[ ! "$rel_path" =~ /$ ]]; then
        if [[ "$rel_path" =~ \. ]] || [[ "$rel_path" =~ rc$ ]] || [[ "$rel_path" =~ conf$ ]]; then
            is_file=1
        fi
    fi
    
    echo ""
    echo -e "${YELLOW}Creating package structure:${NC}"
    echo "  $pkg_name/$rel_path"
    echo ""
    
    if [ "$is_file" -eq 1 ]; then
        local parent_dir=$(dirname "$pkg_path")
        mkdir -p "$parent_dir"
        
        cat > "$pkg_path" << EOF
# Configuration file for $pkg_name
# Add your configuration here

EOF
        echo -e "${GREEN}✓ Created directory: $pkg_name/$(dirname "$rel_path")/${NC}"
        echo -e "${GREEN}✓ Created placeholder file: $pkg_name/$rel_path${NC}"
    else
        mkdir -p "$pkg_path"
        echo -e "${GREEN}✓ Created directory: $pkg_name/$rel_path${NC}"
    fi
    
    local deps_file="$DOTFILES_DIR/dependencies.conf"
    local new_entry="$pkg_name:$cmd_check"
    
    {
        grep -v "^#" "$deps_file" | grep -v "^$" || true
        echo "$new_entry"
    } | sort -u > "$deps_file.tmp"
    
    if grep -q "^#" "$deps_file" 2>/dev/null; then
        grep "^#" "$deps_file" > "$deps_file.new"
        cat "$deps_file.tmp" >> "$deps_file.new"
    else
        mv "$deps_file.tmp" "$deps_file.new"
    fi
    
    mv "$deps_file.new" "$deps_file"
    rm -f "$deps_file.tmp"
    
    echo -e "${GREEN}✓ Updated dependencies.conf${NC}"
    
    local readme_file="$DOTFILES_DIR/README.md"
    local new_readme_entry="- **$pkg_name**"
    
    if [ "$cmd_check" != "$pkg_name" ]; then
        new_readme_entry="- **$pkg_name** ($cmd_check)"
    fi
    
    local pkg_check_line=$(grep -n "Package to check:" "$readme_file" | cut -d: -f1)
    
    if [ -n "$pkg_check_line" ]; then
        local start_line=$((pkg_check_line + 2))
        
        local end_line=$(tail -n +$start_line "$readme_file" | grep -n "^$\|^#" | head -1 | cut -d: -f1)
        
        if [ -n "$end_line" ]; then
            end_line=$((start_line + end_line - 2))
        else
            end_line=$(wc -l < "$readme_file")
        fi
        
        {
            sed -n "${start_line},${end_line}p" "$readme_file"
            echo "$new_readme_entry"
        } | sort -u > "$readme_file.tmp"
        
        {
            head -n $((start_line - 1)) "$readme_file"
            cat "$readme_file.tmp"
            tail -n +$((end_line + 1)) "$readme_file"
        } > "$readme_file.new"
        
        mv "$readme_file.new" "$readme_file"
        rm -f "$readme_file.tmp"
        
        echo -e "${GREEN}✓ Updated README.md${NC}"
    else
        echo -e "${YELLOW}⚠ Could not find 'Package to check:' section in README.md${NC}"
        echo -e "${YELLOW}  Please manually add: $new_readme_entry${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Package '$pkg_name' added successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    
    if [ "$is_file" -eq 1 ]; then
        echo "1. Edit your config file at: $pkg_path"
    else
        echo "1. Add your config files to: $pkg_path"
    fi
    
    echo "2. Run './setup.sh' and select 'Install/Update Configs' to deploy"
    echo ""
    
    add_report "ADDED NEW PACKAGE: $pkg_name (command: $cmd_check, path: $rel_path)"
}

main_menu() {
    print_header
    
    if ! command_exists stow; then
        echo -e "${RED}Error: GNU Stow is not installed. Please install it first.${NC}"
        exit 1
    fi

    echo "1) Install/Update Configs"
    echo "2) Restore Configs (Restore Backups)"
    echo "3) Add New Config"
    echo "4) Exit"
    read -p "Select option: " opt
    
    case $opt in
        1)
            init_submodules
            check_installed_packages
            echo "Starting installation process..."
             for pkg in */ ; do
                pkg=${pkg%/}
                if [[ "$pkg" == "setup.sh" || "$pkg" == "README.md" || "$pkg" == "LICENSE" || "$pkg" == ".git" ]]; then
                    continue
                fi
                
                install_config "$pkg"
                echo "-----------------------------------"
            done
            ;;
        2)
            echo "Starting restore process..."
             for pkg in */ ; do
                pkg=${pkg%/}
                if [[ "$pkg" == "setup.sh" || "$pkg" == "README.md" || "$pkg" == "LICENSE" || "$pkg" == ".git" ]]; then
                    continue
                fi
                
                read -p "Check restore for $pkg? (y/N): " choice
                if [[ "$choice" =~ ^[Yy]$ ]]; then
                    restore_config "$pkg"
                fi
                echo "-----------------------------------"
            done
            ;;
        3)
            add_new_config
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid option"
            main_menu
            ;;
    esac
    
    echo ""
    echo "================ REPORT ================"
    for item in "${REPORT[@]}"; do
        echo "$item"
    done
    echo "========================================"
    
    read -p "Save report to file? (y/N): " save
    if [[ "$save" =~ ^[Yy]$ ]]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        file="dotfiles_report_$timestamp.txt"
        printf "%s\n" "${REPORT[@]}" > "$file"
        echo "Report saved to $file"
    fi
}

main_menu
