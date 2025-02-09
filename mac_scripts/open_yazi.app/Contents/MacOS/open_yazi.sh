#!/bin/bash

# Open Ghostty and ensure it runs with your full zsh configuration
open -na "Ghostty" --args -e "zsh -c 'source ~/.zshrc; y; exec zsh'"
