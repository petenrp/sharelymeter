const app = require("express")();
const PORT = process.env.PORT || 3000

const userIDs = {};
const all = [];

app.get('/userIds', (req, res) => {
    res.json(userIDs).send();
});

app.get('/all', (req, res) => {
    const formattedAllSessions = all.map(a => ({
        ...a,
        socket: a.socket.id,
    }))
    res.json(formattedAllSessions).send();
});

app.get('/clear', (req, res) => {
    const keys = Object.keys(userIds);
    keys.forEach((k) => {
       delete userIDs[k]; 
    });
});

const server = app.listen(PORT, function () {
    console.log(`Listening on port ${PORT}`);
    // console.log(`http://localhost:${PORT}`);
});
const io = require('socket.io')(server);

const CRITERIA = 0.00582776856524;

const findAll = (socket, src, dest) => {
    const other = all.filter(e => e.socket != socket && e.alive);
    other.forEach(e => {
        const eSrc = e.src;
        const eDest = e.dest;
        const distanceSrc = Math.sqrt(Math.pow(eSrc.lat - src.lat, 2) + Math.pow(eSrc.lng - src.lng, 2));
        const distanceDest = Math.sqrt(Math.pow(eDest.lat - dest.lat, 2) + Math.pow(eDest.lng - dest.lng, 2));
        if(distanceSrc <= CRITERIA && distanceDest <= CRITERIA ) {
            e.socket.emit('result', userIDs[socket.id]);
            socket.emit('result', userIDs[e.socket.id]);
        }
    });
};

io.on('connection', (socket) => { 
    console.log('Client Connected');
    socket.on('userID', (userID) => {
        console.log(`User ID: ${userID}`);
        userIDs[socket.id] = userID;
    });
    socket.on('request', ({src, dest}) => {
        const s = all.filter(e => e.socket == socket);
        if(!s.alive) {
            all.push({
                socket,
                dest,
                src,
                alive: true
            });
        } else {
            s.dest = dest;
            s.src = src;
        }
        findAll(socket, src, dest);
    });
    socket.on('disconnect', (reason) => {
        const userID = userIDs[socket.id];
        console.log(`UserID ${userID} disconnected with ` + reason);
        const found = all.find(s => s.socket == socket)
        if(found) {
            found.alive = false;
        }
    });
});