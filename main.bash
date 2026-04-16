#!/bin/bash

BASE_DIR="lab_users"
ARCHIVE_DIR="archives"

mkdir -p "$BASE_DIR"
mkdir -p "$ARCHIVE_DIR"

while true; do
    echo "=============================="
    echo " User Workspace Manager"
    echo "=============================="
    echo "1. Create new user workspace"
    echo "2. Set disk quota (simulated)"
    echo "3. Search file by name/extension"
    echo "4. Archive inactive workspaces"
    echo "5. Exit"
    echo "=============================="

    read -p "Enter choice: " choice

    case $choice in

    1)
        read -p "Enter username: " user
        user_dir="$BASE_DIR/$user"

        mkdir -p "$user_dir"/{docs,code,shared}

        # only owner access (user + admin concept)
        chmod 700 "$user_dir"

        echo "Workspace created: $user_dir"
        ;;

    2)
        read -p "Enter username: " user
        user_dir="$BASE_DIR/$user"

        if [ -d "$user_dir" ]; then
            size=$(du -sm "$user_dir" 2>/dev/null | cut -f1)

            echo "Current usage: ${size}MB"

            if [ "$size" -gt 100 ]; then
                echo "⚠ WARNING: Workspace exceeds 100MB (simulated quota)"
            else
                echo "Usage is within limit"
            fi
        else
            echo "User not found"
        fi
        ;;

    3)
        read -p "Enter filename or extension: " pattern

        echo "Searching in all workspaces..."

        find "$BASE_DIR" -type f -name "*$pattern*" -exec ls -lh {} \; 2>/dev/null
        ;;

    4)
        echo "Archiving inactive workspaces (60+ days simulated)..."

        for user_dir in "$BASE_DIR"/*; do
            if [ -d "$user_dir" ]; then

                # real check (optional logic improvement)
                inactive=$(find "$user_dir" -type f -mtime +60 | wc -l)

                if [ "$inactive" -ge 0 ]; then
                    user=$(basename "$user_dir")
                    archive_file="$ARCHIVE_DIR/${user}_archive.tar.gz"

                    tar -czf "$archive_file" -C "$BASE_DIR" "$user"

                    echo "Archived: $user"

                    read -p "Delete original? (y/n): " del
                    if [ "$del" == "y" ]; then
                        rm -rf "$user_dir"
                        echo "Deleted $user_dir"
                    fi
                fi
            fi
        done
        ;;

    5)
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo "Invalid option"
        ;;
    esac

    echo ""
done