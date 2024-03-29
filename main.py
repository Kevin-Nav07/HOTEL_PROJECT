from functools import wraps
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

def get_all_rooms():
    sql = text("SELECT * FROM Room")
    result = db.session.execute(sql)
    rows = result.fetchall()
    # Assuming Room is a model, convert result rows to Room model instances if needed
    # This part is skipped, but you might need to process rows depending on how you intend to use them
    return rows

def get_hotels_from_chain(chain_name):
    sql = "SELECT * FROM Hotel WHERE ChainName = :chain_name"
    result = db.session.execute(sql, {'chain_name': chain_name})
    rows = result.fetchall()
    return [{'Hotel Address': row.Address, 'Email': row.Email, 'NumberOfRooms': row.NumberOfRooms, 'Rating': row.Rating, 'ChainName': row.ChainName, 'Area': row.BranchName} for row in rows]

def get_chains():
    sql = "SELECT NAME FROM HotelChain"
    result = db.session.execute(sql)
    chains = result.fetchall()
    chain_list = [chain.NAME for chain in chains]
    return chain_list


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
    UserID = db.Column(db.Integer, db.ForeignKey('user.Userid'))
    Username = db.Column(db.String(255), unique=True)
    Address = db.Column(db.String(255))
    Username = db.Column(db.String(255), unique=True)
    Password = db.Column(db.String(255))
    Email = db.Column(db.String(255), unique=True)
    SIN = db.Column(db.String(255), unique =True)
    def get_id(self):
        return self.ID
    
class Employee(db.Model):
    __tablename__ = 'employee'
    ID = db.Column(db.Integer, primary_key=True)
    UserID = db.Column(db.Integer, db.ForeignKey('user.Userid'))
    Address = db.Column(db.String(255))
    Fullname = db.Column(db.String(255))
    HotelAddress = db.Column(db.String(255), db.ForeignKey('hotel.ADDRESS'))
    Role = db.Column(db.String(255))
    # Relationship to User table if needed

class Room(db.Model):
    __tablename__ = 'room'
    RoomNumber = db.Column(db.String(255), primary_key=True)
    HotelAddress = db.Column(db.String(255), db.ForeignKey('hotel.ADDRESS'), primary_key=True)
    Extendability = db.Column(db.Boolean)
    Price = db.Column(db.Numeric(10, 2))
    View = db.Column(db.String(255))
    Size = db.Column(db.String(255))
    RoommCapacity = db.Column(db.Integer())
    Amenities = db.Column(db.String(255))
    problems = db.Column(db.String(255))
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

class Renting(db.Model):
    __tablename__ = 'renting'
    RentingID = db.Column(db.Integer, primary_key=True)
    CustomerID = db.Column(db.Integer, db.ForeignKey('customer.ID'))
    RoomNumber = db.Column(db.String(255), db.ForeignKey('room.RoomNumber'))
    HotelAddress = db.Column(db.String(255), db.ForeignKey('Hotel.ADDRESS'))
    StartDate = db.Column(db.Date, nullable=False)
    EndDate = db.Column(db.Date, nullable=False)
    Status = db.Column(db.String(255), nullable=False)  # e.g., "Checked-in", "Completed"

    
class Hotel(db.Model):
    __tablename__ = 'hotel'
    ADDRESS = db.Column(db.String(255), primary_key=True)
    Email = db.Column(db.String(255), nullable=False)
    NumberOfRooms = db.Column(db.Integer, nullable=False)
    Rating = db.Column(db.Integer, nullable=False)
    ChainName = db.Column(db.String(255), db.ForeignKey('hotelchain.NAME'), nullable=False)
    Area= db.Column(db.String(255), nullable=False)  # Assuming you've added a BranchName column
    def __repr__(self):
        return f'<Hotel {self.Address} in chain {self.ChainName}>'

class Users(UserMixin,db.Model):
    Userid=db.Column(db.Integer,primary_key=True)
    Username=db.Column(db.String(50))
    Password=db.Column(db.String(1000))
    Email=db.Column(db.String(50),unique=True)
    Role = db.Column(db.String(10))
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

