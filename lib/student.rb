require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.new_from_db(row)
  # create a new Student object given a row from the database
    new_student = self.new(nil, nil)
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    new_student  # return the newly created instance
  end

  def self.all
  # retrieve all the rows from the "Students" database
  # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
    SQL

    DB[:conn].execute(sql).map do |row|
    self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
  # find the student in the database given a name
  # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end.first
  end

  def save
    if self.id
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?;"

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?);"

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def update
  sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?;"

  DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

end
