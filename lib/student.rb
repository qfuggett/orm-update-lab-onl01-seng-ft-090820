require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  
  
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
    
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end
  
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end
    
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  
  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end
  
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE students.name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end
  end
  
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
end
