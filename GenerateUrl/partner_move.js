const axios = require('axios');
const url = require('url');
const open = require('open');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

const getQuery = (socket, type, position) => {
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
                  { lat: 13.690785, lng: 100.547337 },
                  { lat: 13.678936, lng: 100.649961 },
                //   { lat: 13.662462, lng: 100.438272 }, Cen 2
                //   { lat: 13.664666, lng: 100.441415 } Green Night Market
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
    case 'partner_move':
        return {
            socketId: socket,
            topic: 'partner_move',
            body: JSON.stringify(position),
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
        const type = 'partner_move';

        const socket = aliveSocket[0].socket;

        
        let lat = 13.690785;
        let lng = 100.547337;

        // { lat: 13.690785, lng: 100.547337 },

        for(var i =0; i <= 1; i++) {
            const result = url.format({
                protocol: 'https',
                hostname: 'afternoon-tor-56476.herokuapp.com',
                pathname: '/publish',
                query: getQuery(socket, type, { lat, lng },),
            });
            await axios.get(result);
            await sleep(5);

            lat += 0.0001;
        }
    }
})();