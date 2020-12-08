const app = require("express")();
const axios = require('axios');
const PORT = process.env.PORT || 3000
var http = require('http').createServer(app);
const io = require('socket.io')(http);
const INITIAL_TAXI = 35;
// userIDs
const userIDs = {};
// Google Map API KEY
const API_KEY = 'AIzaSyBQBLsFeXuIePJDQeEMZqAerje-MKqLsTE';
const getBestPath = require('./utils/getBestPath')(API_KEY);

//กำหนดระยะรัศมี อันนี้ 2km.
const CRITERIA =  0.01942589521733;

const STATUS = {
    NO_ONE_ON_TAXI: "no_one_on_taxi",
    ONE_USER_ON_TAXI: "one_user_on_taxi",
    ONE_USER_DOWN_TAXI: "one_user_down_taxi",
    TWO_USER_ON_TAXI: "two_user_on_taxi",
    TWO_USER_DOWN_TAXI: "two_user_down_taxi",
};

const findBestPartner = (user) => {
    const { src, dest } = user;
    // other users
    const other = Object.keys(userIDs)
        .filter(id => id != user.info.id)
        .map(k => userIDs[k])
        .filter(u => u.socket.connected && u.match == null);

    for ( const e of other ) {
        const eSrc = e.src;
        const eDest = e.dest;
        const distanceSrc = Math.sqrt(Math.pow(eSrc.lat - src.lat, 2) + Math.pow(eSrc.lng - src.lng, 2));
        const distanceDest = Math.sqrt(Math.pow(eDest.lat - dest.lat, 2) + Math.pow(eDest.lng - dest.lng, 2));

        if(distanceSrc <= CRITERIA && distanceDest <= CRITERIA ) {
            return e;
        }
    }
    return null;
};

const formatSocket = (socket) => ({
    id: socket.id,
    connected: socket.connected,
});

app.get('/userIds', (req, res) => {
    const keys = Object.keys(userIDs);
    let result = {};
    keys.forEach(k => {
        const { socket, ...x } = userIDs[k];
        result[k] = {
            socket: formatSocket(socket),
            ...x
        };
    })
    res.json(result);
});

const pendingForMatch = async (user1, user2) => {
    const route = await getBestPath([user1, user2]);
    const match = {
        pending: true,
        users: [
            {
                user: user1,
                confirm: false,
                decline: false,
            },
            {
                user: user2,
                confirm: false,
                decline: false,
            },
        ],
        route,
    };
    user1.match = match;
    user2.match = match;

    user1.socket.emit('result', JSON.stringify({
        partner: user2.info.name + ' | ' + user2.info.tel,
        callTaxi: route.left,
        distance: route.distance,
        path: route.path,
        estimatedPrice: route.estimatedPrice + ' baht',
        points: route.path.map(p => p.name),
    }));

    user2.socket.emit('result', JSON.stringify({
        partner: user1.info.name + ' | ' + user1.info.tel,
        callTaxi: !route.left,
        distance: route.distance,
        path: route.path,
        estimatedPrice: route.estimatedPrice + ' baht',
        points: route.path.map(p => p.name),
    }));
};

const calculatePriceFromMatch = (match) => {
    const [x, y, z] = match.taxiValues;
    const [a, b, c] = match.taxiUsers;
    const p = x/2 + (y-x) + (z-y)/2;
    const q = x/2 + (z-y)/2;

    const anotherUser = getAnotherUser(c);

    return [
        {
            user: c,
            taxi: c == a ? p: q,
            pay: true,
        },
        {
            user: anotherUser,
            taxi: anotherUser == a? p: q,
            pay: false,
        }
    ];
};

const updateStatus = (match, status, x) => {
    let taxi = null;
    let user = null;
    if(x) {
        taxi = x.taxi;
        user = x.user;
    }
    if(match.status == null && status == STATUS.NO_ONE_ON_TAXI) {
        match.status = status;
        match.taxiUsers = [];
        match.taxiValues = [];
        match.users.forEach(u => {
            u.user.socket.emit('status', {
                status: match.status
            });
        });
    } else if (match.status == STATUS.NO_ONE_ON_TAXI && status == STATUS.ONE_USER_ON_TAXI) {
        match.status = status;
        match.taxiUsers.push(user);
        match.taxiValues.push(INITIAL_TAXI);
        match.users.forEach(u => {
            u.user.socket.emit('status', {
                status: match.status,
                taxi: 35,
                isYou: u.user == user,
            });
        });
    } else if ( (match.status == STATUS.ONE_USER_ON_TAXI && status == STATUS.TWO_USER_ON_TAXI) 
    || ( match.status == STATUS.TWO_USER_ON_TAXI && status == STATUS.ONE_USER_DOWN_TAXI )) {
        match.status = status;
        match.taxiUsers.push(user);
        match.taxiValues.push(taxi);
        match.users.forEach(u => {
            u.user.socket.emit('status', {
                status: match.status,
                taxi,
                isYou: u.user == user,
            });
        });

        if(status == STATUS.ONE_USER_DOWN_TAXI) {
            console.log(`Calculate for the price:`);
            const result = calculatePriceFromMatch(match);
            console.log(result.map(r => ({
                name: r.user.info.name,
                taxi: r.taxi,
                pay: r.pay,
            })));
            result.forEach(r => {
                r.user.socket.emit('done', JSON.stringify({
                    taxi: r.taxi,
                    pay: r.pay,
                }));
                r.user.socket.disconnect();
                delete userIDs[r.user.info.id];
            });
        }
    }
    console.log(`Status: ${match.status}, user: ${user != null ? user.info.name: null}, taxi: ${taxi}`);
}

