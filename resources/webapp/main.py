from flask import Flask, session

from flask_session import Session
 
app = Flask(__name__)
app.config.update(
    DEBUG = True,
    SESSION_TYPE = "filesystem",
    PERMANENT_SESSION_LIFETIME = 10,
)
Session(app)

@app.route("/")
def index():
    session.permanent = True
    session["name"] = "my_session_2"
    return "Congratulations, it's a web app BBB!"
