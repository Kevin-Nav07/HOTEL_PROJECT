from flask import Flask, flash, render_template, request, session, redirect, url_for
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
    return Customer.query.get(int(user_id))

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

class User(UserMixin,db.Model):
    id=db.Column(db.Integer,primary_key=True)
    username=db.Column(db.String(50))
    email=db.Column(db.String(50),unique=True)
    password=db.Column(db.String(1000))



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
@app.route("/bookings")
def bookings():
    return render_template("bookings.html", username=current_user.Username)

@app.route("/rooms")
def rooms():
    return render_template("rooms.html")

@app.route("/signup", methods = ['post', "get"])
def signup():
    if request.method == "POST":
        name = request.form.get('customerName')
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        # Assuming the customerID is not needed as mentioned before
        # since ID is usually auto-generated. If it's not auto-generated,
        # ensure your database schema is set up to handle it accordingly.

        # Wrap the raw SQL query with the text() function
        existing_customer = Customer.query.filter((Customer.Username == username) | (Customer.Email == email)).first()
        if existing_customer:
            # If an existing customer is found, return an error message or redirect
            print('Signup failed: username or email already exists')
            return render_template("signup1.html")
        raw_sql_query = text("""
            INSERT INTO customer (Fullname, Username, Email, Password) 
            VALUES (:name, :username, :email, :password);
        """)

        try:
            # Using db.session.execute to run the raw SQL query with named parameters
            db.session.execute(raw_sql_query, {
                'name': name,
                'username': username,
                'email': email,
                'password': password
            })
            db.session.commit()  # Committing the transaction
            print("Signup success")
            return render_template("login1.html")
        except Exception as e:
            db.session.rollback()  # Rolling back in case of error
            print(f"Error: {e}")
            return 'Signup failed due to database error'

    return render_template("signup1.html")


@app.route("/login", methods=['POST', 'GET'])
def login():
    if request.method == "POST":
        username = request.form.get('username')
        password = request.form.get('password')
        customer = Customer.query.filter_by(Username=username).first()

        if customer and customer.Password == password:  
            login_user(customer)
            print("login success", username )
            return redirect(url_for('bookings'))
        else:
            flash("Invalid credentials")
    return render_template('login1.html')

@app.route("/logout")
def logout():
   return render_template("login1.html")


if __name__ == '__main__':
    app.run(debug=True)
