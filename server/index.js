const express = require('express');
const mysql = require('mysql');
const multer = require('multer');
// const request = require('request');

// =========== REQUIREMENTS ===========

const app = express();

app.use(express.urlencoded({ extended: true }));
app.use("public/uploads/", express.static("public/uploads/")); //prolly wrong

app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    res.header("Access-Control-Allow-Methods", 'GET,PUT,POST,DELETE');
    next();
});

const conn = mysql.createPool({
    database: "vacto",
    user: "root",
    password: "",
    host: "localhost"
});

function executeQuery(conn, query) {
    return new Promise((resolve, reject) => {
        conn.query(query, (err,result) => {
            if(err){ reject(err); }
            else{ resolve(result); }
        });
    });
}

function getConnection() {
    return new Promise((resolve, reject)=>{
        conn.getConnection((err, conn)=>{
            if(err){ reject(err); }
            else{ resolve(conn); }
        });
    });
}

const storage = multer.diskStorage({
    destination: (req, file, callback) => {
        callback(null, "public/uploads/"); //prolly wrong
    },
    filename: (req, file, callback) => {
        const filename = file.originalname.split(".");
        const extension = filename[1];

        //TODO: ngganti penamaan file
        callback(null, `${Date.now()}.${extension}`);
    }
});

function checkFileType(file, callback) {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
    if (mimetype && extname) {
        return callback(null, true);
    } else {
        callback('Invalid Format');
    }
}

const uploads = multer({
    storage: storage,
    fileFilter: (req, res, callback) => checkFileType(file, callback)
});

// =========== MAIN CODE AREA ===========

// ------ GET ALL COUNTRIES ------ //
app.get("/api/countries/get/all", async (req, res) => {
    let query = `select name, abv from countries`;
    let getCountries = await executeQuery(conn, query);
    if (getCountries.length > 0) {
        return res.status(200).send(getCountries);
    }
    else{ 
        return res.status(500).send("Something went wrong");
    }
});

// ------ GET A COUNTRY ------ //
app.get("/api/countries/get/:country", async (req, res) => {
    // Icons from https://flagpedia.net
    let country = req.params.country;
    let query = `select name, abv from countries WHERE abv = '${country}'`;
    let getCountry = await executeQuery(conn, query);
    if (getCountry.length > 0) {
        return res.status(200).send(getCountry);
    }
    else {
        return res.status(404).send("Country not found");
    }
});

// ------ USER REGISTER ------ //
app.post("/api/user/register", async (req, res) => {
    let username = req.body.email;
    let password = req.body.password;
    let email = req.body.email;
    let name = req.body.name;
    let dob = req.body.dob; // Format dd-mm-yyyy
    let gender = req.body.gender;

    let pp = "default.png";

    console.log("Data received with following details:", username, password, email, name, dob, gender);

    if (!username || !password || !email || !name || !dob || !gender) return res.status(400).send("One or more field is empty");
    
    // ID = Bulan pembuatan (2) + Tanggal pembuatan (2) + Urutan (3)
    let id;
    let ctr = 1;

    // Get month -> 0 arti e Januari, 11 arti e Desember
    let mm = (new Date().getMonth() < 10) ? `0${new Date().getMonth() + 1}` : `${new Date().getMonth() + 1}`;
    let dd = (new Date().getDate() < 10) ? `0${new Date().getDate()}` : `${new Date().getDate()}`;

    id = `${mm}${dd}`;

    let checkUser = await executeQuery(conn, `select id from user where id LIKE '${id}%'`);
    if (checkUser.length < 1) {
        id = `${mm}${dd}001`;
    }
    else{
        ctr = checkUser.length + 1;

        let pad;
        if (ctr < 10) { pad = "00"; }
        else if(ctr < 100){ pad = "0"; }

        id = `${mm}${dd}${pad}${ctr}`;
    }

    let checkEmail = await executeQuery(conn, `select email from user where email = '${email}'`);
    if(checkEmail.length > 0) return res.status(400).send("Email has already been used");

    let query = `insert into user values('${id}','${username}','${password}','${email}','${name}',STR_TO_DATE('${dob}', "%d-%m-%Y"),'${gender}', '${pp}')`;
    console.log(`Insert user query: ${query}`);
    
    let registerUser = await executeQuery(conn, query);
    if (registerUser["affectedRows"] == 1) return res.status(200).send("User succesfully registered");
});

// ------ USER LOGIN ------ //
app.post("/api/user/login", async (req, res) => {
    let email = req.body.email;
    let password = req.body.password;

    if (!email || !password) return res.status(400).send("One or more required parameters is missing");

    let query = `select id from user where email = '${email}' and password = '${password}'`;
    console.log(query);
    let checkUser = await executeQuery(conn, query);
    if(checkUser.length < 1) return res.status(404).send("User with such credentials doesn't exist");

    return res.status(200).send(checkUser[0]["id"]);
});

app.listen(3000, (req, res) => console.log("Listening on port 3000..."));