def role_required(*roles):
    def wrapper(fn):
        @wraps(fn)
        def decorated_view(*args, **kwargs):
            if not current_user.is_authenticated:
                return login_manager.unauthorized()
            if current_user.Role not in roles:
                flash('You do not have permission to access this page.')
                return redirect(url_for('index'))
            return fn(*args, **kwargs)
        return decorated_view
    return wrapper

@app.route("/bookingView")
@login_required
@role_required("Customer")
def bookingView():
    user_id = current_user.Userid
    query = text("""
        SELECT bh.*
        FROM BookingHistory bh
        JOIN Customer c ON bh.CustomerID = c.ID
        WHERE c.UserID = :userid;
    """)
    result = db.session.execute(query, {'userid': user_id})
    
    booking_history = result.fetchall()
    
    return render_template('bookingView.html', queryd = booking_history)

@app.route("/delete/<string:BookingID>", methods=["POST", "GET"])
@login_required
@role_required("Customer")
def delete(BookingID):
    # Prepare the SQL delete query with parameter placeholders
    delete_query = text("DELETE FROM BookingHistory WHERE BookingID = :BookingID")

    # Execute the delete query with the actual BookingID parameter
    db.session.execute(delete_query, {'BookingID': BookingID})
    db.session.commit()

    # Optionally, flash a message to indicate successful deletion
    flash('Booking deleted successfully!', 'success')

    # Redirect to another page, e.g., the booking view page
    return redirect(url_for('bookingView'))

@app.route("/SearchRooms", methods = ['Post', 'Get'])
@login_required
@role_required("Customer")
def searchRooms():
    # Fetch form data
    print('in search')
    if(request.method== "POST"):

        room_capacity = request.form.get('roomCapacity')
        area = request.form.get('area')
        hotel_chain = request.form.get('hotelChain')
        hotel_category = request.form.get('Rating')
        total_rooms = request.form.get('totalRooms')
        price_range = request.form.get('price')

        # Start building the SQL query
        query = """
            SELECT r.*, h.ADDRESS
            FROM Room r
            JOIN Hotel h ON r.HotelAddress = h.ADDRESS
            WHERE 1=1
        """

        # Add conditions based on the presence of filters
        query_params = {}
        if room_capacity:
            query += " AND r.Capacity >= :room_capacity"
            query_params['room_capacity'] = room_capacity
        if area:
            query += " AND h.Area = :area"
            query_params['area'] = area
        if hotel_chain:
            query += " AND h.ChainName = :hotel_chain"
            query_params['hotel_chain'] = hotel_chain
        if hotel_category:  # Assuming this refers to hotel rating
            query += " AND h.Rating = :hotel_category"
            query_params['hotel_category'] = hotel_category
        if total_rooms:
            query += " AND h.NumberOfRooms >= :total_rooms"
            query_params['total_rooms'] = total_rooms
        if price_range:
            query += " AND r.Price <= :price_range"
            query_params['price_range'] = price_range

        # Execute the query
        query = text(query)
        try:

            result = db.session.execute(query, query_params)
            rooms = result.fetchall()
            print(rooms)
        except Exception as e:
            print("Error trying to get rooms", e)
            db.session.rollback()
        return(render_template("RoomsView.html", rooms_list=rooms))
        
    # Fetch hotel chains from the database
    query = text("SELECT DISTINCT ChainName FROM Hotel ORDER BY ChainName")
    result = db.session.execute(query)
    hotel_chains = result.fetchall()

    # Render the results on a new template or the same with the search form
    return render_template('SearchRooms.html', hotel_chain_list=hotel_chains)


@app.route("/edit/<string:BookingID>", methods = ["Post", "Get"])
@login_required
@role_required("Customer")
def edit(BookingID):
     post = BookingHistory.query.filter_by(BookingID=BookingID).first()
     if request.method == "POST":
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        hotel_address = request.form.get('BranchAddress')  # Ensure this matches your form field name
        room_number = request.form.get('room_number')

        # Prepare SQL query to update booking

        try:

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
        except Exception as e:
            db.session.rollback()
            flash("Booking information update failed, invalid hotel information")
            print("error while updating booking: ", e)
            return render_template("edit.html", posts = post)
        flash("Booking Updated", "Success")
        return (redirect(url_for("bookingView")))
        
     else:
         print(post.HotelAddress)
         return render_template('edit.html',posts = post)
        

