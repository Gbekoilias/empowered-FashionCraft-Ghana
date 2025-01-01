import db, db/sqlite

# Define the structure of the training program
type
  TrainingProgram = object
    id: int
    program_name: string
    duration: int # Duration in hours

# Database initialization and connection
proc initDB(): Db =
  let db = open("training_programs.db")
  db.exec("""
    CREATE TABLE IF NOT EXISTS training_programs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      program_name TEXT NOT NULL,
      duration INTEGER NOT NULL
    )
  """)
  return db

# Function to add a new training program
proc addTrainingProgram(db: Db, program_name: string, duration: int) =
  db.exec("INSERT INTO training_programs (program_name, duration) VALUES (?, ?)", program_name, duration)

# Function to retrieve all training programs
proc getAllTrainingPrograms(db: Db): seq[TrainingProgram] =
  var programs: seq[TrainingProgram] = @[]
  for row in db.query("SELECT id, program_name, duration FROM training_programs"):
    let program = TrainingProgram(
      id = row[0].int,
      program_name = row[1].str,
      duration = row[2].int
    )
    programs.add(program)
  return programs

# Function to update a training program by ID
proc updateTrainingProgram(db: Db, id: int, program_name: string, duration: int) =
  db.exec("UPDATE training_programs SET program_name = ?, duration = ? WHERE id = ?", program_name, duration, id)

# Function to delete a training program by ID
proc deleteTrainingProgram(db: Db, id: int) =
  db.exec("DELETE FROM training_programs WHERE id = ?", id)

# Example usage of the defined functions
proc main() =
  let db = initDB()

  # Adding some sample training programs
  addTrainingProgram(db, "Nim Programming Basics", 20)
  addTrainingProgram(db, "Advanced Nim Techniques", 30)

  # Retrieve and print all training programs
  let programs = getAllTrainingPrograms(db)
  for program in programs:
    echo "ID: ", program.id, ", Name: ", program.program_name, ", Duration: ", program.duration

  # Update a training program (example)
  updateTrainingProgram(db, 1, "Nim Programming Fundamentals", 25)

  # Delete a training program (example)
  deleteTrainingProgram(db, 2)

# Run the main procedure when the script is executed
when isMainModule:
  main()
