#!/bin/bash
#
# Apply SQL migrations to Moonraker's database with detailed output

MIGRATION_DIR="/opt/config/mod/sql"
DATABASE_PATH="/opt/config/mod_data/database/moonraker-sql.db"
LAST_MIGRATION_FILE="/opt/config/mod/sql/version"


get_last_migration() {
    if [ -f "$LAST_MIGRATION_FILE" ]; then
        cat "$LAST_MIGRATION_FILE"
    else
        echo "00000"
    fi
}

apply_migrations() {
    echo "Fetching last migration version..."
    last_migration=$(get_last_migration)
    migrations=($(ls $MIGRATION_DIR/*.sql | sort))
    
    echo "Current database version: ${last_migration}"
    echo "Total migrations found: ${#migrations[@]}"
    
    migration_applied=0
    for migration in "${migrations[@]}"; do
        migration_file=$(basename "$migration")
        migration_name="${migration_file%%.*}"  # Remove .sql extension
        migration_number="${migration_name%%-*}"  # Get the migration number
        
        if [[ "$migration_number" > "$last_migration" ]]; then
            echo "Applying migration: $migration_file"
            
            if sqlite3 "$DATABASE_PATH" < "$migration"; then
                echo "$migration_number" > "$LAST_MIGRATION_FILE"
                migration_applied=1
            else
                echo "Failed to apply migration: $migration_file. Check the SQL script or database file."
                exit 2
            fi
        fi
    done

    if [ "$migration_applied" -eq 0 ]; then
        echo "Database already up to date"
        exit 1
    fi

    echo "All migrations have been processed."
}

apply_migrations
