const express = require('express');
const mysql = require('mysql');
const multer = require('multer');
const { query } = require('express');
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
    let username = req.body.username;
    let password = req.body.password;
    let email = req.body.email;
    let name = req.body.name;
    let nationality = req.body.nationality;
    let dob = req.body.dob; // Format dd-mm-yyyy
    let gender = req.body.gender;
    let role = req.body.role;

    let pp = "default.png";
    let level = 1;

    console.log("Data received with following details:", username, password, email, name, nationality, dob, gender, role);

    if (!username || !password || !email || !name || !nationality || !dob || !gender || !role) return res.status(400).send("One or more field is empty");
    
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

    let query = `insert into user values('${id}','${username}','${password}','${email}','${name}','${nationality}',STR_TO_DATE('${dob}', "%d-%m-%Y"),'${gender}', '${pp}', ${level}, 0, '${role}')`;
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

// ------ GET USER ------ //
app.get("/api/user/get/:id", async (req, res) => {
    let id = req.params.id;

    if(!id) return res.status(400).send("Id is empty");

    let query = `select  *, DATE_FORMAT(dob, '%d-%m-%Y') as date from user where id = '${id}'`;
    console.log(query);
    let checkUser = await executeQuery(conn, query);
    if(checkUser.length < 1) return res.status(400).send("User with such id doesn't exist");

    return res.status(200).send(checkUser[0]);
});

// ------ ADD NEWS ------ //
app.post("/api/news/add", async (req, res) => {
    // TODO: Gambar
    let id = 0; // AUTO INCREMENT
    let author = (req.body.author) ? req.body.author : "none";
    let title = req.body.title;
    let picture = (req.body.picture) ? req.body.picture : ""; // pic can be null
    let content = req.body.content;
    let source = req.body.source;
    let type = (req.body.type) ? req.body.type : "or";
    let subtype = req.body.subtype;
    let answer = req.body.answer;
    let tags = req.body.tags; // FORMAT: 1,2,3,4,5,6 (cuma dipisah koma)

    if(!author || !title || !content || !source || !type || !subtype || !answer) return res.status(400).send("One of the field is empty");

    let query = `insert into news values(${id},'${author}','${title}', NOW(),'${picture}','${content}','${source}','${type}', '${subtype}','${answer}')`;
    let insertNews = await executeQuery(conn, query);
    console.log(query);
    if (insertNews["affectedRows"] < 1) return res.status(400).send("News insert failed");

    if (tags) {
        let tagsArr = tags.split(",");

        // prolly can cause error
        let query = `select LAST_INSERT_ID() as last`;
        let lastInsertQuery = await executeQuery(conn, query);
        let lastInsertId = lastInsertQuery[0]["last"];

        for (const item in tagsArr) {
            if (Object.hasOwnProperty.call(tagsArr, item)) {
                const element = tagsArr[item];
                query = `insert into news_tag values(0,${lastInsertId},${element})`;
                await executeQuery(conn, query);
            }
        }
    }

    return res.status(200).send("News insert successful");
});

app.get("/api/news/get/:id", async (req, res) => {
    let id = req.params.id;
    let tags = "";

    let query = `select * from news where id=${id}`;
    let getNews = await executeQuery(conn, query);
    if (getNews.length < 1) return res.status(400).send("News retrieval failed");

    query = `select t.tag as tag from tags t, news_tag nt WHERE nt.news = ${id} and nt.tag = t.id`;
    let getTags = await executeQuery(conn, query);
    // if (getTags.length < 1) return res.status(400).send("News retrieval failed");

    for (let i = 0; i < getTags.length; i++) {
        const tag = getTags[i]["tag"];
        if(i < getTags.length - 1) tags += `${tag},`;
        else tags += tag;
    }

    let result = {
        "id": getNews[0]["id"],
        "author": getNews[0]["author"],
        "title": getNews[0]["title"],
        "date": getNews[0]["date"],
        "picture": getNews[0]["picture"],
        "content": getNews[0]["content"],
        "source": getNews[0]["source"],
        "type": getNews[0]["type"],
        "sub_type": getNews[0]["sub_type"],
        "answer": getNews[0]["answer"],
        "tags": tags,
    };

    return res.status(200).send(result);
});

app.get("/api/news/generate/:num", async (req, res) => {
    let num = req.params.num;

    let query = `select id from news order by rand() limit ${num}`;
    let getGeneratedNews = await executeQuery(conn, query);
    if(getGeneratedNews.length < 1) return res.status(400).send("Generate failed");

    return res.status(200).send(getGeneratedNews);
});

app.get("/api/news/tags", async (req, res) => {
    let query = `select * from tags`;
    let getTags = await executeQuery(conn, query);
    if (getTags.length < 1) return res.status(500).send("Tags not found somehow");

    return res.status(200).send(getTags);
});

app.listen(3000, (req, res) => console.log("Listening on port 3000..."));