class Dog 
  
  attr_accessor :name, :breed, :id
  
  def initialize(attributes)
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
 
    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs") [0][0]
    self
  end
  
  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    attributes = {}
    attributes[:id] = row [0]
    attributes[:name] =  row[1]
    attributes[:breed] = row[2]
    new_dog = self.new(attributes) 
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(attributes)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !row.empty?
      attributes[:id] = row[0][0]
      dog = self.new(attributes)
    else
      dog = self.create(attributes)
    end
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
  
end