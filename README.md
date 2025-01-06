# Add Python to PATH

A simple batch script to add Python installation directories to the PATH environment variable for Windows users.

## Problem

When running Python commands in Command Prompt, you might encounter the following error:

![Error Screenshot](https://github.com/user-attachments/assets/40b82bb6-9fdd-4d3c-914d-f5a471eb2fed)

This happens when Python's executable is not added to your system's PATH environment variable.

## Solution

This script automates the process of appending Python's installation and `Scripts` directories to the PATH environment variable.

## Features

- Works for Python installations located in `C:\Users\<username>\AppData\Local\Programs\Python\Python<version>`.
- Adds both the Python installation directory and `Scripts` directory to PATH.
- Makes changes to the current user's PATH without affecting other users.

## Usage

1. Download the `AddPythonToPath.bat` file from this repository.
2. Open the file in a text editor to confirm or adjust the Python directory paths if needed.
3. Run the script by double-clicking or via Command Prompt:
   ```cmd
   AddPythonToPath.bat
   ```
4. Close and reopen Command Prompt to apply the changes.

## Verify Installation

After running the script, verify that Python is accessible by typing:

```cmd
python --version
```

## License

This script is released under the MIT License. See [LICENSE](LICENSE) for details.