@app.route("/bookings", methods=['POST', 'GET'])
@login_required
@role_required("Customer")
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
        try:

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
                flash('Booking successful!', "success")
            else:
                flash('Customer not found!', "danger")
        except Exception as e:
            db.session.rollback()
            print("Error creating booking ", e)
            flash("Error creating booking, possibly invalid hotel information", "danger")

   

    return render_template('bookings.html', current_userd = current_user)


@app.route("/EmployeeInformation", methods = ["Post", "Get"])
@login_required
@role_required("Employee")
def EmployeeInformation():
     # Assuming current_user stores the logged-in user's info, including Userid
    if request.method == "POST":
        # Get the form data
        fullname = request.form.get("fullname")
        address = request.form.get("address")
        hotelAddress = request.form.get("hotelAddress")
        position = request.form.get("position")
        print(position)
        
        try:
            # Update the employee information
            update_query = text("""
                UPDATE Employee 
                SET Fullname = :fullname, Address = :address, HotelAddress = :hotelAddress, Role = :role
                WHERE UserID = :user_id
            """)
            db.session.execute(update_query, {
                "fullname": fullname,
                "address": address,
                "hotelAddress": hotelAddress,
                "user_id": current_user.Userid,
                "role": position})
            db.session.commit()
            flash("Employee information updated successfully.", "success")
        except Exception as e:
            db.session.rollback()
            flash("An error occurred while updating employee information.", "danger")
            print(e)
        
        # Redirect to prevent form resubmission
        return redirect(url_for('EmployeeView'))

    user_id = current_user.Userid
    
    
    # Query the Employee table to get the employee details for the logged-in user
    try:
            
        employee_query = text("SELECT * FROM Employee WHERE UserID = :user_id")
        employee_result = db.session.execute(employee_query, {'user_id': user_id})
        
        # Fetchone since there should only be one record per user
        employeed = employee_result.fetchone()
    except Exception as e:
        print("Error trying to access employee: ", e)
        db.session.rollback()
    
    if employeed:
        # Pass the employee to the template
        print(employeed)
        return render_template("EmployeeInformation.html", employee=employeed, current_userd=current_user)
    else:
        # Handle cases where the employee record does not exist
        flash("Employee record not found.", "danger")
        return redirect(url_for('index'))




@app.route("/EmployeeLogin", methods=['POST', 'GET'])
def EmployeeLogin():
    if request.method == "POST":
        username = request.form.get('username')
        password = request.form.get('password')
        employee = Users.query.filter_by(Username=username).first()

        if employee and employee.Password == password:  
            login_user(employee)
            flash("Login Success", "success")
            return redirect(url_for('EmployeeView'))
        else:
            flash("Invalid credentials", "danger")
    return render_template('EmployeeLogin.html')

@app.route("/EmployeeView", methods = ["POST", "GET"])
@login_required
@role_required("Employee")
def EmployeeView():
    # Fetch the Employee's HotelAddress using raw SQL
    employee_query = text("SELECT * FROM Employee WHERE UserID = :user_id")
    employee = db.session.execute(employee_query, {'user_id': current_user.Userid}).first()

    if not employee:
        flash("Employee profile not found.", "danger")
        return redirect(url_for("index"))

    hotel_address = employee.HotelAddress

    # Fetch the bookings for the hotel using raw SQL
    bookings_query = text("""
    SELECT * FROM BookingHistory
    WHERE HotelAddress = :hotel_address AND Status != 'Completed' """)
    bookings = db.session.execute(bookings_query, {'hotel_address': hotel_address}).fetchall()

    return render_template('EmployeeView.html', bookings_list=bookings)

