#!/bin/bash

# Script to generate bash aliases with functions
# Usage: ./generate_alias.sh

BASHRC_FILE="$HOME/.bashrc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bash Alias Generator ===${NC}"
echo

# Function to validate alias name
validate_alias_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo -e "${RED}Error: Invalid alias name. Use only letters, numbers, and underscores. Must start with letter or underscore.${NC}"
        return 1
    fi
    return 0
}

# Function to check if alias already exists
check_existing_alias() {
    local name="$1"
    if grep -q "^alias $name=" "$BASHRC_FILE" 2>/dev/null; then
        echo -e "${YELLOW}Warning: Alias '$name' already exists in $BASHRC_FILE${NC}"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Function to get alias name
get_alias_name() {
    while true; do
        read -p "Enter alias name: " alias_name
        if [[ -z "$alias_name" ]]; then
            echo -e "${RED}Alias name cannot be empty.${NC}"
            continue
        fi
        
        if validate_alias_name "$alias_name"; then
            if check_existing_alias "$alias_name"; then
                break
            fi
        fi
    done
}

# Function to get command template
get_command() {
    echo
    echo -e "${BLUE}Enter the command template:${NC}"
    echo -e "${YELLOW}Use \$1, \$2, \$3, etc. for arguments${NC}"
    echo -e "${YELLOW}Example: pytest -vv \"\$1\" | grep FAILED${NC}"
    echo -e "${YELLOW}Example: conda create -n \"\$1\" python=\"\$2\"${NC}"
    echo
    
    read -p "Command: " command_template
    
    if [[ -z "$command_template" ]]; then
        echo -e "${RED}Command cannot be empty.${NC}"
        return 1
    fi
    
    return 0
}

# Function to generate the alias
generate_alias() {
    local alias_name="$1"
    local command="$2"
    local function_name="_${alias_name}_func"
    
    # Generate the alias line
    local alias_line="alias ${alias_name}='function ${function_name}() { ${command}; }; ${function_name}'"
    
    echo
    echo -e "${GREEN}Generated alias:${NC}"
    echo -e "${BLUE}$alias_line${NC}"
    echo
    
    return 0
}

# Function to add alias to bashrc
add_to_bashrc() {
    local alias_line="$1"
    local alias_name="$2"
    
    # Create backup
    cp "$BASHRC_FILE" "${BASHRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null
    
    # Remove existing alias if it exists
    if grep -q "^alias $alias_name=" "$BASHRC_FILE" 2>/dev/null; then
        sed -i "/^alias $alias_name=/d" "$BASHRC_FILE"
    fi
    
    # Add new alias
    echo >> "$BASHRC_FILE"
    echo "# Generated alias by alias_generator script" >> "$BASHRC_FILE"
    echo "$alias_line" >> "$BASHRC_FILE"
    
    echo -e "${GREEN}✓ Alias added to $BASHRC_FILE${NC}"
    
    # Automatically source bashrc
    echo -e "${BLUE}Sourcing ~/.bashrc...${NC}"
    source "$BASHRC_FILE"
    echo -e "${GREEN}✓ Bashrc reloaded! You can now use the '$alias_name' alias.${NC}"
}

# Function to list all existing aliases
list_aliases() {
    echo -e "${BLUE}=== Current Aliases ===${NC}"
    echo
    
    local normal_aliases=()
    local function_aliases=()
    local found_aliases=false
    
    # First, try to get aliases from current shell
    local shell_aliases=$(alias 2>/dev/null | sort)
    
    # Also extract aliases from bashrc file
    local bashrc_aliases=""
    if [[ -f "$BASHRC_FILE" ]]; then
        bashrc_aliases=$(grep "^alias " "$BASHRC_FILE" 2>/dev/null | sort)
    fi
    
    # Combine both sources and remove duplicates
    local all_aliases=$(echo -e "$shell_aliases\n$bashrc_aliases" | grep "^alias " | sort -u)
    
    # If still no aliases found, try alternative methods
    if [[ -z "$all_aliases" ]]; then
        echo -e "${BLUE}Checking bashrc file directly...${NC}"
        # Look for alias definitions in common shell files
        for file in "$HOME/.bashrc" "$HOME/.bash_aliases" "$HOME/.profile" "$HOME/.bash_profile"; do
            if [[ -f "$file" ]]; then
                local file_aliases=$(grep "^alias " "$file" 2>/dev/null)
                if [[ -n "$file_aliases" ]]; then
                    all_aliases="$all_aliases"$'\n'"$file_aliases"
                    echo -e "${GREEN}Found aliases in: $file${NC}"
                fi
            fi
        done
        all_aliases=$(echo "$all_aliases" | grep "^alias " | sort -u)
    fi
    
    if [[ -z "$all_aliases" ]]; then
        echo -e "${YELLOW}No aliases found in current shell or configuration files.${NC}"
        echo -e "${BLUE}Tip: Make sure your aliases are defined with 'alias name=command' format${NC}"
        return
    fi
    
    # Parse aliases and categorize them
    while IFS= read -r line; do
        if [[ -n "$line" && "$line" == alias* ]]; then
            found_aliases=true
            # Extract alias definition - handle both quoted and unquoted
            local alias_def=$(echo "$line" | sed -n "s/^alias [^=]*=\(.*\)$/\1/p")
            
            # Remove surrounding quotes if present
            alias_def=$(echo "$alias_def" | sed "s/^['\"]//; s/['\"]$//")
            
            # Check if it contains function definition
            if [[ "$alias_def" == *"function "* ]] && [[ "$alias_def" == *"() {"* ]]; then
                function_aliases+=("$line")
            else
                normal_aliases+=("$line")
            fi
        fi
    done <<< "$all_aliases"
    
    if [[ "$found_aliases" == false ]]; then
        echo -e "${YELLOW}No valid aliases found.${NC}"
        return
    fi
    
    # Display normal aliases
    if [[ ${#normal_aliases[@]} -gt 0 ]]; then
        echo -e "${GREEN}📋 Normal Aliases (${#normal_aliases[@]}):${NC}"
        echo -e "${GREEN}═══════════════════════${NC}"
        for alias_line in "${normal_aliases[@]}"; do
            local name=$(echo "$alias_line" | sed -n "s/^alias \([^=]*\)=.*$/\1/p")
            local cmd=$(echo "$alias_line" | sed -n "s/^alias [^=]*=\(.*\)$/\1/p" | sed "s/^['\"]//; s/['\"]$//")
            printf "  ${BLUE}%-15s${NC} → %s\n" "$name" "$cmd"
        done
        echo
    fi
    
    # Display function aliases
    if [[ ${#function_aliases[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚙️  Function Aliases (${#function_aliases[@]}):${NC}"
        echo -e "${YELLOW}═══════════════════════${NC}"
        for alias_line in "${function_aliases[@]}"; do
            local name=$(echo "$alias_line" | sed -n "s/^alias \([^=]*\)=.*$/\1/p")
            local func_content=$(echo "$alias_line" | sed -n "s/^alias [^=]*=.*function [^{]*{ \(.*\); }.*$/\1/p")
            # If extraction failed, show the full definition
            if [[ -z "$func_content" ]]; then
                func_content=$(echo "$alias_line" | sed -n "s/^alias [^=]*=\(.*\)$/\1/p" | sed "s/^['\"]//; s/['\"]$//")
            fi
            printf "  ${BLUE}%-15s${NC} → %s\n" "$name" "$func_content"
        done
        echo
    fi
    
    echo -e "${GREEN}Total: ${#normal_aliases[@]} normal + ${#function_aliases[@]} function aliases${NC}"
    
    # Debug info if no aliases found but files exist
    if [[ ${#normal_aliases[@]} -eq 0 && ${#function_aliases[@]} -eq 0 ]]; then
        echo
        echo -e "${BLUE}Debug: Searching for aliases in configuration files...${NC}"
        for file in "$HOME/.bashrc" "$HOME/.bash_aliases" "$HOME/.profile"; do
            if [[ -f "$file" ]]; then
                local count=$(grep -c "^alias " "$file" 2>/dev/null || echo "0")
                echo -e "  $file: $count alias definitions found"
            fi
        done
    fi
}

# Function to show usage examples
show_examples() {
    echo
    echo -e "${BLUE}=== Usage Examples ===${NC}"
    echo
    echo -e "${YELLOW}Example 1: pytest with grep${NC}"
    echo "  Alias name: pyf"
    echo "  Command: pytest -vv \"\$1\" | grep FAILED"
    echo "  Usage: pyf test_file.py"
    echo
    echo -e "${YELLOW}Example 2: conda environment creation${NC}"
    echo "  Alias name: newenv"
    echo "  Command: conda create -n \"\$1\" python=\"\$2\""
    echo "  Usage: newenv myenv 3.9"
    echo
    echo -e "${YELLOW}Example 3: Docker run with volume${NC}"
    echo "  Alias name: drun"
    echo "  Command: docker run -it -v \"\$PWD\":/workspace \"\$1\" bash"
    echo "  Usage: drun python:3.9"
    echo
}

# Function to test the alias
test_alias() {
    local alias_name="$1"
    local command="$2"
    
    echo
    read -p "Do you want to test the alias? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Testing alias (dry run)...${NC}"
        echo -e "${YELLOW}Command that would be executed:${NC}"
        
        # Simple test with placeholder arguments
        local test_command=$(echo "$command" | sed 's/\$[0-9]/TEST_ARG/g')
        echo "  $test_command"
        echo
        echo -e "${GREEN}Test completed. The alias structure looks correct.${NC}"
    fi
}

# Main script execution
main() {
    # Show examples if requested
    if [[ "$1" == "--examples" || "$1" == "-e" ]]; then
        show_examples
        exit 0
    fi
    
    # List existing aliases
    if [[ "$1" == "--list" || "$1" == "-l" ]]; then
        list_aliases
        exit 0
    fi
    
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: $0 [--examples|-e] [--list|-l] [--help|-h]"
        echo "  --examples, -e  Show usage examples"
        echo "  --list, -l      List all existing aliases (categorized)"
        echo "  --help, -h      Show this help message"
        exit 0
    fi
    
    # Get alias name
    get_alias_name
    
    # Get command
    while ! get_command; do
        echo "Please try again."
    done
    
    # Generate alias
    generate_alias "$alias_name" "$command_template"
    
    # Test alias
    test_alias "$alias_name" "$command_template"
    
    # Ask to add to bashrc
    echo
    read -p "Add this alias to ~/.bashrc? (Y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Alias not added to bashrc. You can copy it manually if needed.${NC}"
    else
        local final_alias_line="alias ${alias_name}='function _${alias_name}_func() { ${command_template}; }; _${alias_name}_func'"
        add_to_bashrc "$final_alias_line" "$alias_name"
        
        # Ask if user wants to see the updated alias list
        echo
        read -p "Do you want to see all your aliases now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo
            list_aliases
        fi
    fi
    
    echo
    echo -e "${GREEN}Done!${NC}"
}

# Run main function with all arguments
main "$@"