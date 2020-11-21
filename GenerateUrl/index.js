const axios = require('axios');
const url = require('url');
const open = require('open');

const getQuery = (socket, type) => {
  switch (type) {
    case 'request':
        return {
            socketId: socket,
            topic: 'result',
            body: JSON.stringify({
                partner: 'Aof | 0800420423',
                callTaxi: true,
                distance: '1.25 KM',
                path: [
                  { lat: 13.6494925, lng: 100.4953804 },
                  { lat: 13.655127, lng: 100.498858 },
                  { lat: 13.662462, lng: 100.438272 },
                  { lat: 13.664666, lng: 100.441415 }
                ],
                estimatedPrice: '120 บาท',
                points: [ 
                    'KMUTT', 
                    'The Cube', 
                    'Cen 2', 
                    'Green night market'
                ]
            }),
        };
    case 'cancel':
        return {
            socketId: socket,
            topic: 'cancel',
            body: ''
        };
  }
};

(async () => {
    const response = await axios.get('https://afternoon-tor-56476.herokuapp.com/all')
    const aliveSocket = response.data.filter( s => s.alive )
    if(aliveSocket.length > 0) {
        const socket = aliveSocket[0].socket;
        const result = url.format({
            protocol: 'https',
            hostname: 'afternoon-tor-56476.herokuapp.com',
            pathname: '/publish',
            query: getQuery(socket, 'cancel'),
        });
        await open(`${result}`, { wait: true });
    }
})();