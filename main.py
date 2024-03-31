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
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:@localhost/newest_hotel_testing"
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


# Creating db models (tables) but are hardly used and only as a backup reference

class HotelChain(db.Model):
    __tablename__ = 'hotelchain'
    NAME = db.Column(db.String(255), primary_key=True)
    ADDRESS = db.Column(db.String(255))
    NumberOfHotels = db.Column(db.Integer)
    PhoneNumber = db.Column(db.String(20))  
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
    problems = db.Column(db.Boolean)
    
    

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
   

class Renting(db.Model):
    __tablename__ = 'renting'
    RentingID = db.Column(db.Integer, primary_key=True)
    CustomerID = db.Column(db.Integer, db.ForeignKey('customer.ID'))
    RoomNumber = db.Column(db.String(255), db.ForeignKey('room.RoomNumber'))
    HotelAddress = db.Column(db.String(255), db.ForeignKey('Hotel.ADDRESS'))
    StartDate = db.Column(db.Date, nullable=False)
    EndDate = db.Column(db.Date, nullable=False)
    Status = db.Column(db.String(255), nullable=False)  # e.g., "Checked-in", "Checked-out"

    
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


##homepage
@app.route("/")
def index():
    return render_template("index1.html")

    


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
        WHERE c.UserID = :userid AND bh.Status != 'cancelled';
    """)
    result = db.session.execute(query, {'userid': user_id})
    
    booking_history = result.fetchall()
    
    return render_template('bookingView.html', queryd = booking_history)

@app.route("/DeleteEmployeeAccount", methods=["POST"])
@login_required
def delete_employee_account():
    user_id = current_user.Userid

    try:
        # First, retrieve the Employee ID based on UserID
        employee_query = text("SELECT ID FROM Employee WHERE UserID = :user_id")
        employee_result = db.session.execute(employee_query, {'user_id': user_id}).fetchone()
        if not employee_result:
            flash("No employee found for the current user.", "danger")
            return redirect(url_for('index'))

        employee_id = employee_result[0]

        # Then, delete the Employee record. ResponsibleFor cleanup is handled by the trigger.
        delete_employee_query = text("DELETE FROM Employee WHERE UserID = :user_id")
        db.session.execute(delete_employee_query, {'user_id': user_id})

        # Now, delete the User record, which also effectively logs out the user if they are logged in.
        delete_user_query = text("DELETE FROM Users WHERE Userid = :user_id")
        db.session.execute(delete_user_query, {'user_id': user_id})

        # Commit the changes
        db.session.commit()

        # Log out the current user
        logout_user()
        flash("Your employee account and all related records have been successfully deleted.", "success")
    except Exception as e:
        # Rollback in case of any errors
        db.session.rollback()
        flash(f"An error occurred while deleting your employee account. Please try again.", "danger")
        print(e)

    # Redirect to the home page after account deletion
    return redirect(url_for('index'))


@app.route("/cancel/<string:BookingID>", methods=["POST", "GET"])
@login_required
def cancel(BookingID):
    # Prepare the SQL update query to change the status to "cancelled"
    update_query = text("UPDATE BookingHistory SET Status = 'cancelled' WHERE BookingID = :BookingID")

    # Execute the update query with the actual BookingID parameter
    db.session.execute(update_query, {'BookingID': BookingID})
    db.session.commit()

    # Flash a message to indicate successful cancellation
    flash('Booking cancelled successfully!', 'success')

    # Redirect to another page, e.g., the booking view page
    return redirect(url_for('bookingView'))

@app.route("/CustomerInformation", methods=["GET", "POST"])
@login_required
def CustomerInformation():
    user_id = current_user.Userid

    if request.method == "POST":
        # Extract the information from the form
        fullname = request.form.get("fullname")
        sin = request.form.get("sin")
        address = request.form.get("address")
        email = request.form.get("email")

        try:
            # Update the customer information in the database
            update_query = text("""
                UPDATE Customer
                SET Fullname = :fullname, SIN = :sin, Address = :address, Email = :email
                WHERE UserID = :user_id
            """)
            db.session.execute(update_query, {
                "fullname": fullname,
                "sin": sin,
                "address": address,
                "user_id": user_id,
                "email": email
            })
            db.session.commit()
            flash("Customer information updated successfully.", "success")
        except Exception as e:
            db.session.rollback()
            flash("An error occurred while updating customer information.", "danger")
            print(e)
        
        return render_template("index1.html")
    else:
        try:
            # Fetch the current customer's information to populate the form
            customer_query = text("SELECT * FROM Customer WHERE UserID = :user_id")
            customer = db.session.execute(customer_query, {"user_id": user_id}).first()
            if customer:
                print(customer)
                return (render_template("CustomerInformation.html", customer=customer))
            else:
                flash("Customer not found.", "danger")
                return redirect(url_for('index'))
        except Exception as e:
            flash("Failed to fetch customer details.", "danger")
            print(e)
            return redirect(url_for('index'))
        

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
        booked = 0

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
            query += " AND r.RoomCapacity >= :room_capacity"
            query_params['room_capacity'] = room_capacity
        if area:
            query += " AND h.Area = :area"
            query_params['area'] = area
        if hotel_chain:
            query += " AND h.ChainName = :hotel_chain"
            query_params['hotel_chain'] = hotel_chain
        if hotel_category: #this refers to hotel rating
            query += " AND h.Rating = :hotel_category"
            query_params['hotel_category'] = hotel_category
        if total_rooms:
            query += " AND h.NumberOfRooms >= :total_rooms"
            query_params['total_rooms'] = total_rooms
        if price_range:
            query += " AND r.Price <= :price_range"
            query_params['price_range'] = price_range
        query+= " AND r.Booked = :booked"
        query_params['booked'] = booked

        # Execute the query
        query = text(query)
        try:

            result = db.session.execute(query, query_params)
            rooms = result.fetchall()
            
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


@app.route("/edit/<string:BookingID>", methods=["POST", "GET"])
@login_required
@role_required("Customer")
def edit(BookingID):
    if request.method == "POST":
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        hotel_address = request.form.get('BranchAddress')  # Ensure this matches form field name
        room_number = request.form.get('room_number')

        try:
            # Update booking details using raw SQL
            update_query = text("""
                UPDATE BookingHistory
                SET StartDate = :start_date, EndDate = :end_date, HotelAddress = :hotel_address, RoomNumber = :room_number
                WHERE BookingID = :BookingID;
            """)
            db.session.execute(update_query, {
                'start_date': start_date,
                'end_date': end_date,
                'hotel_address': hotel_address,
                'room_number': room_number,
                'BookingID': BookingID
            })
            db.session.commit()
            flash("Booking Updated", "success")
         
        except Exception as e:
            db.session.rollback()
            flash("Booking information update failed, please check your inputs", "danger")
            print(f"Error while updating booking: {e}")
           
        return redirect(url_for('bookingView'))       

    # For GET request or in case of an error, fetch booking details to show on the edit page
    try:
        # Fetch booking details using raw SQL
        fetch_query = text("""
            SELECT * FROM BookingHistory WHERE BookingID = :BookingID;
        """)
        booking_details = db.session.execute(fetch_query, {'BookingID': BookingID}).fetchone()
        if booking_details:
            return render_template('edit.html', posts=booking_details)
        else:
            flash("No booking found with the provided ID", "danger")
            return redirect(url_for('bookingView'))
    except Exception as e:
        flash("An error occurred while fetching booking details", "danger")
        print(f"Error while fetching booking details: {e}")
        return redirect(url_for('bookingView'))


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
        current_id = current_user.Userid  

        # First, find the customer ID based on the current user ID
        sql_query = text("SELECT ID FROM Customer WHERE UserID = :Userid")
        result = db.session.execute(sql_query, {'Userid': current_id})
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

                # Check if a BooksAt record already exists
                check_books_at_query = text("""
                    SELECT * FROM BooksAt WHERE CustomerID = :customer_id AND HotelAddress = :hotel_address
                """)
                books_at_record = db.session.execute(check_books_at_query, {
                    'customer_id': customer_id,
                    'hotel_address': hotel_address
                }).fetchone()

                if not books_at_record:
                    # Insert into BooksAt table only if no record exists
                    insert_books_at_query = text("""
                        INSERT INTO BooksAt (CustomerID, HotelAddress) VALUES (:customer_id, :hotel_address)
                    """)
                    db.session.execute(insert_books_at_query, {
                        'customer_id': customer_id,
                        'hotel_address': hotel_address
                    })
                    db.session.commit()

                flash('Booking successful!', "success")
            else:
                flash('Customer not found!', "danger")
        except Exception as e:
            db.session.rollback()
            print("Error during booking: ", e)
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

@app.route("/deleteRoom/<string:Roomnum>", methods=["POST", "GET"])
@login_required
@role_required("Employee")
def deleteRoom(Roomnum):
    # Prepare the SQL delete query with parameter placeholders
    delete_query = text("DELETE FROM Room WHERE RoomNumber= :Roomnum")

    # Execute the delete query with the actual BookingID parameter
    db.session.execute(delete_query, {'Roomnum': Roomnum})
    db.session.commit()

    # Optionally, flash a message to indicate successful deletion
    flash('Room deleted successfully!', 'success')

    # Redirect to another page,
    return redirect(url_for('EmployeeEditRooms'))
@app.route("/EmployeeEditingRooms/<string:room_number>", methods=["GET", "POST"])
@login_required
@role_required("Employee")
def EmployeeEditingRooms(room_number):
    if request.method == "POST":
        # Extract room details from form submission
        extendability = request.form.get("Extendability")
        price = request.form.get("price")
        view = request.form.get("view")
        capacity = request.form.get("capacity")
        amenities = request.form.get("amenities")
        problems = request.form.get("problems")

        try:
            # Update room details using raw SQL
            update_query = text("""
                UPDATE Room
                SET Extendability = :extendability, Price = :price, View = :view, 
                    RoomCapacity = :capacity, Amenities = :amenities, problems = :problems
                WHERE RoomNumber = :room_number
            """)
            db.session.execute(update_query, {
                "extendability": extendability,
                "price": price,
                "view": view,
                "capacity": capacity,
                "amenities": amenities,
                "problems": problems,
                "room_number": room_number
            })
            db.session.commit()
            flash("Room updated successfully.", "success")
        except Exception as e:
            db.session.rollback()
            flash("Failed to update room details.", "danger")
            print(e)

        return redirect(url_for('EmployeeEditRooms'))

    else:
        # Fetch current room details to pre-populate the form for editing
        try:
            room_query = text("SELECT * FROM Room WHERE RoomNumber = :room_number")
            roomd = db.session.execute(room_query, {"room_number": room_number}).first()
            if roomd:
                return render_template("EmployeeEditingRooms.html", room=roomd)
            else:
                flash("Room not found.", "danger")
                return redirect(url_for('EmployeeEditRooms'))
        except Exception as e:
            flash("Failed to fetch room details.", "danger")
            print(e)
            return redirect(url_for('EmployeeEditRooms'))



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


@app.route("/EmployeeHotelInformation")
@login_required
def EmployeeHotelInformation():
    # Check if the current user is an Employee and their role is "Manager"
    if current_user.Role == "Employee":
        employee_info_query = text("SELECT Role FROM Employee WHERE UserID = :user_id")
        employee_info = db.session.execute(employee_info_query, {'user_id': current_user.Userid}).first()

        if employee_info and employee_info.Role == "Manager":
            # Query the database for all hotels
            hotels_query = text("SELECT * FROM Hotel")
            hotels_list = db.session.execute(hotels_query).fetchall()
            
            # Render the template with the hotels data
            return (render_template("EmployeeHotelInformation.html", hotels_list=hotels_list))
        else:
            flash("Access denied. This page is only available to Managers.", "danger")
            return redirect(url_for('EmployeeView'))
    else:
        flash("Access denied. You must be an employee to view this page.", "danger")
        return redirect(url_for('index'))
    
@app.route("/EditHotels/<hotel_address>", methods=["GET", "POST"])
@login_required
@role_required("Employee")
def Edithotels(hotel_address):
   
    if request.method == "POST":
        # Extract form data for the update
        number_of_rooms = request.form.get('NumberOfRooms')
        rating = request.form.get('Rating')
        chain_name = request.form.get('ChainName')
        area = request.form.get('Area')
        email = request.form.get('Email')

        try:
            # Perform the update in the database
            update_query = text("""
                UPDATE Hotel
                SET NumberOfRooms = :number_of_rooms, Rating = :rating, 
                    ChainName = :chain_name, Area = :area, Email = :email
                WHERE ADDRESS = :hotel_address
            """)
            db.session.execute(update_query, {
                "hotel_address": hotel_address,
                "number_of_rooms": number_of_rooms,
                "rating": rating,
                "chain_name": chain_name,
                "area": area,
                "email": email
            })
            db.session.commit()
            flash("Hotel information updated successfully.", "success")
            # Redirect back to the hotel information page after successful update
            return redirect(url_for('EmployeeHotelInformation'))
        except Exception as e:
            db.session.rollback()
            flash("An error occurred while updating hotel information.", "danger")
            print(e)

    # This part is for the GET request to display the form with existing hotel details
    hotel_query = text("SELECT * FROM Hotel WHERE ADDRESS = :hotel_address")
    hotel = db.session.execute(hotel_query, {"hotel_address": hotel_address}).first()
    
    if hotel:
        # Render the EditHotels template, passing the hotel details for GET request
        return render_template("EditHotels.html", hotel=hotel)
    else:
        flash("Hotel not found.", "danger")
        return redirect(url_for('EmployeeHotelInformation'))

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
    WHERE HotelAddress = :hotel_address AND Status = 'booked' """)
    bookings = db.session.execute(bookings_query, {'hotel_address': hotel_address}).fetchall()

    return render_template('EmployeeView.html', bookings_list=bookings)