const confirmMatching = (user) => {
    const match = user.match;
    if(match == null || !match.pending) return;
    match.users.forEach(u => {
        if(u.user == user) {
            u.confirm = true;
        }
    });
    const confirmed = match.users.filter(u => u.confirm)
    if(confirmed.length == 2) {
        console.log(`Both users confirmed`);
        match.pending = false;
        match.traveling = true;

        updateStatus(match, STATUS.NO_ONE_ON_TAXI);
    }
};

const cancelMatching = (user) => {
    const match = user.match;
    // if(match == null || !match.pending) return;
    match.users.forEach(u => {
        if(u.user.match == match) {
            u.user.match = null;
            u.user.socket.emit('cancel', '');
        }
    });

    console.log(`Matching between ${match.users[0].user.info.name} and ${match.users[1].user.info.name} has been canceled`)
};

const getAnotherUser = (user) => {
    const match = user.match;
    if(match == null) return null;
    for(const u of match.users) {
        if(u.user != user) return u.user;
    }
    return null;
};

const getUserFromSocket = (socket) => {
    const keys = Object.keys(userIDs);

    for(const k of keys) {
        if(userIDs[k].socket == socket) return userIDs[k];
    }
    return null;
};

io.on('connection', (socket) => { 
    console.log('Client Connected');
    const id = socket.id;

    // socket.emit('result', 'hello');

    socket.on('user', (message) => {
        const user = JSON.parse(message);
        if(userIDs[user.id] == null) {
            userIDs[user.id] = { socket, info: user };
        } else {
            userIDs[user.id].socket = socket;
        }
        console.log(`Socket ID: ${id}`);
        console.log(`User ID:\t${user.id}`);
        console.log(`User Tel:\t${user.tel}`);
    });

    socket.on('request', ({src, dest}) => {
        const user = getUserFromSocket(socket);
        if(user != null) {
            user.src = src;
            user.dest = dest;
        }
        const partner = findBestPartner(user);
        if(partner != null) {
            pendingForMatch(user, partner);
        }
    });

    socket.on('disconnect', (reason) => {
        console.log(`${id} is disconnecting because ${reason}`);
        const user = getUserFromSocket(socket);
        cancelMatching(user);
    });

    socket.on('confirm', () => {
        const user = getUserFromSocket(socket);
        console.log(`User ${user.info.name} confirmed`);
        confirmMatching(user);
    });

    socket.on('decline', () => {
        const user = getUserFromSocket(socket);
        console.log(`User ${user.info.name} declined`);
        cancelMatching(user);
    });

    socket.on('getInOut', (e) => {
        const message = JSON.parse(e);
        const user = getUserFromSocket(socket);
        if(user.match != null) {
            if(user.match.status == STATUS.NO_ONE_ON_TAXI) {
                updateStatus(user.match, STATUS.ONE_USER_ON_TAXI, { user });
            } else if (user.match.status == STATUS.ONE_USER_ON_TAXI
                || user.match.status == STATUS.TWO_USER_ON_TAXI
                || user.match.status == STATUS.ONE_USER_DOWN_TAXI){
                if(user.match.taxi == null) {
                    console.log(`user ${user.info.name} taxi ${message.taxi}`);
                    user.match.taxi = {
                        value: message.taxi,
                        user: user,
                    };
                    const anotherUser = getAnotherUser(user);
                    anotherUser.socket.emit('confirm_metre', {
                        taxi: message.taxi,
                    });
                }
                // updateStatus(user.match, STATUS.TWO_USER_ON_TAXI, { user, taxi: message.taxi });
                // updateStatus(user.match, STATUS.TWO_USER_ON_TAXI, { user, taxi });
            }
        } 
    });

    socket.on('taxi', (e) => {
        const message = JSON.parse(e);
        const user = getUserFromSocket(socket);
        console.log(`user ${user.info.name} confirm: ${message.confirm}`);
        if (user.match.status == STATUS.ONE_USER_ON_TAXI
            || user.match.status == STATUS.TWO_USER_ON_TAXI
            || user.match.status == STATUS.ONE_USER_DOWN_TAXI){
            const taxiUser = user.match.taxi.user;
            const anotherUser = getAnotherUser(user.match.taxi.user);
            if(user.match.taxi != null && user == anotherUser) {
                if (message.confirm) {
                    if(user.match.status == STATUS.ONE_USER_ON_TAXI) {
                        updateStatus(user.match, STATUS.TWO_USER_ON_TAXI, { user: taxiUser, taxi: user.match.taxi.value });
                    } else if(user.match.status == STATUS.TWO_USER_ON_TAXI) {
                        updateStatus(user.match, STATUS.ONE_USER_DOWN_TAXI, { user: taxiUser, taxi: user.match.taxi.value });
                    }
                    user.match.taxi = null;
                } else {
                    user.match.taxi = null;
                    taxiUser.socket.emit('re_enter_taxi', JSON.stringify({
                        message: `${taxiUser.info.name} decline taxi metre`
                    }));
                }
            }
        }
    });
});

http.listen(PORT, () => {
    console.log(`Listening on port ${PORT}`);
});