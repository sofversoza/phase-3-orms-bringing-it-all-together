
class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    # drops the table from the db 
    def self.drop_table
        sql = <<-SQL
           DROP TABLE IF EXISTS dogs
        SQL
  
        DB[:conn].execute(sql)
    end

    # creates the table
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT 
            )
        SQL
        DB[:conn].execute(sql)
    end

    # saves an instance to the DB
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)   # inserts the song to the DB
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]   # get the id & set it to the instance's id
        self    # then return the Ruby instance
    end

    # creates new instance & saves it to the DB using #save method ^
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    # converts the array we get from DB into a Ruby instance
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    # return all the converted array data from DB
    def self.all
        sql = <<-SQL
            SELECT *
            FROM dogs
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)     # were calling new_from_db method bc it converted DB's array into Ruby object
        end    
    end

    # works like .all ^ but this will find an instance by its name
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)      # were calling new_from_db method bc it converted DB's array into Ruby object
        end.first    
    end

    # works like .find_by_name & .all but this will find an instance by its id
    def self.find(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)      # were calling new_from_db method bc it converted DB's array into Ruby object
        end.first    
    end

    # ----------------- BONUS ------------------- #
    
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            LIMIT 1
        SQL
        row = DB[:conn].execute(sql, name, breed).first
        
        if row
            self.new_from_db(row)       # were calling new_from_db method bc it converted DB's array into Ruby object
        else
            self.create(name: name, breed: breed)    
        end    
    end

    
    def update
        sql = <<-SQL
            UPDATE dogs
            SET
                name = ?,
                breed = ?
            WHERE id = ?;    
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