@app.route("/AddHotels", methods=["GET", "POST"])
@login_required
@role_required("Employee") 
def AddHotels():
    if request.method == "POST":
        hotel_address = request.form.get('HotelAddress')
        number_of_rooms = request.form.get('NumberOfRooms')
        rating = request.form.get('Rating')
        chain_name = request.form.get('ChainName')
        area = request.form.get('Area')
        email = request.form.get('Email')

        # Check if the hotel chain exists
        chain_query = text("SELECT NAME FROM HotelChain WHERE NAME = :chain_name")
        chain_exists = db.session.execute(chain_query, {'chain_name': chain_name}).first()

        if not chain_exists:
            flash(f"Hotel chain {chain_name} does not exist. Please add the chain first.", "danger")
            return redirect(url_for('AddHotels'))

        # Check if the hotel already exists
        hotel_query = text("SELECT ADDRESS FROM Hotel WHERE ADDRESS = :hotel_address")
        hotel_exists = db.session.execute(hotel_query, {'hotel_address': hotel_address}).first()

        if hotel_exists:
            flash(f"Hotel with address {hotel_address} already exists.", "danger")
            return redirect(url_for('AddHotels'))

        try:
            # Add the new hotel
            insert_query = text("""
                INSERT INTO Hotel (ADDRESS, NumberOfRooms, Rating, ChainName, Area, Email) 
                VALUES (:hotel_address, :number_of_rooms, :rating, :chain_name, :area, :email)
            """)
            db.session.execute(insert_query, {
                'hotel_address': hotel_address,
                'number_of_rooms': number_of_rooms,
                'rating': rating,
                'chain_name': chain_name,
                'area': area,
                'email': email
            })
            db.session.commit()
            flash("New hotel added successfully.", "success")
        except Exception as e:
            db.session.rollback()
            flash(f"An error occurred while adding the hotel: {e}", "danger")

        return redirect(url_for('EmployeeHotelInformation'))  # Redirect after POST

     # GET request: Fetch all hotel chains to pass to the template
    chains_query = text("SELECT NAME FROM HotelChain")
    chains = db.session.execute(chains_query).fetchall()
    chain_names = [chain[0] for chain in chains]

    # Render the Add Hotel form, passing through the hotel chains
    return render_template("AddHotels.html", hotel_chains=chain_names)


