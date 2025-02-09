#!/bin/bash

# Open Ghostty and ensure it runs with full zsh configuration
open -na "Ghostty" --args -e "zsh -c 'source ~/.zshrc; y; exec zsh'"
