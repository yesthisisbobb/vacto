const express = require('express');
const mysql = require('mysql');
const multer = require('multer');
const { query, response } = require('express');
const e = require('express');
const path = require('path');
// const request = require('request');

// =========== REQUIREMENTS ===========

const app = express();

app.use(express.urlencoded({ extended: true }));
app.use("public/uploads/", express.static("public/uploads/")); //prolly wrong

// Buat ngambil gambar
app.use("/static", express.static('public'));
app.use('/images/news', express.static(path.join(__dirname, 'public', 'uploads', 'news_img')));
app.use('/images/profile', express.static(path.join(__dirname, 'public', 'uploads', 'pp_img')));

// CONTOH CARA NGAMBIL GAMBAR: http://127.0.0.1:3001/images/news/pp1.png

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

const newsstorage = multer.diskStorage({
    destination: (req, file, callback) => {
        callback(null, "public/uploads/news_img");
    },
    filename: (req, file, callback) => {
        const filename = file.originalname.split(".");
        const extension = filename[filename.length - 1];

        // ngganti penamaan file
        callback(null, `${Date.now()}.${extension}`);
    }
});
const ppstorage = multer.diskStorage({
    destination: (req, file, callback) => {
        callback(null, "public/uploads/pp_img");
    },
    filename: (req, file, callback) => {
        const filename = file.originalname.split(".");
        const extension = filename[filename.length - 1];

        // ngganti penamaan file
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

const newsuploads = multer({
    storage: newsstorage,
    // fileFilter: (req, res, callback) => checkFileType(file, callback)
});
const ppuploads = multer({
    storage: ppstorage,
    // fileFilter: (req, res, callback) => checkFileType(file, callback)
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

let feedSelects = `select f.*, u.username, a.name as achievement`;
let feedFroms = `FROM feed f INNER JOIN user u ON f.user = u.id LEFT JOIN achievement a ON f.achievement = a.id`;
// ------ GET FEEDS GLOBAL ------ //
app.get("/api/feed/get/global/", async (req, res) => {
    let query = `${feedSelects} ${feedFroms} order by f.date DESC LIMIT 30`;
    let getFeed = await executeQuery(conn, query);
    if(getFeed.length < 1) return res.status(400).send("Failed getting feed");

    return res.status(200).send(getFeed);
});

// ------ GET FEEDS LOCAL ------ //
app.get("/api/feed/get/local/:nat", async (req, res) => {
    let nat = req.params.nat; // global/local
    let query = `${feedSelects} ${feedFroms} and u.nationality = '${nat}' order by f.date DESC LIMIT 30`;
    let getFeed = await executeQuery(conn, query);
    if (getFeed.length < 1) return res.status(400).send("Failed getting feed");

    return res.status(200).send(getFeed);
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
    let pp = "default.png";
    let level = 1;
    // rating (MMR)
    let role = req.body.role;
    // sgp (Standard Games Played)
    // tgp (Timed Games Played)
    // tstg (Times Spent on Timed Gamemode)
    // cgp (Challenge Games Played)
    // cw (Challenge Won)
    // ca (Correct Answers)
    // tqf (Total Questions Faced)
    // na (News Added)

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

    let query = `insert into user values('${id}','${username}','${password}','${email}','${name}','${nationality}',STR_TO_DATE('${dob}', "%d-%m-%Y"),'${gender}', '${pp}', ${level}, 0, '${role}', 0, 0, 0, 0, 0, 0, 0, 0)`;
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

// ------ GET ACHIEVEMENT USER ------ //
app.get("/api/user/achievement/get/:id", async (req, res) => {
    let id = req.params.id;

    if(!id) return res.status(400).send("Id is missing");

    let query = `select * from user_achievement where user='${id}'`;
    let getAchievements = await executeQuery(conn, query);
    
    return res.status(200).send(getAchievements);
});

// ------ ADD ACHIEVEMENT USER ------ //
app.post("/api/user/achievement/add", async (req, res) => {
    let uid = req.body.uid;
    let aid = req.body.aid;

    if (!uid || !aid) return res.status(400).send("One of the field is missing");

    aid = parseInt(aid);

    let query = `insert into user_achievement values(0,'${uid}',${aid},NOW())`
    let insertAchievement = await executeQuery(conn, query);
    if(insertAchievement["affectedRows"] < 1) return res.status(400).send("Insert achievement failed");

    query = `insert into feed values(0,NOW(),'achievement','${uid}','',${aid})`;
    let insertFeed = await executeQuery(conn, query);
    if (insertFeed["affectedRows"] < 1) return res.status(400).send("Insert feed failed");

    return res.status(200).send("Insert successful");
});

// ------ POST GAME UPDATE USER ------ //
app.post("/api/user/update/stats", async (req, res) => {
    // user id
    let id = req.body.id;
    // gamemode (s standard / t timed / c challenge)
    let gamemode = req.body.gamemode;
    // level -> cuma + 1
    // Tier 1 100+ || Tier 2 200+ || Tier 3 400+ || Tier 4 800+ || Tier 5  1600+ || Tier 6 3200+ || Tier 7 6400+
    let level;
    // rating (MMR)
    let rating = parseInt(req.body.rating);
    // sgp (Standard Games Played) -> cuma + 1
    let sgp;
    // tgp (Timed Games Played) -> cuma + 1
    let tgp;
    // tstg (Times Spent on Timed Gamemode)
    let tstg = parseInt(req.body.tstg);
    // cgp (Challenge Games Played) -> cuma + 1
    let cgp;
    // ca (Correct Answers)
    let ca = parseInt(req.body.ca);
    // tqf (Total Questions Faced)
    let tqf = parseInt(req.body.tqf);

    let query = `select rating, sgp, tgp, tstg, cgp, ca, tqf from user where id='${id}'`;
    let getUser = await executeQuery(conn, query);
    if(getUser.length < 1) return res.status(404).send("User not found");

    level = 1;
    if (rating + parseInt(getUser[0]["rating"]) > 199) {
        level = 2;
    } if (rating + parseInt(getUser[0]["rating"]) > 399){
        level = 3;
    } if (rating + parseInt(getUser[0]["rating"]) > 799) {
        level = 4;
    } if (rating + parseInt(getUser[0]["rating"]) > 1599) {
        level = 5;
    } if (rating + parseInt(getUser[0]["rating"]) > 3199) {
        level = 6;
    } if (rating + parseInt(getUser[0]["rating"]) > 6399) {
        level = 7;
    }
    rating += parseInt(getUser[0]["rating"]);
    if(gamemode == "s") sgp = parseInt(getUser[0]["sgp"]) + 1;
    else sgp = parseInt(getUser[0]["sgp"]);
    if(gamemode == "t") tgp = parseInt(getUser[0]["tgp"]) + 1;
    else tgp = parseInt(getUser[0]["tgp"]);
    tstg += parseInt(getUser[0]["tstg"]);
    if (gamemode == "c") cgp = parseInt(getUser[0]["cgp"]) + 1;
    else cgp = parseInt(getUser[0]["cgp"]);
    ca += parseInt(getUser[0]["ca"]);
    tqf += parseInt(getUser[0]["tqf"]);

    query = `update user set level=${level}, rating=${rating}, sgp=${sgp}, tgp=${tgp}, tstg=${tstg}, cgp=${cgp}, ca=${ca}, tqf=${tqf} where id='${id}'`;
    console.log(query);
    let updateUser = await executeQuery(conn, query);
    if(updateUser["affectedRows"] < 1) return res.status(400).send("Update failed");

    return res.status(200).send("Update successful");
});

// ------ POST GAME UPDATE USER ------ //
app.post("/api/user/update/stats/na", async (req, res) => {
    let uid = req.body.uid;
    let na = 0;

    if(!uid) return res.status(400).send("No id given");
    
    let query = `select na from user where id='${uid}'`;
    let getNa = await executeQuery(conn, query);
    if (getNa.length < 1) return res.status(400).send("NA not found");

    na = parseInt(getNa[0]["na"]);
    na++;

    query = `update user set na=${na} where id='${uid}'`;
    let updateNa = await executeQuery(conn,query);
    if (updateNa["affectedRows"] < 1) return res.status(400).send("NA update error");

    return res.status(200).send("NA update successful");
});

// ------ GET USERS ------ //
// Not to be confused with get 'user', which only fetches a singular data
app.get("/api/users/get/:num", async (req, res) => {
    let num = req.params.num;

    let query = `select id from user order by rand() limit ${num}`;
    let getUsers = await executeQuery(conn, query);
    if(getUsers.length < 1) return res.status(400).send("Failed to get users");

    return res.status(200).send(getUsers);
});

// ------ GET USERS SORTED ------ //
// Not to be confused with get 'user', which only fetches a singular data
app.get("/api/users/get/sorted/:num", async (req, res) => {
    let num = req.params.num;

    let query = `select id from user order by rating DESC limit ${num}`;
    let getUsers = await executeQuery(conn, query);
    if (getUsers.length < 1) return res.status(400).send("Failed to get users");

    return res.status(200).send(getUsers);
});

// TETSING MUST DELET LATER
app.post("/api/news/uploadimage", newsuploads.single('picture'), async (req, res) => {
    let picture = req.file;

    console.log(req);
    console.log(picture);

    return res.status(200).send(picture);

    // { Yang dikembalikan picture
    // fieldname: 'picture',
    // originalname: '47dd4551ce492ebdeae23c0faaeca164.jpg',
    // encoding: '7bit',
    // mimetype: 'image/jpeg',
    // destination: 'public/uploads/',
    // filename: '1637388493211.jpg',
    // path: 'public\\uploads\\1637388493211.jpg',
    // size: 0
    // }
});

// ------ ADD NEWS ------ //
app.post("/api/news/add", newsuploads.single('picture'), async (req, res) => {
    // TODO: Gambar & status news udah di verify atau belom
    let id = 0; // AUTO INCREMENT
    let author = (req.body.author) ? req.body.author : "none";
    let title = req.body.title;
    let picture = (req.file) ? req.file.filename : ""; // pic can be null
    let content = req.body.content;
    let source = req.body.source;
    let type = (req.body.type) ? req.body.type : "or";
    let subtype = req.body.subtype;
    let answer = req.body.answer;
    let tags = req.body.tags; // FORMAT: 1,2,3,4,5,6 (cuma dipisah koma)

    if(!author || !title || !content || !source || !type || !subtype || !answer) return res.status(400).send("One of the field is empty");

    let query = `insert into news values(${id},'${author}','${title}', NOW(),'${picture}','${content}','${source}','${type}', '${subtype}','${answer}','n')`;
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

// ------ GET NEWS ------ //
app.get("/api/news/get/:id", async (req, res) => {
    let id = req.params.id;
    let tags = "";
    let references = "";

    let query = `select * from news where id=${id}`;
    let getNews = await executeQuery(conn, query);
    if (getNews.length < 1) return res.status(400).send("News retrieval failed");

    query = `select t.tag as tag from tags t, news_tag nt WHERE nt.news = ${id} and nt.tag = t.id`;
    let getTags = await executeQuery(conn, query);
    // if (getTags.length < 1) return res.status(400).send("Tags retrieval failed");

    query = `select nr.reference as 'references' from news n, news_reference nr WHERE n.id = ${id} and nr.news = n.id`;
    let getReferences = await executeQuery(conn, query);
    // if (getReferences.length < 1) return res.status(400).send("References retrieval failed");

    for (let i = 0; i < getTags.length; i++) {
        const tag = getTags[i]["tag"];
        if(i < getTags.length - 1) tags += `${tag},`;
        else tags += tag;
    }

    for (let i = 0; i < getReferences.length; i++) {
        const ref = getReferences[i]["references"];
        if (i < getReferences.length - 1) references += `${ref},`;
        else references += ref;
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
        "references": references
    };

    return res.status(200).send(result);
});

// ------ GET ALL USER CREATED NEWS ------ //
app.get("/api/news/get/all/by/:uid", async (req,res) => {
    let uid = req.params.uid;

    if(!uid) return res.status(400).send("No id given");

    let query = `select id from news where author = '${uid}'`;
    let getNews = await executeQuery(conn, query);
    if(getNews.length < 1) return res.status(400).send("Get news failed");

    return res.status(200).send(getNews);
});

// ------ GENERATE NEWS ------ //
app.get("/api/news/generate/:num", async (req, res) => {
    // TODO: masukno soal bonus & ngefilter news yang 'or' soale 'uc' itu soal bonus
    let num = req.params.num;

    let query = `select id from news order by rand() limit ${num}`;
    let getGeneratedNews = await executeQuery(conn, query);
    if(getGeneratedNews.length < 1) return res.status(400).send("Generate failed");

    return res.status(200).send(getGeneratedNews);
});

// ------ GET NEWS TAGS ------ //
app.get("/api/news/tags", async (req, res) => {
    let query = `select * from tags`;
    let getTags = await executeQuery(conn, query);
    if (getTags.length < 1) return res.status(500).send("Tags not found somehow");

    return res.status(200).send(getTags);
});

// ------ ADD CHALLENGE ------ //
app.post("/api/challenge/add", async (req, res) => {
    let questions = req.body.questions;
    let user1 = req.body.user1;
    let user2 = req.body.user2;
    // user1_completed
    // user2_completed
    let user1ca = req.body.user1ca;
    // user2_ca

    if (!questions || !user1 || !user2 || !user1ca) return res.status(400).send("One or more field is missing");

    console.log(questions);
    console.log(user1);
    console.log(user2);
    console.log(user1ca);

    let query = `insert into challenge values(0, CURRENT_TIMESTAMP(), '${questions}', '${user1}', '${user2}', 'y', 'n', ${user1ca}, 0)`;
    console.log(query);
    let addChallenge = await executeQuery(conn, query);
    if(addChallenge["affectedRows"] < 1) return res.status(400).send("Challenge creation failed");

    return res.status(200).send("Challenge created");
});

// ------ GET CHALLENGE ------ //
app.get("/api/challenge/get/:id", async (req, res) => {
    let id = req.params.id;

    if(!id) return res.status(400).send("One of the field is empty");

    id = parseInt(id);

    let query = `select c.*, u.username as challenger from challenge c, user u where c.id=${id} and c.user1 = u.id`;
    let getChallenge = await executeQuery(conn, query);
    if(getChallenge.length < 1) return res.status(400).send("Challenge fetch failed");

    return res.status(200).send(getChallenge[0]);
});

// ------ GET CHALLENGES BY A USER ------ //
app.get("/api/challenge/get/by/:userid", async (req, res) => {
    let userid = req.params.userid;

    if (!userid) return res.status(400).send("One of the field is empty");

    // TODO: dont think challenger is needed here
    let query = `select c.*, u.username as challenger from challenge c, user u where user1='${userid}' and c.user1 = u.id`;
    console.log(query);
    let getChallenges = await executeQuery(conn, query);
    if (getChallenges.length < 1) return res.status(400).send("Challenges fetch failed");

    return res.status(200).send(getChallenges);
});

// ------ GET CHALLENGES FOR A USER ------ //
app.get("/api/challenge/get/for/:userid", async (req, res) => {
    let userid = req.params.userid;

    if (!userid) return res.status(400).send("One of the field is empty");

    // TODO: dont think challenger is needed here
    let query = `select c.*, u.username as challenger from challenge c, user u where user2='${userid}' and c.user1 = u.id`;
    console.log(query);
    let getChallenges = await executeQuery(conn, query);
    if (getChallenges.length < 1) return res.status(400).send("Challenges fetch failed");

    return res.status(200).send(getChallenges);
});

// ------ UPDATE CHALLENGE ------ //
app.post("/api/challenge/update", async (req, res) => {
    let id = req.body.id;
    // user2_completed
    let user2ca = req.body.user2ca

    let score = req.body.score;
    let winner = req.body.winner;
    let loser = req.body.loser;
    let challengestatus = req.body.challengestatus;

    if (!id || !user2ca || !score || !winner || !loser) return res.status(400).send("One of the field is empty");

    id = parseInt(id);
    user2ca = parseInt(user2ca);
    score = parseInt(score);

    let query = `update challenge set user2_completed = 'y', user2_ca=${user2ca} where id=${id}`;
    let updateChallenge = await executeQuery(conn, query);
    if (updateChallenge["affectedRows"] < 1) return res.status(400).send("Challenge update failed");

    if(challengestatus != "draw"){
        let rating, cw;
        query = `select rating, cw from user where id='${winner}'`;
        let getWinner = await executeQuery(conn, query);
        if (getWinner.length < 1) return res.status(400).send("Get winner failed");

        rating = parseInt(getWinner[0]["rating"]) + score;
        cw = parseInt(getWinner[0]["cw"]) + 1;
        query = `update user set rating=${rating}, cw=${cw} where id='${winner}'`;
        let updateWinner = await executeQuery(conn, query);
        if (updateWinner["affectedRows"] < 1) return res.status(400).send("Winner update failed");

        query = `select rating from user where id='${loser}'`;
        let getLoser = await executeQuery(conn, query);
        if (getLoser.length < 1) return res.status(400).send("Get loser failed");

        rating = parseInt(getLoser[0]["rating"]) - score;
        query = `update user set rating=${rating} where id='${loser}'`;
        let updateLoser = await executeQuery(conn, query);
        if (updateLoser["affectedRows"] < 1) return res.status(400).send("Loser update failed");
    }

    // ngambil username lawan
    if(challengestatus === "win"){
        let query = `select username from user where id='${loser}'`;
        let getOpponent = await executeQuery(conn, query);
        if(getOpponent.length < 1) return res.status(400).send("Opponent not found");

        query = `insert into feed values(0,NOW(),'challenge_w','${winner}','${getOpponent[0]["username"]}',0)`;
        let insertFeed = await executeQuery(conn, query);
        if(insertFeed["affectedRows"] < 1) return res.status(400).send("Feed insert failed");
    }
    else if(challengestatus === "lose"){
        let query = `select username from user where id='${winner}'`;
        let getOpponent = await executeQuery(conn, query);
        if (getOpponent.length < 1) return res.status(400).send("Opponent not found");

        query = `insert into feed values(0,NOW(),'challenge_l','${loser}','${getOpponent[0]["username"]}',0)`;
        let insertFeed = await executeQuery(conn, query);
        if (insertFeed["affectedRows"] < 1) return res.status(400).send("Feed insert failed");
    }
    else{
        let query = `select username from user where id='${loser}'`;
        let getOpponent = await executeQuery(conn, query);
        if (getOpponent.length < 1) return res.status(400).send("Opponent not found");

        query = `insert into feed values(0,NOW(),'challenge_d','${winner}','${getOpponent[0]["username"]}',0)`;
        let insertFeed = await executeQuery(conn, query);
        if (insertFeed["affectedRows"] < 1) return res.status(400).send("Feed insert failed");
    }

    return res.status(200).send("Challenge update successful");
});

// ------ UPLOAD ANSWER ------ //
app.post("/api/answer/upload", async (req, res) => {
    let user = req.body.user;
    let news = req.body.news;
    let answer = req.body.answer;
    let score = req.body.score;
    let reasoning = req.body.reasoning; // bisa kosong

    if(!user || !news || !answer || !score) return res.status(400).send("One of the field is empty!");

    news = parseInt(req.body.news);
    score = parseInt(req.body.score);
    
    let query = `insert into user_answer values(0, '${user}', ${news}, CURRENT_TIMESTAMP(), '${answer}', ${score}, '${reasoning}')`;
    let insertAnswer = await executeQuery(conn, query);
    if(insertAnswer["affectedRows"] < 1) return res.status(400).send("Insert failed");

    return res.status(200).send("Insert successful");
});

// GET FORMATTED ANSWER
app.get("/api/answer/get/formatted/:id", async (req, res) => {
    let id = req.params.id;

    if(!id) return res.status(400).send("Param is empty");

    // PASTIKAN SAMA MBEK SG BAWAH
    let query = `select ua.id as "Answer id", ua.date_answered as "Answer Date", n.title as "News Title", ua.answer as "User Answer", n.answer as "Actual Answer", ua.score as "Resulting Score", ua.reasoning as "Reasoning", u.name as "Name", u.nationality as "Nationality", u.dob as "Date of Birth" from user u, user_answer ua, news n where ua.id=${id} and ua.user = u.id and ua.news = n.id`;
    let getAnswer = await executeQuery(conn, query);
    if (getAnswer.length < 1) return res.status(500).send("Answer retrieval failed");

    return res.status(200).send(getAnswer[0]);
});

// GET ALL ANSWERS
app.get("/api/answer/get/formatted/all", async (req, res) => {
    let query = `select ua.id as "Answer id", ua.date_answered as "Answer Date", n.title as "News Title", ua.answer as "User Answer", n.answer as "Actual Answer", ua.score as "Resulting Score", ua.reasoning as "Reasoning", u.name as "Name", u.nationality as "Nationality", u.dob as "Date of Birth" from user u, user_answer ua, news n where ua.user = u.id and ua.news = n.id`;
    let getAllAnswers = await executeQuery(conn, query);
    if (getAllAnswers.length < 1) return res.status(500).send("Answers retrieval failed");

    return res.status(200).send(getAllAnswers);
});

// GET ALL ANSWERS FOR A USER
app.get("/api/answer/get/formatted/all/:uid", async (req, res) => {
    let uid = req.params.uid;

    if(!uid) return res.status(400).send("No id given");

    let query = `select ua.id as "Answer id", ua.date_answered as "Answer Date", n.title as "News Title", ua.answer as "User Answer", n.answer as "Actual Answer", ua.score as "Resulting Score", ua.reasoning as "Reasoning", u.name as "Name", u.nationality as "Nationality", u.dob as "Date of Birth" from user u, user_answer ua, news n where ua.user = '${uid}' and ua.user = u.id and ua.news = n.id`;
    let getAllAnswers = await executeQuery(conn, query);
    if (getAllAnswers.length < 1) return res.status(500).send("Answers retrieval failed");

    return res.status(200).send(getAllAnswers);
});

// GET ALL ANSWERS FOR A NEWS
app.get("/api/answer/get/formatted/all/news/:nid", async (req, res) => {
    let nid = req.params.nid;

    if (!nid) return res.status(400).send("No id given");

    let query = `select ua.id as "Answer id", ua.date_answered as "Answer Date", n.title as "News Title", ua.answer as "User Answer", n.answer as "Actual Answer", ua.score as "Resulting Score", ua.reasoning as "Reasoning", u.username as "Username", u.name as "Name", u.nationality as "Nationality", u.dob as "Date of Birth" from user u, user_answer ua, news n where ua.news = '${nid}' and ua.user = u.id and ua.news = n.id`;
    let getAllAnswers = await executeQuery(conn, query);
    if (getAllAnswers.length < 1) return res.status(500).send("Answers retrieval failed");

    return res.status(200).send(getAllAnswers);
});

app.listen(3000, (req, res) => console.log("Listening on port 3000..."));