@app.route("/AddRooms", methods=['GET', 'POST'])
@login_required
@role_required("Employee")  # Make sure only employees can add rooms
def AddRooms():
    if request.method == 'GET':
        # Render the form page. 
        return render_template("AddRooms.html")
    elif request.method == 'POST':
        room_number = request.form.get('RoomNumber')
        hotel_address = request.form.get('HotelAddress')
        extendability = request.form.get('Extendability') == 'true'
        room_problems = request.form.get('roomProblems') == 'true'
        price = request.form.get('Price')
        view = request.form.get('View')
        size = request.form.get('size')
        capacity = request.form.get('RoomCapacity')
        amenities = request.form.get('Amenities')
        booked = False

        # Check if the hotel address exists
        hotel_query = text("SELECT COUNT(*) FROM Hotel WHERE ADDRESS = :hotel_address")
        hotel_exists = db.session.execute(hotel_query, {'hotel_address': hotel_address}).scalar() > 0

        if not hotel_exists:
            flash('Hotel address does not exist.', 'danger')
            return redirect(url_for('AddRooms'))

        # Check if the room already exists
        room_query = text("SELECT COUNT(*) FROM Room WHERE RoomNumber = :room_number AND HotelAddress = :hotel_address")
        room_exists = db.session.execute(room_query, {'room_number': room_number, 'hotel_address': hotel_address}).scalar() > 0

        if room_exists:
            flash('Room already exists in this hotel.', 'danger')
            return redirect(url_for('AddRooms'))

        # Add the room since it doesn't exist
        insert_room_query = text("""
        INSERT INTO Room (RoomNumber, HotelAddress, Extendability, problems, Price, View, Size, RoomCapacity, Amenities, booked)
        VALUES (:room_number, :hotel_address, :extendability, :room_problems, :price, :view, :size, :capacity, :amenities, :booked)
        """)
        try:
            db.session.execute(insert_room_query, {
                'room_number': room_number,
                'hotel_address': hotel_address,
                'extendability': extendability,
                'room_problems': room_problems,
                'price': price,
                'view': view,
                'size': size,
                'capacity': capacity,
                'amenities': amenities,
                'booked': booked
            })
            db.session.commit()
            flash('Room added successfully.', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error adding room', 'danger')
            print(e)

        return redirect(url_for('EmployeeEditRooms'))


@app.route("/DeleteHotel/<string:hotel_address>", methods=["POST", "GET"])
@login_required
@role_required("Employee")  # Ensure only employees can access this function
def DeleteHotel(hotel_address):
    # Fetch the current employee's details
    employee_query = text("""
        SELECT HotelAddress FROM Employee WHERE UserID = :user_id
    """)
    employee = db.session.execute(employee_query, {"user_id": current_user.Userid}).first()
    
    if not employee:
        flash("Employee record not found.", "danger")
        return redirect(url_for('EmployeeHotelInformation'))
    
    # Check if the current employee's hotel address matches the hotel address to be deleted
    if employee.HotelAddress == hotel_address:
        flash("You do not have permission to delete this hotel.", "danger")
        return redirect(url_for('EmployeeHotelInformation'))
    
    try:
        # Proceed with deletion since the employee is associated with the hotel
        delete_query = text("DELETE FROM Hotel WHERE ADDRESS = :hotel_address")
        db.session.execute(delete_query, {"hotel_address": hotel_address})
        db.session.commit()
        flash("Hotel successfully deleted.", "success")
    except Exception as e:
        db.session.rollback()
        flash("An error occurred while deleting the hotel.", "danger")
        print(e)

    return redirect(url_for('EmployeeHotelInformation'))

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

@app.route("/view-rooms-info")
@login_required
def view_rooms_info():
    # Query the AvailableRoomsPerArea view
    available_rooms_query = text("SELECT * FROM AvailableRoomsPerArea")
    available_rooms = db.session.execute(available_rooms_query).fetchall()
    
    # Query the TotalCapacityPerHotel view
    total_capacity_query = text("SELECT * FROM TotalCapacityPerHotel")
    total_capacity = db.session.execute(total_capacity_query).fetchall()
    
    return render_template("rooms_info.html", available_rooms=available_rooms, total_capacity=total_capacity)

@app.route("/DeleteCustomerAccount", methods=["POST"])
@login_required
def delete_customer_account():
    user_id = current_user.Userid

    try:
        # First, retrieve the Customer ID based on UserID
        customer_query = text("SELECT ID FROM Customer WHERE UserID = :user_id")
        customer_result = db.session.execute(customer_query, {'user_id': user_id}).fetchone()
        if not customer_result:
            flash("No customer found for the current user.", "danger")
            return redirect(url_for('index'))

        customer_id = customer_result[0]

        # Then, delete the Customer record
        delete_customer_query = text("DELETE FROM Customer WHERE UserID = :user_id")
        db.session.execute(delete_customer_query, {'user_id': user_id})

        # Now, delete the User record
        delete_user_query = text("DELETE FROM Users WHERE Userid = :user_id")
        db.session.execute(delete_user_query, {'user_id': user_id})

        # Commit the changes
        db.session.commit()

        # Log out the current user
        logout_user()
        flash("Your account and all related records have been successfully deleted.", "success")
    except Exception as e:
        # Rollback in case of any errors
        db.session.rollback()
        flash(f"An error occurred while deleting your account. Please try again.", "danger")
        print(e)

    # Redirect to the home page after account deletion
    return redirect(url_for('index'))


@app.route("/EmployeeCheckin/<string:booking_id>", methods=["Post", "Get"])
@login_required
@role_required("Employee")
def EmployeeCheckin(booking_id):
    # Find the employee
    employee_id_query = text("""
            SELECT ID FROM Employee WHERE UserID = :user_id
        """)
    employee_result = db.session.execute(employee_id_query, {'user_id': current_user.Userid}).first()

    if not employee_result:
        flash('Employee not found.', 'danger')
        return redirect(url_for('EmployeeView'))

    employee_id = employee_result[0]

    try:
        # Find the booking
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
            VALUES (:StartDate, :EndDate, :RoomNumber, :HotelAddress, :CustomerID, 'Checked-in')
        """)
        db.session.execute(insert_renting, {
            'StartDate': booking.StartDate,
            'EndDate': booking.EndDate,
            'RoomNumber': booking.RoomNumber,
            'HotelAddress': booking.HotelAddress,
            'CustomerID': booking.CustomerID
        })
        db.session.commit()

        # Check if ResponsibleFor entry exists
        responsible_check_query = text("""
            SELECT * FROM ResponsibleFor WHERE EmployeeID = :EmployeeID AND CustomerID = :CustomerID
        """)
        responsible_exists = db.session.execute(responsible_check_query, {
            'EmployeeID': employee_id,
            'CustomerID': booking.CustomerID
        }).fetchone()

        if not responsible_exists:
            # Insert into ResponsibleFor if no entry exists
            insert_responsible = text("""
                INSERT INTO ResponsibleFor (EmployeeID, CustomerID)
                VALUES (:EmployeeID, :CustomerID)
            """)
            db.session.execute(insert_responsible, {
                'EmployeeID': employee_id,
                'CustomerID': booking.CustomerID
            })
            db.session.commit()

        # Update the BookingHistory status
        update_sql = text("UPDATE BookingHistory SET Status = 'Completed' WHERE BookingID = :booking_id")
        db.session.execute(update_sql, {'booking_id': booking_id})
        db.session.commit()

        flash('Check-in successful. Booking status updated to Completed.', 'success')
    except Exception as e:
        db.session.rollback()
        flash('An error occurred', 'danger')
        print(e)

    return redirect(url_for('EmployeeView'))

@app.route("/EmployeeCheckout/<int:renting_id>", methods=["POST", "GET"])
@login_required
def EmployeeCheckout(renting_id):
    try:
        # First, update the status of the renting to "Checked-out".
        
        db.session.execute(text("UPDATE Renting SET Status = 'Checked-out' WHERE RentingID = :renting_id"), {'renting_id': renting_id})

        # Then, find the associated room number and hotel address for the renting.
        room_details = db.session.execute(text("SELECT RoomNumber, HotelAddress FROM Renting WHERE RentingID = :renting_id"), {'renting_id': renting_id}).fetchone()

        if room_details:
            room_number, hotel_address = room_details
            # Now, set the 'booked' attribute of the associated room to false.
            db.session.execute(text("UPDATE Room SET booked = False WHERE RoomNumber = :room_number AND HotelAddress = :hotel_address"), {'room_number': room_number, 'hotel_address': hotel_address})

            db.session.commit()
            flash("Checkout successful, and room status updated.", "success")
        else:
            flash("Renting details not found.", "danger")

    except Exception as e:
        db.session.rollback()
        flash(f"An error occurred during checkout: ", "danger")
        print(e)

    return redirect(url_for('RentingView'))


@app.route("/RentingView")
@login_required
def RentingView():

    user_id = current_user.Userid  

    try:
        # Fetch rentings for customers this employee is responsible for.
       
        renting_query = text("""
            SELECT r.* FROM Renting r
            JOIN ResponsibleFor rf ON r.CustomerID = rf.CustomerID
            JOIN Employee e ON rf.EmployeeID = e.ID
            WHERE e.UserID = :user_id;
        """)

        renting_result = db.session.execute(renting_query, {'user_id': user_id})
        rentings = renting_result.fetchall()

        # Pass the fetched rentings to the template.
        return render_template("RentingView.html", renting_list=rentings)

    except Exception as e:
        flash(f"An error occurred while fetching renting information: {e}", "danger")
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

@app.route("/EmployeeSignup", methods=['POST', "GET"])
def EmployeeSignup():
    if request.method == "POST":
        name = request.form.get('EmployeeName')
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        role = request.form.get('role')
        emp_address = request.form.get('Emp_Address')
        hoteladd = request.form.get('hoteladd')
        
        # Check if the user already exists
        existing_user_query = text("SELECT * FROM Users WHERE Username = :username")
        result = db.session.execute(existing_user_query, {'username': username}).first()

        if result:
            flash('Signup failed: username already exists.', "danger")
            return redirect(url_for("EmployeeSignup"))
        
        
         # Check if the hotel exists
        existing_hotel_query = text("SELECT * FROM Hotel WHERE ADDRESS = :hoteladd")
        existing_hotel_result = db.session.execute(existing_hotel_query, {'hoteladd': hoteladd}).first()

        if not existing_hotel_result:
            flash('Signup failed: Hotel does not exist.', "danger")
            return redirect(url_for("EmployeeSignup"))
        
        # Insert into Users table
       
        try:
            insert_user_query = text("""
            INSERT INTO Users (Username, Password, Email, Role) 
            VALUES (:username, :password, :email, 'Employee');
        """)

            
            db.session.execute(insert_user_query, {'username': username, 'password': password, 'email': email})
            db.session.commit()

            # Fetch the newly created user ID
            new_user_result = db.session.execute(existing_user_query, {'username': username, 'email': email}).first()
            new_user_id = new_user_result.UserID

            # Insert into Employee table
            insert_employee_query = text("""
            INSERT INTO Employee (UserID, Fullname, Address, HotelAddress, Role) 
            VALUES (:user_id, :name, :emp_address, :hotelAddress, :role);
        """)
            
            db.session.execute(insert_employee_query, {'user_id': new_user_id, 'name': name, 'emp_address': emp_address,'hotelAddress':hoteladd, 'role': role})
            db.session.commit()

            flash("Employee signup successful.", "success")
            return redirect(url_for("login")) # Assuming you have a login page for employees
        except Exception as e:
            db.session.rollback()
            flash("Error creating user or customer, try again")
            print(e)
    return render_template("EmployeeSignup.html")


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
