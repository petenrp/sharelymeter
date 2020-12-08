const app = require("express")();
const axios = require('axios');
const PORT = process.env.PORT || 3000

const userIDs = {};
const all = [];
// Google Map API KEY
const API_KEY = 'AIzaSyBQBLsFeXuIePJDQeEMZqAerje-MKqLsTE';

const CRITERIA =  0.01942589521733;

// app.get('/publish', (req, res) => {
//     try {
//         const { topic, body, socketId } = req.query;
//         const found = all.find(s => s.socket.id == socketId);
//         if(found) {
//             found.socket.emit(topic, body);
//             res.json({
//                 message: 'Message Sent'
//             })
//         } else {
//             res.json({
//                 message: 'Socket Not Found'
//             })
//         }
//     } catch (e) {
//         res.json({
//             message: `Boom: ${e.message}`
//         })
//     }
// });

// const findAll = (socket, src, dest) => {
//     const other = all.filter(e => e.socket != socket && e.alive);
//     for ( const e of other ) {
//         const eSrc = e.src;
//         const eDest = e.dest;
//         const distanceSrc = Math.sqrt(Math.pow(eSrc.lat - src.lat, 2) + Math.pow(eSrc.lng - src.lng, 2));
//         const distanceDest = Math.sqrt(Math.pow(eDest.lat - dest.lat, 2) + Math.pow(eDest.lng - dest.lng, 2));

//         if(distanceSrc <= CRITERIA && distanceDest <= CRITERIA ) {
//             // e.socket.emit('result', userIDs[socket.id]);
//             // socket.emit('result', userIDs[e.socket.id]);
//             return [
//                 {
//                     src, dest
//                 },
//                 {
//                     src: eSrc,
//                     dest: eDest
//                 }
//             ];
//         }
//     }
//     return null;
// };

const getBestPath = async (req) => {
    const [user1, user2] = req;
        
    const path_1 = [user1.src, user2.src, user1.dest, user2.dest];
    const response_1 = await callGoogleApi(path_1, API_KEY);
    const distance_1 = response_1.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

    const path_2 = [user1.src, user2.src, user2.dest, user1.dest];
    const response_2 = await callGoogleApi(path_2, API_KEY);
    const distance_2 = response_2.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

    const path_3 = [user2.src, user1.src, user1.dest, user2.dest];
    const response_3 = await callGoogleApi(path_3, API_KEY);
    const distance_3 = response_3.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

    const path_4 = [user2.src, user1.src, user2.dest, user1.dest];
    const response_4 = await callGoogleApi(path_4, API_KEY);
    const distance_4 = response_4.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

    const allPossibility = [
        {
            left: true,
            distance: distance_1,
            path: path_1,
            estimatedPrice: getPriceFromDistance(distance_1 / 1000),
        },
        {
            left: true,
            distance: distance_2,
            path: path_2,
            estimatedPrice: getPriceFromDistance(distance_2 / 1000),
        },
        {
            left: false,
            distance: distance_3,
            path: path_3,
            estimatedPrice: getPriceFromDistance(distance_3 / 1000),
        },
        {
            left: false,
            distance: distance_4,
            path: path_4,
            estimatedPrice: getPriceFromDistance(distance_4 / 1000),
        },
    ].sort((a, b) => {
        return a.distance - b.distance;
    });

    return allPossibility.length > 0 ? allPossibility[0]: null;
    // return allPossibility;
}

app.get('/userIds', (req, res) => {
    res.json(userIDs);
});

// app.get('/price/:distance', (req, res) => {
//     const price = getPriceFromDistance(req.params.distance);
//     res.json({
//         price
//     });
// });

// app.get('/possible_match/:src/:dst', async (req, res) => {
//     const { src, dst } = req.params;
//     const [, latSrc, lngSrc] = src.match(/([^,]+),([^,]+)/)
//     const [, latDst, lngDst] = dst.match(/([^,]+),([^,]+)/)
    
//     const result = findAll('', {
//         lat: parseFloat(latSrc),
//         lng: parseFloat(lngSrc),
//     }, {
//         lat: parseFloat(latDst),
//         lng: parseFloat(lngDst),
//     });

//     if (result) {
//         const bestPath = await getBestPath(result);
//         bestPath.points = [
//             'KMUTT',
//             'The Cube',
//             'Cen 2',
//             'Green night market',
//         ];
//         res.json(result);
//     } else {
//         res.json({
//             message: 'cannot find any nearby partner'
//         });
//     }
// });

// app.get('/all', (req, res) => {
//     const formattedAllSessions = all.map(a => ({
//         ...a,
//         socket: a.socket.id,
//     }))
//     res.json(formattedAllSessions);
// });

// app.get('/clear', (req, res) => {
//     all.forEach((e) => {
//         all.pop(); 
//     });
// });

const server = app.listen(PORT, function () {
    console.log(`Listening on port ${PORT}`);
    // console.log(`http://localhost:${PORT}`);
});
const io = require('socket.io')(server);

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
        // findAll(socket, src, dest);
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