#!/bin/bash
backup() { 
    echo "backup account" 
}
package() {

for i in "$@"
do
    case $i in
        -b|--backup)
            backup
            ;;
        -p|--package)
            echo "Packaging account"
            ;;
        -r|--restore)
            echo "Restoring account"
            ;;
        -k|--kill)
            echo "Killing account"
            ;;
        -a|--all)
            echo "Creating backup"
            echo "Packaging account"
            echo "Killing account"
            echo "Restoring account"
            ;;
        -h|--help)
            echo "Help"
            ;;
        *)
            echo "invalid"
            ;;
    esac
done
