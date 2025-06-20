
# Bash Alias Generator (`generate_alias.sh`)

A powerful and user-friendly bash script to interactively generate, manage, and list shell aliases, with a special focus on creating aliases that act like functions with arguments. This script is a part of a larger collection of utility scripts in the [toolbox](https://github.com/shahinabdi/toolbox) repository.

This tool simplifies the process of creating complex aliases, making your command-line experience more efficient and personalized.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Project Structure

```
toolbox/scripts/generate_alias/
├── generate_alias.sh         # The main script for creating and managing aliases
└── README.md                 # Documentation for the toolbox and its components
```
## Prerequisites

- Bash 4.0 or higher
- A Unix-like system (Linux, macOS, WSL)
- A writable `.bashrc` or `.bash_profile` file in your home directory

Optional but recommended:
- `tput` or similar utility for colored output
- `grep`, `sed`, `awk` (common Unix text tools)

## Installation

1. Clone the toolbox repository:

```bash
git clone https://github.com/shahinabdi/toolbox.git
cd toolbox/scripts/generate_alias
```

2. Make the script executable:

```bash
chmod +x generate_alias.sh
```

3. (Optional) Add it to your `PATH` for global use:

```bash
export PATH="$PATH:/path/to/toolbox"
```

## Usage

### 1. Interactive Mode (Create a New Alias)

```bash
./generate_alias.sh
```

The script will prompt you step-by-step to:
- Enter an alias name
- Define the command (with optional arguments like `$1`)
- Confirm and test the command
- Save it to `.bashrc` with backup and reload

### 2. List Existing Aliases

```bash
./generate_alias.sh --list
```

Displays aliases from:
- The current shell session
- The `.bashrc` file (categorized)

### 3. Show Usage Examples

```bash
./generate_alias.sh --examples
```

Provides sample aliases including those with arguments and pipes.

### 4. Show Help

```bash
./generate_alias.sh --help
```

Displays all available options and usage tips.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Open a pull request with a clear description

Please ensure code is well-documented and adheres to the modularity of the `toolbox`.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

Created and maintained by **[Shahin Abdi](https://github.com/shahinabdi)**.  
For suggestions, issues, or improvements, feel free to [open an issue](https://github.com/shahinabdi/toolbox/issues).
