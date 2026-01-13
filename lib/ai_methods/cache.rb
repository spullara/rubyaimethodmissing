require 'fileutils'

module AIMethods
  class Cache
    # Initialize cache with database path
    # @param db_path [String, nil] Path to SQLite database. If nil, uses ~/.ai_methods/cache.db
    def initialize(db_path = nil)
      @db_path = expand_path(db_path || '~/.ai_methods/cache.db')
      ensure_db_directory

      # Try to use SQLite3 if available, otherwise use in-memory cache
      begin
        require 'sqlite3'
        @db = SQLite3::Database.new(@db_path)
        @db.results_as_hash = true
        create_table
        @use_sqlite = true
      rescue LoadError
        # Fallback to in-memory cache
        @cache = {}
        @use_sqlite = false
      end
    end

    # Find a cached method by class name and method name
    # @param class_name [String] Name of the class
    # @param method_name [String] Name of the method
    # @return [String, nil] Generated code or nil if not found
    def find(class_name, method_name)
      if @use_sqlite
        query = <<~SQL
          SELECT generated_code FROM generated_methods
          WHERE class_name = ? AND method_name = ?
          LIMIT 1
        SQL

        result = @db.execute(query, [class_name, method_name])
        result.empty? ? nil : result[0]['generated_code']
      else
        key = "#{class_name}:#{method_name}"
        @cache[key]
      end
    end

    # Find all methods for a given class
    # @param class_name [String] Name of the class
    # @return [Array<Hash>] Array of {method_name:, generated_code:} hashes
    def find_all_for_class(class_name)
      if @use_sqlite
        query = <<~SQL
          SELECT method_name, generated_code FROM generated_methods
          WHERE class_name = ?
          ORDER BY created_at ASC
        SQL

        results = @db.execute(query, [class_name])
        results.map { |row| { method_name: row['method_name'], generated_code: row['generated_code'] } }
      else
        @cache.select { |k, _| k.start_with?("#{class_name}:") }
               .map { |k, v| { method_name: k.split(':')[1], generated_code: v } }
      end
    end

    # Store a generated method in the cache
    # @param class_name [String] Name of the class
    # @param method_name [String] Name of the method
    # @param signature [String] Method signature
    # @param code [String] Generated code
    def store(class_name, method_name, signature, code)
      if @use_sqlite
        query = <<~SQL
          INSERT OR REPLACE INTO generated_methods
          (class_name, method_name, method_signature, generated_code, created_at)
          VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
        SQL

        @db.execute(query, [class_name, method_name, signature, code])
      else
        key = "#{class_name}:#{method_name}"
        @cache[key] = code
      end
    end

    # Update last_used_at and increment call_count for a method
    # @param class_name [String] Name of the class
    # @param method_name [String] Name of the method
    def touch(class_name, method_name)
      if @use_sqlite
        query = <<~SQL
          UPDATE generated_methods
          SET last_used_at = CURRENT_TIMESTAMP, call_count = call_count + 1
          WHERE class_name = ? AND method_name = ?
        SQL

        @db.execute(query, [class_name, method_name])
      end
      # In-memory cache doesn't track usage stats
    end

    # Close the database connection
    def close
      @db.close if @use_sqlite && @db
    end

    private

    # Expand ~ to home directory
    # @param path [String] Path that may contain ~
    # @return [String] Expanded path
    def expand_path(path)
      path.start_with?('~') ? File.expand_path(path) : path
    end

    # Ensure the database directory exists
    def ensure_db_directory
      dir = File.dirname(@db_path)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end

    # Create the generated_methods table if it doesn't exist
    def create_table
      @db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS generated_methods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          class_name TEXT NOT NULL,
          method_name TEXT NOT NULL,
          method_signature TEXT,
          generated_code TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          last_used_at DATETIME,
          call_count INTEGER DEFAULT 0,
          UNIQUE(class_name, method_name, method_signature)
        )
      SQL

      @db.execute(<<~SQL)
        CREATE INDEX IF NOT EXISTS idx_class_name ON generated_methods(class_name)
      SQL
    end
  end
end

