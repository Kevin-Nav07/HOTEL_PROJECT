from flask import Flask, request, render_template
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
@app.route("/")
def index():
    return render_template("index1.html")

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',  # Your database host
            user='root',  # Your database username
            password='',  # Your database password
            database='hotel_db'  # Your database name
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL database: {e}")
        return None
@app.route("/hotels")
def hotels():
    return render_template("hotels.html")
@app.route("/bookings")
def hbookings():
    return render_template("bookings.html")

@app.route("/rooms")
def rooms():
    return render_template("rooms.html")
@app.route('/signup', methods=['POST'])
def signup():
    # Extracting data from received request
   if request.method == "POST":
        name = request.form.get('customerName')
        username=request.form.get('username')
        email=request.form.get('email')
        password=request.form.get('password')
        customerID=request.form.get('customerID')
    # SQL query to insert the new customer
        insert_query = """
            INSERT INTO Customer (Fullname, Address, Email, Username, Password) 
            VALUES (%s, %s, %s, %s, %s)
        """

        try:
            # Establishing a database connection
            db_connection = get_db_connection()
            cursor = db_connection.cursor()
            # Executing the insert query with provided data
            cursor.execute(insert_query, (fullname, address, email, username, password))
            db_connection.commit()  # Committing the transaction
            cursor.close()
            db_connection.close()
            return 'Signup successful'
        except Error as e:
            print(f"Error: {e}")
            return 'Signup failed due to database error'

if __name__ == '__main__':
    app.run(debug=True)