@app.route("/EmployeeEditRooms", methods = ["Post", "Get"])
@login_required
@role_required("Employee")
def EmployeeEditRooms():
    # Assuming 'current_user' is the logged-in employee
    employee_id = current_user.Userid
    # SQL to get the hotel address for the current employee
    try:

        hotel_address_query = text("SELECT HotelAddress FROM Employee WHERE UserID = :employee_id")
        hotel_address_result = db.session.execute(hotel_address_query, {'employee_id': employee_id})
        hotel_address = hotel_address_result.fetchone()
    except Exception as e:
         
         db.session.rollback()
         print(f'An error occurred: {str(e)}', 'danger')


    if hotel_address:
        # SQL to get rooms belonging to the employee's hotel
        try:
            rooms_query = text("SELECT * FROM Room WHERE HotelAddress = :hotel_address")
            rooms = db.session.execute(rooms_query, {'hotel_address': hotel_address[0]}).fetchall()
            return render_template("EmployeeEditRooms.html", rooms_list=rooms)
        except Exception as e:
              db.session.rollback()
              print(f'An error occurred: {str(e)}', 'danger')
    else:
        flash("Employee's hotel not found.", "danger")
        return redirect(url_for('index'))


@app.route("/EmployeeCheckin/<string:booking_id>", methods = ["Post", "Get"])
@login_required
@role_required("Employee")
def EmployeeCheckin(booking_id):
     # Find the booking
    try:
        booking_query = text("""
            SELECT * FROM BookingHistory WHERE BookingID = :booking_id
        """)
        booking = db.session.execute(booking_query, {'booking_id': booking_id}).first()

        if booking is None:
            flash('Booking not found.', 'danger')
            return redirect(url_for('EmployeeView'))

    

        # Create a new renting record without BookingID
        insert_renting = text("""
            INSERT INTO Renting (StartDate, EndDate, RoomNumber, HotelAddress, CustomerID, Status)
            VALUES (:StartDate, :EndDate, :RoomNumber,:HotelAddress, :CustomerID, 'Checked-in')
        """)

        db.session.execute(insert_renting, {
            'StartDate': booking.StartDate,
            'EndDate': booking.EndDate,
            'RoomNumber': booking.RoomNumber,
            'HotelAddress':booking.HotelAddress,
            'CustomerID': booking.CustomerID
        })
        db.session.commit()

        # Update the BookingHistory status
        try:
            update_sql = text("UPDATE BookingHistory SET Status = :status WHERE BookingID = :booking_id")
            db.session.execute(update_sql, {'status': 'Completed', 'booking_id': booking_id})
            db.session.commit()
            flash('Check-in successful. Booking status updated to Completed.', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'An error occurred while updating booking status: {str(e)}', 'danger')

    except Exception as e:
        db.session.rollback()
        flash(f'An error occurred: {str(e)}', 'danger')

    return redirect(url_for('EmployeeView'))




@app.route("/signup", methods=['POST', "GET"])
def signup():
    if request.method == "POST":
        name = request.form.get('customerName')
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        sin = request.form.get("SIN")
        Cust_Address = request.form.get("Cust_Address")
        role = "Customer"
        
        # Check if the user already exists
        existing_user_query = text("SELECT * FROM Users WHERE Username = :username OR Email = :email")
        result = db.session.execute(existing_user_query, {'username': username, 'email': email}).first()

    
        
        if result:
            flash('Signup failed: username or email already exists', "danger")
            return render_template("signup1.html")
        
        # Insert into Users table
        insert_user_query = text("""
            INSERT INTO Users (Username, Password, Email, Role) 
            VALUES (:username, :password, :email, :role);
        """)
        
        db.session.execute(insert_user_query, {'username': username, 'password': password, 'email': email, 'role': role})
        db.session.commit()
        
        # Fetch the newly created user ID again
        new_user_id_result = db.session.execute(existing_user_query, {'username': username, 'email': email}).first()
        new_user_id = new_user_id_result[0]  # Assuming UserID is the first column in the SELECT result
        
        # Insert into Customer table
        insert_customer_query = text("""
            INSERT INTO Customer (UserID, Fullname,Address, Email, SIN) 
            VALUES (:user_id, :name, :Cust_Address , :email, :sin);
        """)
        
        db.session.execute(insert_customer_query, {'user_id': new_user_id, 'name': name, 'Cust_Address': Cust_Address, 'email': email, "sin" : sin})
        db.session.commit()
        
        flash("Signup success", "success")
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
   flash("logged out", "success")
   return redirect(url_for('login'))



if __name__ == '__main__':
    app.run(debug=True)
