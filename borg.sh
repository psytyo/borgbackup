#!/bin/sh

# Set variables
REPO="$1"
PASSPHRASE="$2"
BACKUP_NAME="$3"
BACKUP_DIRS="$4"

# Check for missing arguments
if [ -z "$REPO" ] || [ -z "$PASSPHRASE" ] || [ -z "$BACKUP_NAME" ] || [ -z "$BACKUP_DIRS" ]; then
    echo "Usage: $0 REPO PASSPHRASE BACKUP_NAME BACKUP_DIRS"
    exit 1
fi

# Set repository and passphrase
export BORG_REPO="$REPO"
export BORG_PASSPHRASE="$PASSPHRASE"

# Define info function
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }

# Trap for backup interruption
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Create backup
borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    ::'{hostname}-'$BACKUP_NAME'-{now}'            \
    $BACKUP_DIRS

backup_exit=$?

info "Pruning repository"

# Prune repository
borg prune                          \
    --list                          \
    --glob-archives '{hostname}-*'  \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6

prune_exit=$?

# Compact repository
info "Compacting repository"
borg compact

compact_exit=$?

# Set global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

# Handle exit code
if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}