from flask import Flask, flash, render_template, request, session, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
from sqlalchemy import inspect
from flask_login import UserMixin
from flask_login import login_user,logout_user,login_manager,LoginManager
from flask_login import login_required,current_user
from flask_mail import Mail


db = SQLAlchemy()
app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:@localhost/hotel_db"
db.init_app(app)

app.secret_key = 'kevin_science'

##login
login_manager = LoginManager(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    return Users.query.get(int(user_id))

# Creating db models (tables)
class HotelChain(db.Model):
    __tablename__ = 'hotelchain'
    NAME = db.Column(db.String(255), primary_key=True)
    ADDRESS = db.Column(db.String(255))
    NumberOfHotels = db.Column(db.Integer)
    PhoneNumber = db.Column(db.String(20))  # Change to String if your phone numbers include non-numeric characters
    Email = db.Column(db.String(255))
    

class Customer(UserMixin,db.Model):
    __tablename__ = 'customer'
    ID = db.Column(db.Integer, primary_key=True)
    Fullname = db.Column(db.String(255))
    Username = db.Column(db.String(255), unique=True)
    Password = db.Column(db.String(255))
    Email = db.Column(db.String(255), unique=True)
    def get_id(self):
        return self.ID
    
class Employee(db.Model):
    __tablename__ = 'employee'
    ID = db.Column(db.Integer, primary_key=True)
    UserID = db.Column(db.Integer, db.ForeignKey('user.UserID'))
    Address = db.Column(db.String(255))
    Fullname = db.Column(db.String(255))
    HotelAddress = db.Column(db.String(255), db.ForeignKey('hotel.ADDRESS'))
    # Relationship to User table if needed

class Room(db.Model):
    __tablename__ = 'room'
    RoomNumber = db.Column(db.String(255), primary_key=True)
    HotelAddress = db.Column(db.String(255), db.ForeignKey('hotel.ADDRESS'), primary_key=True)
    Extendability = db.Column(db.Boolean)
    Price = db.Column(db.Numeric(10, 2))
    View = db.Column(db.String(255))
    Size = db.Column(db.String(255))
    # Relationships if needed

class BookingHistory(db.Model):
    __tablename__ = 'bookinghistory'
    BookingID = db.Column(db.Integer, primary_key=True)
    CustomerID = db.Column(db.Integer, db.ForeignKey('customer.ID'))
    RoomNumber = db.Column(db.String(255), db.ForeignKey('room.RoomNumber'))
    HotelAddress = db.Column(db.String(255), db.ForeignKey('room.HotelAddress'))
    BookingDate = db.Column(db.Date)
    StartDate = db.Column(db.Date)
    EndDate = db.Column(db.Date)
    Status = db.Column(db.String(255))
    # Relationships to Customer and Room tables if needed

class Amenities(db.Model):
    __tablename__ = 'amenities'
    RoomNumber = db.Column(db.String(255), db.ForeignKey('room.RoomNumber'), primary_key=True)
    HotelAddress = db.Column(db.String(255), db.ForeignKey('room.HotelAddress'), primary_key=True)
    TV = db.Column(db.Boolean)
    Fridge = db.Column(db.Boolean)
    AirCondition = db.Column(db.Boolean)
    # Relationship to Room table if needed

    
class Hotel(db.Model):
    __tablename__ = 'hotel'
    Address = db.Column(db.String(255), primary_key=True)
    Email = db.Column(db.String(255), nullable=False)
    NumberOfRooms = db.Column(db.Integer, nullable=False)
    Rating = db.Column(db.Integer, nullable=False)
    ChainName = db.Column(db.String(255), db.ForeignKey('hotelchain.NAME'), nullable=False)
    BranchName = db.Column(db.String(255), nullable=False)  # Assuming you've added a BranchName column


    def __repr__(self):
        return f'<Hotel {self.BranchName} in chain {self.ChainName}>'

class Users(UserMixin,db.Model):
    Userid=db.Column(db.Integer,primary_key=True)
    Username=db.Column(db.String(50))
    Password=db.Column(db.String(1000))
    Email=db.Column(db.String(50),unique=True)
    def get_id(self):
        return self.Userid



@app.route("/")
def index():
    return render_template("index1.html")

@app.route("/test")
def hello_world():
    try:
        # Query the first hotel chain
        first_hotel_chain = HotelChain.query.all()
        for i in first_hotel_chain:
            # Construct a response string with details of the first hotel chain
            response = (f"Hotel Chain Name: {i.NAME}, "
                        f"Address: {i.ADDRESS}, "
                        f"Number Of Hotels: {i.NumberOfHotels}, "
                        f"Phone Number: {i.PhoneNumber}, "
                        f"Email: {i.Email}")
            return response
        else:
            return "No hotel chains found in the database."
    except Exception as e:
        return f"An error occurred: {str(e)}"
    

@app.route("/hotels")
def hotels():
    return render_template("hotels.html")

@app.route("/bookingView")
@login_required
def bookingView():
    em = current_user.Email
    query = text("""
        SELECT bh.*
        FROM BookingHistory bh
        JOIN Customer c ON bh.CustomerID = c.ID
        WHERE c.Email = :email;
    """)
    result = db.session.execute(query, {'email': em})
    
    booking_history = result.fetchall()
    
    return render_template('bookingView.html', queryd = booking_history)



@app.route("/edit/<string:BookingID>", methods = ["Post", "Get"])
@login_required
def edit(BookingID):
     post = BookingHistory.query.filter_by(BookingID=BookingID).first()
     if request.method == "POST":
        email = request.form.get('email')
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        hotel_address = request.form.get('BranchAddress')  # Ensure this matches your form field name
        room_number = request.form.get('room_number')

        # Prepare SQL query to update booking
        update_query = text("""
            UPDATE BookingHistory
            SET StartDate = :start_date, EndDate = :end_date, HotelAddress = :hotel_address, RoomNumber = :room_number
            WHERE BookingID = :BookingID;
        """)

        # Execute SQL query with provided parameters
        db.session.execute(update_query, {
            'start_date': start_date,
            'end_date': end_date,
            'hotel_address': hotel_address,
            'room_number': room_number,
            'BookingID': BookingID
        })
        db.session.commit()

        print('Booking updated successfully!', 'success')
        return redirect(url_for('bookingView'))
     else:
         return render_template('edit.html',posts = post)
        

@app.route("/bookings", methods=['POST', 'GET'])
@login_required
def bookings():
    if request.method == "POST":
        email = request.form.get('email')
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        hotel_address = request.form.get('BranchAddress')
        room_number = request.form.get('room_number')

        # First, find the customer ID based on the email
        sql_query = text("SELECT ID FROM Customer WHERE Email = :email")
        result = db.session.execute(sql_query, {'email': email})
        customer_record = result.fetchone()

        if customer_record:
            customer_id = customer_record[0]
            # Now insert the booking into the BookingHistory table using raw SQL
            insert_query = text("""
                INSERT INTO bookinghistory (CustomerID, RoomNumber, HotelAddress, StartDate, EndDate, Status) 
                VALUES (:customer_id, :room_number, :hotel_address, :start_date, :end_date, 'booked');
            """)
            db.session.execute(insert_query, {
                'customer_id': customer_id,
                'room_number': room_number,
                'hotel_address': hotel_address,
                'start_date': start_date,
                'end_date': end_date
            })
            db.session.commit()
            print('Booking successful!')
        else:
            print ('Customer not found!')

    return render_template('bookings.html', current_userd = current_user)


@app.route("/rooms")
def rooms():
    return render_template("rooms.html")

@app.route("/signup", methods=['POST', "GET"])
def signup():
    if request.method == "POST":
        name = request.form.get('customerName')
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        # Check if the user already exists
        existing_user_query = text("SELECT * FROM Users WHERE Username = :username OR Email = :email")
        result = db.session.execute(existing_user_query, {'username': username, 'email': email}).first()

    
        
        if result:
            print('Signup failed: username or email already exists')
            return render_template("signup1.html")
        
        # Insert into Users table
        insert_user_query = text("""
            INSERT INTO Users (Username, Password, Email) 
            VALUES (:username, :password, :email);
        """)
        
        db.session.execute(insert_user_query, {'username': username, 'password': password, 'email': email})
        db.session.commit()
        
        # Fetch the newly created user ID again
        new_user_id_result = db.session.execute(existing_user_query, {'username': username, 'email': email}).first()
        new_user_id = new_user_id_result[0]  # Assuming UserID is the first column in the SELECT result
        
        # Insert into Customer table
        insert_customer_query = text("""
            INSERT INTO Customer (UserID, Fullname, Username, Password, Email) 
            VALUES (:user_id, :name, :username, :password, :email);
        """)
        
        db.session.execute(insert_customer_query, {'user_id': new_user_id, 'name': name, 'username': username, 'password': password, 'email': email})
        db.session.commit()
        
        print("Signup success")
        return render_template("login1.html")
        
    return render_template("signup1.html")

@app.route("/login", methods=['POST', 'GET'])
def login():
    if request.method == "POST":
        username = request.form.get('username')
        password = request.form.get('password')
        customer = Users.query.filter_by(Username=username).first()

        if customer and customer.Password == password:  
            login_user(customer)
            flash("Login Success", "Primary")
            return redirect(url_for('bookings'))
        else:
            flash("Invalid credentials", "danger")
    return render_template('login1.html')

@app.route("/logout")
@login_required
def logout():
   logout_user()
   print("logged out")
   return redirect(url_for('login'))


if __name__ == '__main__':
    app.run(debug=True)
